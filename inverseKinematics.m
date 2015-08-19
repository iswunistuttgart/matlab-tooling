function [length, varargout] = inverseKinematics(Pose, PulleyPositions, CableAttachments, varargin)
% INVERSEKINEMATICS - Perform inverse kinematics for the given robot
%   Inverse kinematics means to determine the values for the joint variables
%   (in this case cable lengths) for a given endeffector pose. This is quite a
%   simple setup for cable-driven parallel robots because the equation for the
%   kinematic loop has to be solved, which is the sole purpose of this method.
%   
%   It can determine the cable lengths for any given robot configuration (note
%   that calculations will be done as if we were looking at a 3D/6DOF cable
%   robot following necessary conventions, so adjust your variables
%   accordingly). To determine the cable lengths, different algorithms may be
%   used (please see below for the 'ALGORITHM' option). Note that all cable
%   lengths will always be from the PulleyPosition to the platform, any free
%   cable length that you might have before the last pulley need to be added by
%   you manually after running this method
% 
%   LENGTH = INVERSEKINEMATICS(POSE, PULLEYPOSITIONS, CABLEATTACHMENTS)
%   performs standard inverse kinematics with the cables running from a_i to
%   b_i for the given pose
%   
%   LENGTH = INVERSEKINEMATICS(POSE, PULLEYPOSITIONS, CABLEATTACHMENTS,
%   ALGORITHM) performs inverse kinematics according to the selected algorithm.
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
%   ALGORITHM: Optional positional parameter argument that tells the
%   script to use advanced inverse kinematics algorithms to determining the
%   cable length.
%   Implemented algorithms are
%       'Standard'          Standard straight-line model
%       'Pulley'            Pulley kinematics with pulley radius and rotation
%                           included
%       'Catenary'          Uses non-elastic catenary lines between the
%                           locations of the pulleys and the platforms's anchor
%                           points
%       'Catenary-Elastic'  TO COME Using a catenary approach the cable length
%                           will be calculated assuming ideal cable entry points
%                           (i.e., no rotation or radius of the pulleys.
%       'Catenary+Pulley'   TO COME Most advanced algorithm to determine
%                           catenary cable line with the inclusion of pulleys
%                           that is rotation of the pulley and cable wrapping
%                           around the pulley.
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
%   'ReturnStruct': Allows to have just one return value which then is a struct
%   of all the available variables as per the algorithm. Can be set to any valid
%   string of 'off', 'no', 'on', 'yes', 'please'. Only 'on', 'yes', and 'please'
%   will actually return a struct then
% 
%   Outputs:
% 
%   LENGTH: Length is a vector of size 1xM with the cable lengths determined
%   using either simple or advanced kinematics. If option 'ReturnStruct' is
%   given, then length will be a structure of available variables such as
%   'Length', 'Vector', 'UnitVector', ...
%
%   VECTOR: Vectors of each cable from attachment point to (corrected) pulley
%   point
%   
%   UNITVECTOR: Normalized vector for each cable from attachment point to its
%   (corrected) pulley point
%   
%   PULLEYANGLES: Matrix of gamma and beta angles of rotation and wrapping angle
%   of pulley and cable on pulley respectively, given as 2xM matrix where the
%   first row is the rotation about the z-axis of the pulley, and the second
%   row is the wrapping angle about the pulley. Returned only for algorithms
%   'pulley' and 'catenary+pulley'
% 
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-08-15
% Changelog:
%   2015-08-15
%       * Change option 'Catenary' to 'Catenary-Elastic'
%       * Introduce new option 'Catenary' which returns non-elastic catenaries
%   2015-06-18
%       * Replace option 'UseAdvanced' with 'Algorithm' and implement logic for
%       allowing to use 'catenary' and 'catenary+pulley' as algorithm
%       * Add option 'ReturnStruct' to return a struct of all available
%       variables instead of a long list of variable varargouts
%       * Change 'Winch' to 'Pulley' in all its forms
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
valFcn_Algorithm = @(x) any(validatestring(lower(x), {'standard', 'pulley', 'catenary', 'catenary+pulley'}, mfilename, 'Algorithm'));
addOptional(ip, 'Algorithm', 'standard', valFcn_Algorithm);

% We might want to use the pulley orientations
valFcn_PulleyOrientations = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'ncols', size(PulleyPositions, 2)}, mfilename, 'PulleyOrientations');
addParameter(ip, 'PulleyOrientations', zeros(3, size(PulleyPositions, 2)), valFcn_PulleyOrientations);

