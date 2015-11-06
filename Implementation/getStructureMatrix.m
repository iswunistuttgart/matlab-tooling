function [StructureMatrix, varargout] = getStructureMatrix(MotionPattern, CableAttachments, CableVectors, varargin)
% GETSTRUCTUREMATRIX(CableAttachments, CableVectors) gets the structure matrix
%   for the given cable attachment and vector combination
%   
%   STRUCTUREMATRIX = GETSTRUCTUREMATRIX(CABLEATTACHMENTS, CABLEVECTORS)
%   calculates the structure matrix for the given combination of cable
%   attachment points and cable vectors (which can come from any 'inverse
%   kinematics' algorithm. This performs calculation of the structure matrix
%   according to a non-rotated platform. In case the platform is rotated, you
%   need to provide its rotation as well (see below).
%
%   STRUCTUREMATRIX = GETSTRUCTUREMATRIX(CABLEATTACHMENTS, CABLEVECTORS, 
%   ROTATION) also takes into account the rotation of the platform to determine
%   the correct entries of the structure matrix.
%
%   Inputs:
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
%   
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-06-25
% Changelog:
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
parse(ip, MotionPattern, CableAttachments, CableVectors, varargin{:});



%% Parse variables so we can use them natively
chMotionPattern = ip.Results.MotionPattern;
aCableAttachments = ip.Results.CableAttachments;
aCableVectors = ip.Results.CableVectors;
aRotation = ip.Results.Rotation;
chReturnStruct = inCharToValidArgument(ip.Results.ReturnStruct);



%% Do the magic
switch chMotionPattern
    case '2T'
        aStructureMatrix = algoStructureMatrix_2T(aCableAttachments, aCableVectors);
    case '3T'
        aStructureMatrix = algoStructureMatrix_3T(aCableAttachments, aCableVectors);
    case '1R2T'
        aStructureMatrix = algoStructureMatrix_1R2T(aCableAttachments, aCableVectors, aRotation);
    case '3R3T'
        aStructureMatrix = algoStructureMatrix_3R3T(aCableAttachments, aCableVectors, aRotation);
    otherwise
        error('Unsupported or unknown motion pattern');
end



%% Assign output quantities
% Struct requested as return value?
if strcmp(chReturnStruct, 'on')
    StructureMatrix = struct();
    
    StructureMatrix.StructureMatrix = aStructureMatrix;
    
    StructureMatrix = orderfields(StructureMatrix);
% No struct as return value
else
    StructureMatrix = aStructureMatrix;
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
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
