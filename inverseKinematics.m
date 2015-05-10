function [length, varargout] = inverseKinematics(Pose, WinchPositions, CableAttachments, varargin)
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
%   [LENGTH, CABLEVECTORS, CABLEUNITVECTORS] = INVERSEKINEMATICS(...) also
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
%   respectively i.e., WINCHPOSITIONS must be a matrix of 3xM values. The
%   number of winches i.e., M, must match the number of cable attachment
%   points in CABLEATTACHMENTS (i.e., its column count) and the order must
%   mach the real linkage of winch to cable attachment on the platform
% 
%   CABLEATTACHMENTS: Matrix of cable attachment points w.r.t. the
%   platforms coordinate system. Each attachment point has its own column
%   and the rows are the x, y, and z-value, respectively, i.e.,
%   CABLEATTACHMENTS must be a matrix of 3xM values. The number of cables
%   i.e., M, must match the number of winches in WINCHPOSITIONS (i.e., its
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
%   must be a matrix of 3xM values. The number of orientations, i.e., M,
%   must match the number of winches in WINCHPOSITIONS (i.e., its column
%   count) and the order must match the order winches in WINCHPOSITIONS
% 
%   'WinchPulleyRadius': Vector of pulley radius per winch given in meter
%   i.e., WINCHPULLEYRADIUS is a vector of 1xM values where M must match
%   the number of winches in WINCHPOSITIONS and the order must be the same,
%   too.
% 
%   Outputs:
% 
%   LENGTH: Length is a vector of size 1xM with the cable lengths
%   determined using either simple or advanced kinematics
%
%   CABLEVECTOR: Vectors of each cable from attachment point to (corrected)
%   winch point
%   
%   CABLEUNITVECTOR: Normalized vector for each cable from attachment point
%   to its (corrected) winch point
% 
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-04-03
% Changelog:
%   2015-04-22: Add commentary for outputs CableVector and CableUnitVector
%   2015-04-03: Initial release



%% Create an input parser
% Input parse to easily parse input arguments
ip = inputParser;

%%% This fills in the parameters for the function
% We need the current pose...
valFcn_Pose = @(x) validateattributes(x, {'numeric'}, {'vector', 'ncols', 12}, mfilename, 'Pose');
addRequired(ip, 'Pose', valFcn_Pose);

% We need the a_i's ...
valFcn_WinchPositions = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'ncols', size(CableAttachments, 2)}, mfilename, 'WinchPositions');
addRequired(ip, 'WinchPositions', valFcn_WinchPositions);

% And we need the b_i's
valFcn_CableAttachmens = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'ncols', size(WinchPositions, 2)}, mfilename, 'CableAttachments');
addRequired(ip, 'CableAttachments', valFcn_CableAttachmens);

% We allow the user to explicitley flag which algorithm to use
valFcn_UseAdvanced = @(x) any(validatestring(x, {'yes', 'no', 'on', 'off'}, mfilename, 'UseAdvanced'));
addOptional(ip, 'UseAdvanced', false, valFcn_UseAdvanced);

% We might want to use the winch orientations
valFcn_WinchOrientations = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'ncols', size(WinchPositions, 2)}, mfilename, 'WinchOrientations');
addParameter(ip, 'WinchOrientations', zeros(3, size(WinchPositions, 2)), valFcn_WinchOrientations);

% We might want the pulley radius to be defined if using advanced
% kinematics
valFcn_WinchPulleyRadius = @(x) validateattributes(x, {'numeric'}, {'vector', 'ncols', size(WinchPositions, 2)}, mfilename, 'WinchPulleyRadius');
addParameter(ip, 'WinchPulleyRadius', zeros(1, size(WinchPositions, 2)), valFcn_WinchPulleyRadius);

% Configuratio nfor the input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, Pose, WinchPositions, CableAttachments, varargin{:});



%% Parse variables so we can use them natively
bUseAdvanced = ip.Results.UseAdvanced;
vPlatformPose = ip.Results.Pose;
mWinchPositions = ip.Results.WinchPositions;
mWinchOrientations = ip.Results.WinchOrientations;
vWinchPulleyRadius = ip.Results.WinchPulleyRadius;
mCableAttachments = ip.Results.CableAttachments;



%% Do the magic
%%% What algorithm to use?
% Advanced kinematics algorithm (including pulley radius)
if bUseAdvanced
    [vCableLength, mCableVector, mCableUnitVector, mWinchPulleyAngles] = algoInverseKinematics_Pulley(vPlatformPose, mWinchPositions, mCableAttachments, vWinchPulleyRadius, mWinchOrientations);
% Simple kinematics algorithm (no pulley radius)
else
    [vCableLength, mCableVector, mCableUnitVector] = algoInverseKinematics_Simple(vPlatformPose, mWinchPositions, mCableAttachments);
end



%% Assign output quantities
length = vCableLength;

%%% Assign all the other, optional output quantities
% Second output argument is the matrix of cable directions vectors
if nargout >= 2
    varargout{1} = mCableVector;
end

% Third output is the matrix of normalized cable direction vectors
if nargout >= 3
    varargout{2} = mCableUnitVector;
end

% Fourth output argument...
if nargout >= 4
    % For the advanced algorithms we are returning the wrapping angles
    if bUseAdvanced
        varargout{3} = mWinchPulleyAngles;
    end
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