% We might want the pulley radius to be defined if using advanced
% kinematics
valFcn_PulleyRadius = @(x) validateattributes(x, {'numeric'}, {'vector', 'ncols', size(PulleyPositions, 2)}, mfilename, 'PulleyRadius');
addParameter(ip, 'PulleyRadius', zeros(1, size(PulleyPositions, 2)), valFcn_PulleyRadius);

% Use needs some more output? Of course, just use 'Verbose', 'yes' or 'on'
valFcn_Verbose = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'Verbose'));
addParameter(ip, 'Verbose', 'off', valFcn_Verbose);

% Return a struct as the only return value of this function?
valFcn_ReturnStruct = @(x) any(validatestring(lower(x), {'off', 'no', 'on', 'yes'}, mfilename, 'ReturnStruct'));
addParameter(ip, 'ReturnStruct', 'off', valFcn_ReturnStruct);

% Configuratio nfor the input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, Pose, PulleyPositions, CableAttachments, varargin{:});



%% Parse variables so we can use them natively
chAlgorithm = ip.Results.Algorithm;
vPlatformPose = ip.Results.Pose;
aPulleyPositions = ip.Results.PulleyPositions;
aPulleyOrientations = ip.Results.PulleyOrientations;
vPulleyRadius = ip.Results.PulleyRadius;
aCableAttachments = ip.Results.CableAttachments;
chReturnStruct = inCharToValidArgument(ip.Results.ReturnStruct);



%% Do the magic
%%% What algorithm to use?
switch lower(chAlgorithm)
    % Catenary kinematics with non-elastic cables
    case 'catenary'
%         [vCableLength, aCableVector, aCableUnitVector, aCableLine] = algoInverseKinematics_Catenary(vPlatformPose, aPulleyPositions, aCableAttachments, aPulleyOrientations, ?.?.?);
    % Catenary kinematics with elastic cables
    case 'catenary-elastic'
%         [vCableLength, aCableVector, aCableUnitVector, aCableLine] = algoInverseKinematics_CatenaryElastic(vPlatformPose, aPulleyPositions, mCableAttachments, aPulleyOrientations, ?.?.?);
    % Catenary kinematics with pulley deflection
    case 'catenary+pulley'
%         [vCableLength, aCableVector, aCableUnitVector, aCableLine] = algoInverseKinematics_CatenaryPulley(vPlatformPose, aPulleyPositions, aCableAttachments, aPulleyOrientations, ?.?.?);
    % Advanced kinematics algorithm (including pulley radius)
    case 'pulley'
        [vCableLength, aCableUnitVector, aCorrectedPulleyPositions, aPulleyAngles] = algoInverseKinematics_Pulley(vPlatformPose, aPulleyPositions, aCableAttachments, vPulleyRadius, aPulleyOrientations);
    % Standard kinematics algorithm (no pulley radius)
    case 'standard'
        [vCableLength, aCableUnitVector] = algoInverseKinematics_Standard(vPlatformPose, aPulleyPositions, aCableAttachments);
    otherwise
        [vCableLength, aCableUnitVector] = algoInverseKinematics_Standard(vPlatformPose, aPulleyPositions, aCableAttachments);
end
% end ```switch lower(chAlgorithm)```


%% Assign output quantities
if strcmp(chReturnStruct, 'on')
    length = struct();
    length.Length = vCableLength;
    length.PulleyAngles = zeros(2, size(aPulleyPositions, 2));
    length.PulleyPosition = aPulleyPositions;
    length.UnitVector = aCableUnitVector;
        
    switch chAlgorithm
        case 'catenary-elastic'
            
        case 'catenary+pulley'
            
        case 'pulley'
            length.PulleyAngles = aPulleyAngles;
            length.PulleyPosition = aCorrectedPulleyPositions;
        otherwise
    end
    % end switch chAlgorithm
    
    length = orderfields(length);
% Return as matrices/vectors, not as struct
else
    length = vCableLength;

    %%% Assign all the other, optional output quantities
    % Second output argument is the matrix of normalized cable direction vectors
    if nargout >= 2
        varargout{1} = aCableUnitVector;
    end

    % Third output 
    if nargout >= 3
        % For the advanced algorithms we are returning the wrapping angles
        switch chAlgorithm
            case 'pulley'
                varargout{2} = aPulleyAngles;
            otherwise
        end
    end
    % end if nargout >= 3
end
% end if strcmp(chReturnStruct, 'on')


end


function out = inCharToValidArgument(in)

switch lower(in)
    case {'on', 'yes', 'please'}
        out = 'on';
    case {'off', 'no', 'never'}
        out = 'off';
    otherwise
        out = 'off';
end
% end ```switch lower(in)```

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
