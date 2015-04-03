function [length, varargout] = inverseKinematics(pose, winchPositions, cableAttachments, varargin)
% INVERSEKINEMATICS - Perform inverse kinematics for the given robot
%   Inverse kinematics means to determine the values for the joint
%   variables (in this case cable lengths) for a given endeffector pose.
%   This is quite a simple setup for cable-driven parallel robots because
%   the equation for the kinematic loop has to be solved, which is the sole
%   purpose of this method.
%   It can determine the cable lengths for any given robot configuration
%   (note that calculations will be done as if we were looking at a 3D/6DOF
%   cable robot following necessary conventions, so adjust your variables
%   accordingly). To determine the cable lengths, both the simple kinematic
%   loop can be used as well as the advanced pulley kinematics (considering
%   pulley radius and rotatability).
% 
%   LENGTH = INVERSEKINEMATICS(POSE, WINCHPOSITIONS, CABLEATTACHMENTS)
%   performs simple inverse kinematics with the cables running from a_i to
%   b_i for the given pose
%   
%   LENGTH = INVERSEKINEMATICS(POSE, WINCHPOSITIONS, CABLEATTACHMENTS, true)
%   performs advanced inverse kinematics for the given pose assuming no
%   separate rotation of the winches nor any pulley radius
%   
%   LENGTH = INVERSEKINEMATICS(POSE, ..., 'WinchOrientations', mWinchOrientations)
%   performs advanced inverse kinematics given the specified winch
%   orientations.
%   
%   LENGTH = INVERSEKINEMATICS(POSE, ..., 'WinchPulleyRadius', vPulleyRadius)
%   performs advanced inverse kinematics taking into account the specified
%   pulley radius.
% 
%   [LENGTH, CABLEVECTORS] = INVERSEKINEMATICS(Pose, ...) also provides the
%   vectors of the cable directions from platform to attachment point given
%   in the global coordinate system
%   
%   Inputs:
%   
%   POSE: The current robots pose given as a 12-column row vector that has
%   the [x, y, z] position in the first three entries and then follwing are
%   the entries of the rotation matrix such that the vector POSE looks
%   something like this
%   pose = [x, y, z, R11, R12, R13, R21, R22, R23, R31, R32, R33]
% 
%   WINCHPOSITIONS: Matrix of winch positions w.r.t. the world frame. Each
%   winch has its own column and the rows are the x, y, and z-value,
%   respectively i.e., WINCHPOSITIONS must be a matrix of 3xN values. The
%   number of winches i.e., N, must match the number of cable attachment
%   points in CABLEATTACHMENTS (i.e., its column count) and the order must
%   mach the real linkage of winch to cable attachment on the platform
% 
%   CABLEATTACHMENTS: Matrix of cable attachment points w.r.t. the
%   platforms coordinate system. Each attachment point has its own column
%   and the rows are the x, y, and z-value, respectively, i.e.,
%   CABLEATTACHMENTS must be a matrix of 3xN values. The number of cables
%   i.e., N, must match the number of winches in WINCHPOSITIONS (i.e., its
%   column count) and the order must match the real linkage of cable
%   attachment on the platform to winch.
% 
%   USEADVANCED: Optional positional parameter argument that tells the
%   script to use advanced inverse kinematics algorithms to determining the
%   cable length. Must be a logical value i.e, true or false
%   
%   'WinchOrientations': Matrix of orientations for each winch w.r.t. the
%   global coordinate system. Every winch's orientation is stored in a
%   column where the first row is the orientation about x-axis, the second
%   about y-axis, and the third about z-axis. This means, WINCHORIENTATIONS
%   must be a matrix of 3xN values. The number of orientations, i.e., N,
%   must match the number of winches in WINCHPOSITIONS (i.e., its column
%   count) and the order must match the order winches in WINCHPOSITIONS
% 
%   'WinchPulleyRadius': Vector of pulley radius per winch given in meter
%   i.e., WINCHPULLEYRADIUS is a vector of 1xN values where N must match
%   the number of winches in WINCHPOSITIONS and the order must be the same,
%   too.
% 
%   Outputs:
% 
%   LENGTH: Length is a vector of size 1xN with the cable lengths
%   determined using either simple or advanced kinematics
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-04-03
% Changelog:
%   2015-04-03: Initial release


