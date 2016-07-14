function [StructureMatrix, NullSpace] = structureMatrix(MotionPattern, CableAttachments, CableVectors, varargin)
% STRUCTUREMATRIX gets the structure matrix for the given robot
%   
%   STRUCTUREMATRIX = STRUCTUREMATRIX(MOTIONPATTERN, CABLEATTACHMENTS,
%   CABLEVECTORS) calculates the structure matrix for the given combination of
%   cable attachment points and cable vectors (which can come from any 'inverse
%   kinematics' algorithm. This performs calculation of the structure matrix
%   according to a non-rotated platform. In case the platform is rotated, you
%   need to provide its rotation as well (see below).
%
%   STRUCTUREMATRIX = STRUCTUREMATRIX(MOTIONPATTERN, CABLEATTACHMENTS,
%   CABLEVECTOR, ROTATION) also takes into account the rotation of the platform
%   to determine the correct entries of the structure matrix.
%
%   STRUCTUREMATRIX = STRUCTUREMATRIX(MOTIONPATTERN, CABLEATTACHMENTS,
%   CABLEVECTOR, ROTATION, 'ReturnStruct', 'on') will return the result as a
%   structure rather than a matrix. Only works with one output argument then
%
%   Inputs:
%
%   MOTIONPATTERN: Required name of the motion pattern to use for the underlying
%   determination of the structure matrix. Supported motion patterns are
%
%       '2T'
%       '3T'
%       '1R2T'
%       '3R3T'
%
%   Motion pattern 1T is quite simple while 2R3T is too specific (which are the
%   two axes that you allow rotation about?)
%   
%   CABLEATTACHMENTS: A matrix of the cable attachment points w.r.t. the
%   platform's coordinate system given as a 3xM matrix where each column is a
%   cable attachment point and the rows are the x-, y-, and z-coordinate
%   thereof, respectively.
%   
%   CABLEVECTORS: Matrix of the cable (unit) vectors pointing in the direction
%   of each cable. Must be given as a 3xM matrix where each column is a cable
%   (unit) vector and the rows are the x-, y-, and z-direction, respectively.
%   If not given as a unit vector, will automatically be normalized.
%
%   ROTATION: Matrix of the rotation of the platform given as a 3x3 matrix
%   either from Yaw-Pitch-Roll, Tait-Bryan angles, or other rotation formalisms.
%   If not provided, a non-rotated platform is assumed i.e., ROTATION = eye(3).
%   
%   'ReturnStruct': Allows to have just one return value which then is a struct
%   of all the available variables as per the algorithm. Can be set to any valid
%   string of 'off', 'no', 'on', 'yes', 'please'. Only 'on', 'yes', and 'please'
%   will actually return a struct then
%
%   Outputs:
%
%   STRUCTUREMATRIX: The determined structure matrix At given the cable unit
%   vectors and rotation
%
%   NULLSPACE: Nullspace of the structure matrix At satisfying At*NULLSPACE = 0 
%



%% File Information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-07-14
% Changelog:
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%   2016-03-30
%       * Add missing input paramter MOTIONPATTERN
%       * Add return option NULLSPACE
%       * Update help doc
%   2016-03-29
%       * Code cleanup
%   2015-06-25
%       * Add option 'MotionPattern'
%   2015-06-19
%       * Add option 'ReturnStruct'
%   2015-05-10
%       * Initial release



%% Create an input parser
% Input parse to easily parse input arguments
ip = inputParser;

%%% This fills in the parameters for the function
% We need the motion pattern
valFcn_MotionPattern = @(x) any(validatestring(upper(x), {'2T', '3T', '1R2T', '3R3T'}, mfilename, 'MotionPattern'));
addRequired(ip, 'MotionPattern', valFcn_MotionPattern);

% We need the b_i's
valFcn_CableAttachmens = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'ncols', size(CableVectors, 2)}, mfilename, 'CableAttachments');
addRequired(ip, 'CableAttachments', valFcn_CableAttachmens);

% We need the cable (unit) vectors
valFcn_CableVectors = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'ncols', size(CableAttachments, 2)}, mfilename, 'CableVectors');
addRequired(ip, 'CableVectors', valFcn_CableVectors);

% Rotation of the platform is needed to transform the b_i into the global frame
valFcn_Rotation = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'ncols', 3}, mfilename, 'Rotation');
addOptional(ip, 'Rotation', eye(3), valFcn_Rotation);

% Return a struct as the only return value of this function?
valFcn_ReturnStruct = @(x) any(validatestring(lower(x), {'off', 'no', 'on', 'yes'}, mfilename, 'ReturnStruct'));
addParameter(ip, 'ReturnStruct', 'off', valFcn_ReturnStruct);

% Configuration for the input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    parse(ip, MotionPattern, CableAttachments, CableVectors, varargin{:});
catch me
    throw(MException(me.identifier, me.message));
end



%% Parse variables so we can use them natively
% Get the motion pattern
chMotionPattern = ip.Results.MotionPattern;
% Cable attachment points
aCableAttachments = ip.Results.CableAttachments;
% Cable (unit) vectors
aCableVectors = ip.Results.CableVectors;
% Rotation matrix
aRotation = ip.Results.Rotation;
% And whether to return as a struct or not
chReturnStruct = inCharToValidArgument(ip.Results.ReturnStruct);



%% Post-processing of input
% If the return value shall be a struct, then we only allow one return value
if strcmp('on', chReturnStruct)
    nargoutchk(0, 1);
end



%% Do the magic
switch chMotionPattern
    case '2T'
        [aStructureMatrix, aNullSpace] = algoStructureMatrix_2T(aCableAttachments, aCableVectors);
    case '3T'
        [aStructureMatrix, aNullSpace] = algoStructureMatrix_3T(aCableAttachments, aCableVectors);
    case '1R2T'
        [aStructureMatrix, aNullSpace] = algoStructureMatrix_1R2T(aCableAttachments, aCableVectors, aRotation);
    case '3R3T'
        [aStructureMatrix, aNullSpace] = algoStructureMatrix_3R3T(aCableAttachments, aCableVectors, aRotation);
    otherwise
        error('Unsupported or unknown motion pattern');
end



%% Assign output quantities
% Struct requested as return value?
if strcmp('on', chReturnStruct)
    StructureMatrix = struct();
    
    StructureMatrix.StructureMatrix = aStructureMatrix;
    StructureMatrix.NullSpace = aNullSpace;
    
    StructureMatrix = orderfields(StructureMatrix);
% No struct as return value
else
    % First output: structure matrix; required
    StructureMatrix = aStructureMatrix;
    
    % Second output: null space; optional
    if nargout > 1
        NullSpace = aNullSpace;
    end
end
% end if strcmpi(chReturnStruct, 'on');


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
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
