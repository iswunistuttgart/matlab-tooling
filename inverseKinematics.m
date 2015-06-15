function [length, varargout] = inverseKinematics(Pose, PulleyPositions, CableAttachments, varargin)
% INVERSEKINEMATICS - Perform inverse kinematics for the given robot
%   Inverse kinematics means to determine the values for the joint
%   variables (in this case cable lengths) for a given endeffector pose.
%   This is quite a simple setup for cable-driven parallel robots because
%   the equation for the kinematic loop has to be solved, which is the sole
%   purpose of this method.
%   It can determine the cable lengths for any given robot configuration
%   (note that calculations will be done as if we were looking at a 3D/6DOF
%   cable robot following necessary conventions, so adjust your variables
%   accordingly). To determine the cable lengths, different algorithms may be
%   used (please see below for the 'ALGORITHM' option). Note that all cable
%   lengths will always be from the PulleyPosition to the platform, any free
%   cable length that you might have before the last pulley needs to be added by
%   you manually after running this method
% 
%   LENGTH = INVERSEKINEMATICS(POSE, PULLEYPOSITIONS, CABLEATTACHMENTS)
%   performs simple inverse kinematics with the cables running from a_i to
%   b_i for the given pose
%   
%   LENGTH = INVERSEKINEMATICS(POSE, PULLEYPOSITIONS, CABLEATTACHMENTS,
%   ALGORITHM) performs inverse kinematics according to the selected algorithm.
%   Implemented algorithms are
%       'Simple'            Standard straight-line model
%       'Pulley'            Pulley kinematics with pulley radius and rotation
%                           included
%       'CatenarySimple'    TO COME Using a catenary approach the cable length will be
%                           calculated assuming ideal cable entry points (i.e.,
%                           no rotation or radius of the pulleys.
%       'CatenaryPulley'    TO COME Most advanced algorithm to determine catenary cable
%                           line with the inclusion of pulleys that is rotation
%                           of the pulley and cable wrapping around the pulley.
%   
%   LENGTH = INVERSEKINEMATICS(POSE, ..., 'PulleyOrientations',
%   mPulleyOrientations) performs non-standard inverse kinematics given the
%   specified pulley orientations.
%   
%   LENGTH = INVERSEKINEMATICS(POSE, ..., 'PulleyRadius', vPulleyRadius)
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
%   PULLEYPOSITIONS: Matrix of pulley positions w.r.t. the world frame. Each
%   pulley has its own column and the rows are the x, y, and z-value,
%   respectively i.e., PULLEYPOSITIONS must be a matrix of 3xM values. The
%   number of pulleyes i.e., M, must match the number of cable attachment
%   points in CABLEATTACHMENTS (i.e., its column count) and the order must
%   mach the real linkage of pulley to cable attachment on the platform
% 
%   CABLEATTACHMENTS: Matrix of cable attachment points w.r.t. the
%   platforms coordinate system. Each attachment point has its own column
%   and the rows are the x, y, and z-value, respectively, i.e.,
%   CABLEATTACHMENTS must be a matrix of 3xM values. The number of cables
%   i.e., M, must match the number of pulleyes in PULLEYPOSITIONS (i.e., its
%   column count) and the order must match the real linkage of cable
%   attachment on the platform to pulley.
% 
%   USEADVANCED: Optional positional parameter argument that tells the
%   script to use advanced inverse kinematics algorithms to determining the
%   cable length. Must be a logical value i.e, true or false
%   
%   'PulleyOrientations': Matrix of orientations for each pulley w.r.t. the
%   global coordinate system. Every pulley's orientation is stored in a
%   column where the first row is the orientation about x-axis, the second
%   about y-axis, and the third about z-axis. This means, WINCHORIENTATIONS
%   must be a matrix of 3xM values. The number of orientations, i.e., M,
%   must match the number of pulleyes in PULLEYPOSITIONS (i.e., its column
%   count) and the order must match the order pulleyes in PULLEYPOSITIONS
% 
%   'PulleyRadius': Vector of pulley radius per pulley given in meter
%   i.e., WINCHPULLEYRADIUS is a vector of 1xM values where M must match
%   the number of pulleyes in PULLEYPOSITIONS and the order must be the same,
%   too.
% 
%   Outputs:
% 
%   LENGTH: Length is a vector of size 1xM with the cable lengths
%   determined using either simple or advanced kinematics
%
%   CABLEVECTOR: Vectors of each cable from attachment point to (corrected)
%   pulley point
%   
%   CABLEUNITVECTOR: Normalized vector for each cable from attachment point
%   to its (corrected) pulley point
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
valFcn_PulleyPositions = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'ncols', size(CableAttachments, 2)}, mfilename, 'PulleyPositions');
addRequired(ip, 'PulleyPositions', valFcn_PulleyPositions);

% And we need the b_i's
valFcn_CableAttachmens = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'ncols', size(PulleyPositions, 2)}, mfilename, 'CableAttachments');
addRequired(ip, 'CableAttachments', valFcn_CableAttachmens);

% We allow the user to explicitley flag which algorithm to use
valFcn_Algorithm = @(x) any(validatestring(x, {'standard', 'pulley', 'catenary'}, mfilename, 'UseAdvanced'));
addOptional(ip, 'Algorithm', 'standard', valFcn_Algorithm);

% We might want to use the pulley orientations
valFcn_PulleyOrientations = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'ncols', size(PulleyPositions, 2)}, mfilename, 'PulleyOrientations');
addParameter(ip, 'PulleyOrientations', zeros(3, size(PulleyPositions, 2)), valFcn_PulleyOrientations);

% We might want the pulley radius to be defined if using advanced
% kinematics
valFcn_PulleyRadius = @(x) validateattributes(x, {'numeric'}, {'vector', 'ncols', size(PulleyPositions, 2)}, mfilename, 'PulleyRadius');
addParameter(ip, 'PulleyRadius', zeros(1, size(PulleyPositions, 2)), valFcn_PulleyRadius);

% Configuratio nfor the input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, Pose, PulleyPositions, CableAttachments, varargin{:});



%% Parse variables so we can use them natively
chAlgorithm = ip.Results.Algorithm;
vPlatformPose = ip.Results.Pose;
mPulleyPositions = ip.Results.PulleyPositions;
mPulleyOrientations = ip.Results.PulleyOrientations;
vPulleyRadius = ip.Results.PulleyRadius;
mCableAttachments = ip.Results.CableAttachments;



%% Do the magic
%%% What algorithm to use?
switch lower(chAlgorithm)
    case 'catenary'
%         [vCableLength, mCableVector, mCableUnitVector, mCableLine] = algoInverseKinematics_Catenary(vPlatformPose, mPulleyPositions, mCableAttachments, mPulleyOrientations, ?.?.?);
    % Advanced kinematics algorithm (including pulley radius)
    case 'pulley'
        [vCableLength, mCableVector, mCableUnitVector, mPulleyAngles] = algoInverseKinematics_Pulley(vPlatformPose, mPulleyPositions, mCableAttachments, vPulleyRadius, mPulleyOrientations);
    % Simple kinematics algorithm (no pulley radius)
    case 'standard'
        [vCableLength, mCableVector, mCableUnitVector] = algoInverseKinematics_Simple(vPlatformPose, mPulleyPositions, mCableAttachments);
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
    if chAlgorithm
        varargout{3} = mPulleyAngles;
    end
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