%------------- BEGIN CODE --------------

%% Create an input parser
% Input parse to easily parse input arguments
ip = inputParser;

% Allow the pose to be a row vector of
% [x, y, z, R11, R12, R13, R21, R22, R23, R31, R32, R33];
valFcn_Pose = @(x) isrow(x) && numel(x) == 12;
% Allow the winch positions to be given as
% [a_1x, a_2x, ..., a_nx; ...
%  a_1y, a_2y, ..., a_ny; ...
%  a_1z, a_2z, ..., a_nz];
valFcn_WinchPositions = @(x) ismatrix(x) && size(x, 1) == 3 && size(x, 2) == size(cableAttachments, 2);
% Allow the cable attachments to be given as
% [b_1x, b_2x, ..., b_nx; ...
%  b_1y, b_2y, ..., b_ny; ...
%  b_1z, b_2z, ..., b_nz];
valFcn_CableAttachmens = @(x) ismatrix(x) && size(x, 1) == 3 && size(x, 2) == size(winchPositions, 2);
% Allow the winch orientations to be given as
% [a_1, a_2, ..., a_3; ...
%  b_1, b_2, ..., b_3; ...
%  c_1, c_2, ..., c_3];
% for a rotation result of R_i = rotz(c_i)*roty(b_i)*rotx(a_i);
valFcn_WinchOrientations = @(x) ismatrix(x) && size(x, 1) == 3 && size(x, 2) == size(cableAttachments, 2);
% Allow the winch pulley radius to only be a matrix of one radius per winch
valFcn_WinchPulleyRadius = @(x) isrow(x) && size(x, 2) == size(winchPositions, 2);

%%% This fills in the parameters for the function
% We need the current pose...
addRequired(ip, 'Pose', valFcn_Pose);
% We need the a_i's ...
addRequired(ip, 'WinchPositions', valFcn_WinchPositions);
% And we need the b_i's
addRequired(ip, 'CableAttachments', valFcn_CableAttachmens);
% We allow the user to explicitley flag which algorithm to use
addOptional(ip, 'UseAdvanced', false, @islogical);
% We might want to use the winch orientations
addParameter(ip, 'WinchOrientations', zeros(3, size(winchPositions, 2)), valFcn_WinchOrientations);
% We might want the pulley radius to be defined if using advanced
% kinematics
addParameter(ip, 'WinchPulleyRadius', zeros(1, size(winchPositions, 2)), valFcn_WinchPulleyRadius);

% Configuratio nfor the input parser
ip.KeepUnmatched = true;
ip.FunctionName = 'calculateCableLength';

% Parse the provided inputs
parse(ip, pose, winchPositions, cableAttachments, varargin{:});

%% Parse variables so we can use them natively
bUseAdvanced = ip.Results.UseAdvanced;
vPlatformPose = ip.Results.Pose;
vPlatformPosition = reshape(vPlatformPose(1:3), 3, 1);
vPlatformRotation = vPlatformPose(4:end);
mPlatformRotation = reshape(vPlatformRotation, 3, 3);
mWinchPositions = ip.Results.WinchPositions;
mWinchOrientations = ip.Results.WinchOrientations;
vWinchPulleyRadius = ip.Results.WinchPulleyRadius;
mCableAttachments = ip.Results.CableAttachments;

%% Init output
length = zeros(1, size(mWinchPositions, 2));


%% Do the magic
% Initialize zero cable length for every cables
mCableLength = zeros(3, size(mWinchPositions, 2));
vCableLength = zeros(1, size(mWinchPositions, 2));

