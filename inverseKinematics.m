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
%   [LENGTH, CABLEVECTORS] = INVERSEKINEMATICS(...) also provides the
%   vectors of the cable directions from platform to attachment point given
%   in the global coordinate system
% 
%   [LENGTH, CABLEVECTORS, CABLEUNITVECTORS = INVERSEKINEMATICS(...) also
%   provides the unit vectors for each cable which might come in handy at
%   times
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
% Holds the vectors of the cables (i.e., from B to A (or A-adjusted i.e.,
% C))
mCableVector = zeros(3, size(mWinchPositions, 2));
% Holds the unit vectors for each cable vector
mCableUnitVector = zeros(3, size(mWinchPositions, 2));
% % Adjustements to the cable length (primarily used by the advanced
% % algorithm to allow for adding the wound up cable length
% % vCableLengthAdjustment = zeros(1, size(mWinchPositions, 2));
% Final length of the cables (may also already contain cable length
% adjustment determined by the advanced algorithm
vCableLength = zeros(1, size(mWinchPositions, 2));


%% Do the magic
%%% What algorithm to use?
% Advanced kinematics algorithm
if bUseAdvanced
    for iUnit = 1:size(mWinchPositions, 2)
        % Rotation matrix to rotate any vector given in winch coordinate
        % system K_A into the global coordinate system K_O
        mRotation_kA2kO = rotz(mWinchOrientations(3, iUnit))*roty(mWinchOrientations(2, iUnit))*rotx(mWinchOrientations(1, iUnit));
        
        % Vector from contact point of cable on pulley A to cable
        % attachment point on the platform B given in coordinates of system
        % A
        v_A2B_in_kA = transpose(mRotation_kA2kO)*(vPlatformPosition + mPlatformRotation*mCableAttachments(:, iUnit) - mWinchPositions(:, iUnit));
        
        % Determine the angle of rotation of the pulley to have the
        % pulley's x-axis point in the direction of the cable which points
        % towards B
        dRotationAngleAbout_kAz_Degree = atan2d(v_A2B_in_kA(2), v_A2B_in_kA(1));
        
        % Rotation matrix from pulley coordinate system K_P to winch
        % coordinate system K_A
        mRotation_kP2kA = rotz(dRotationAngleAbout_kAz_Degree);
        
        % Vector from point P (center of coordinate system K_P) to the
        % cable attachment point B given in the coordinate system of the
        % pulley (easily transferable from the same vector given in K_A by
        % simply rotating it about the local z-axis of K_A)
        v_A2B_in_kP = transpose(mRotation_kP2kA)*v_A2B_in_kA;
        v_P2B_in_kP = v_A2B_in_kP;
        
        % Vector from P to the pulley center given in the pulley coordinate
        % system K_P
        v_P2M_in_kP = vWinchPulleyRadius(iUnit)*[1; 0; 0];
        
        % Closed vector loop to determine the vector from M to B in
        % coordinate system K_P: P2M + M2B = P2B. This basically also
        % transforms our coordinate system K_P to K_M
        v_M2B_in_kP = v_P2B_in_kP - v_P2M_in_kP;
        
        % Convert everything in to the coordinate system K_M of the
        % pulley's center
        v_M2B_in_kM = v_M2B_in_kP;
        
        % Preliminarily determine the cable length (this helps us to
        % determine the angle beta_3 to later on determine the angle of the
        % vector from M to C in the coordinate system of M. It is quite
        % simple to do so using Pythagoras: l^2 + radius^2 = M2B^2
        dCableLength_C2B = sqrt(norm(v_M2B_in_kM)^2 - vWinchPulleyRadius(iUnit));
        
        % Determine the angle of rotation of that vector relative to the
        % x-axis of K_P. This is beta_2 in PTT's sketch
        dAngleBetween_M2B_and_xM_Degree = atan2d(v_M2B_in_kP(3), v_M2B_in_kP(1));
        
        % Now we can determine the angle between M2B and M2C using
        % trigonometric functions because cos(beta_3) = radius/M2B and as
        % well sin(beta_3) = L/M2B or tan(beta_3) = L/radius
        dAngleBetween_M2B_and_M2C_Degree = atand(dCableLength_C2B/vWinchPulleyRadius(iUnit));
        
        % Angle between the x-axis of M and the vector from M to C given in
        % coordinate system K_M and in degree
        dAngleBetween_xM_and_M2C_Degree = dAngleBetween_M2B_and_M2C_Degree + dAngleBetween_M2B_and_xM_Degree;
        
        % Vector from winch center M to adjusted cable release point C in
        % system K_M is nothing but the scaled x-axis rotated about the
        % y-axis with previsouly determined angle beta2
        mRotation_kC2kM = roty(dAngleBetween_xM_and_M2C_Degree);
        v_M2C_in_kM = transpose(mRotation_kC2kM)*(vWinchPulleyRadius(iUnit).*[1; 0; 0]);
        
        % Wrapping angle can be calculated in to ways, either by getting
        % the angle between the scaled negative x-axis (M to P) and the
        % vector M to C, or by getting the angle between the scaled
        % positive x-axis and the vector M to C
        v_M2P_in_kM = vWinchPulleyRadius(iUnit).*[-1; 0; 0];
        dAngleWrap_Degree = acosd(dot(v_M2P_in_kM, v_M2C_in_kM)/(norm(v_M2P_in_kM)*norm(v_M2C_in_kM)));
        
        % Adjust the winch position given the coordinates to point C
        mWinchPositions(:, iUnit) = mWinchPositions(:, iUnit) + mRotation_kA2kO*(mRotation_kP2kA*(v_P2M_in_kP + v_M2C_in_kM));
        vCableLength(iUnit) = degtorad(dAngleWrap_Degree)*vWinchPulleyRadius(iUnit);
        
%         % Calculate the cable vector (from attachment point B to last
%         % contact point of cable on pulley)
%         mCableVector(:, iUnit) = mWinchPositions(:, iUnit) - ( vPlatformPosition + mPlatformRotation*mCableAttachments(:, iUnit));
%         % Calculate the normalized vector of the cable direction
%         mCableUnitVector(:, iUnit) = mCableVector(:, iUnit)./norm(mCableVector(:, iUnit));
%         % And finally, determine the actual cable length which is nothing
%         % else but the length from adjusted A (in this case C) and the
%         % distance on the pulley the cable is wrapped up
%         vCableLength(iUnit) = norm(mCableVector(:, iUnit)) + degtorad(dAngleWrap_Degree)*vWinchPulleyRadius(iUnit);
        
        
        % Code is checked and validated up to here and it is correct
        % ^ PTT 2015-04-04 11-53
    end
% % Standard algorithm l_i = a_i - ( r_i + R*b_i)
% else
end

%% Determine the actual cable length
% Given the standard algorithm l_i = a_i - ( r_i + R*b_i) which may have
% adjusted a_i and also an adjustment for the determined cable length, the
% cable length will be determined here
% We have to loop over every winch, otherwise it'll be a little too
% complicated to get the values correct
for iUnit = 1:size(mWinchPositions, 2)
    % Get the cable vector according to l_i = a_i - ( r_i + R*b_i )
    mCableVector(:, iUnit) = mWinchPositions(:, iUnit) - ( vPlatformPosition + mPlatformRotation*mCableAttachments(:, iUnit));
    % Determine the cable length by taking the norm of the cable vector and
    % also adding previously determined cable length adjustment values
    % (stored in vCableLength is e.g., the length of the cable on the
    % pulley)
    vCableLength(iUnit) = vCableLength(iUnit) + norm(mCableVector(:, iUnit));
    
    % Only determine the cable unit vector in case it is requested (this
    % saves some computational time
    if nargout > 2
        mCableUnitVector(:, iUnit) = mCableVector(:, iUnit)./norm(mCableVector(:, iUnit));
    end
end

% Assign output quantity
length = vCableLength;

% Assign all the other, optional output quantities
if nargout
    if nargout > 1
        varargout{1} = mCableVector;
    end
    
    if nargout > 2
        varargout{2} = mCableUnitVector;
    end
end

end
%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