%%% What algorithm to use?
% Advanced kinematics algorithm
if bUseAdvanced
    for iUnit = 1:size(mWinchPositions, 2)
        % Rotation matrix to rotate any vector given in A to the global
        % coordinate system
        mRotation_kA2kO = rotz(mWinchOrientations(3, iUnit))*roty(mWinchOrientations(2, iUnit))*rotx(mWinchOrientations(1, iUnit));
        
        % Vector from cable contact point on pulley to cable attachment
        % point on platform. This is needed to determine the pulley's
        % rotation about the local z-axis (z-axis of system A)
        v_A2B_in_kO = vPlatformPosition + mPlatformRotation*mCableAttachments(:, iUnit) - mWinchPositions(:, iUnit);
        
        % Transform the vector from A to B into K_A so that we can
        % determine the local rotation about the z-axis (this leads to
        % coordinate system AB (A rotated such that its x-axis aligns with
        % the vector of A through B)
        v_A2B_in_kA = transpose(mRotation_kA2kO)*v_A2B_in_kO;
        
        % Get the rotation angle (whatch out, this is being done in degree
        % so we can use it directly for ```rotz```)
        dAngleRotation_kAB2kA_Degree = atan2d(v_A2B_in_kA(2), v_A2B_in_kA(1));
        % Code is checked and validated up to here and it is correct! (^PTT 2015-04-03 11:34)
        dAngleRotation_kAB2kA_Radian = degtorad(dAngleRotation_kAB2kA_Degree);
        
        % Rotation matrix to get any vector given in coordinate system M
        % into the coordinate system of the winch
        mRotation_kAB2kA = rotz(dAngleRotation_kAB2kA_Degree);
        
        % Vector from A to M in the rotated coordinate system of the
        % pulley, per convention the pulley is aligned with the x-axis of
        % this coordinate system, so that makes things quite easy
        v_A2M_in_kAB = vWinchPulleyRadius(iUnit)*[1; 0; 0];
        
        % The vector from M to B in K_AB is given by the closed loop from A
        % to M and then from M to B
        v_M2B_in_kAB = transpose(mRotation_kAB2kA)*v_A2B_in_kA - v_A2M_in_kAB;
        
        % Calculate the free cable length from C to B using Pythagoras
        dCableLength_C2B = sqrt(norm(v_M2B_in_kAB)^2 - vWinchPulleyRadius(iUnit)^2 );
        
        % The rotation about the y-axis of the coordinate system kM can be
        % easily determined using two angles, one being the angle that M2B
        % has relative to the x-axis of k_AB, and the other is the angle
        % that is defined by the triangle through M-C-B. Then, additionally
        % you would want to want to add 90° (or pi/2) to this result to
        % reflect the angles being measured against the x-axis of k_AB
        dAngleRotation_kM2kAB_Degree = radtodeg(pi/2) + atan2d(v_M2B_in_kAB(3), v_M2B_in_kAB(1)) + acosd(vWinchPulleyRadius(iUnit)/norm(v_M2B_in_kAB));
        dAngleRotation_kM2kAB_Radian = degtorad(dAngleRotation_kM2kAB_Degree);
        
        % Calculate the length of the cable wrapped around the pulley by
        % multiplying the wrapping angle (in radian) with the pulley radius
        dCableLength_Wrap = dAngleRotation_kM2kAB_Radian*vWinchPulleyRadius(iUnit);
        
        % The absolute cable length is obviously the cable length wrapped
        % around the pulley and the length from C to B
        vCableLength(iUnit) = dCableLength_Wrap + dCableLength_C2B;
        % Code is checked and validated up to here and it is not completey
        % correct (^PTT 2015-04-03 12:25)
    end
% Standard algorithm l_i = a_i - ( r_i + R*b_i)
else
    % We have to loop over every winch, otherwise it'll be a little too
    % complicated to get the values correct
    for iUnit = 1:size(mWinchPositions, 2)
        mCableLength(:, iUnit) = mWinchPositions(:, iUnit) - ( vPlatformPosition + mPlatformRotation*mCableAttachments(:, iUnit));
        vCableLength(iUnit) = norm(mCableLength(:, iUnit));
    end
end

% Assign output quantity
length = vCableLength;

% Assign all the other, optional output quantities
if nargout
    if nargout >= 0
        varargout{1} = mCableVector;
    end
end

end
%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
