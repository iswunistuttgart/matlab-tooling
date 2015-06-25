function StructureMatrix = algoStructureMatrix_3R3T(CableAttachments, CableVectors, Rotation)
% ALGOSTRUCTUREMATRIX - Calculate the structure matrix for the given cable
%   attachment points and cable vectors of a 3R3T cable robot
% 
%   STRUCTUREMATRIX = ALGOSTRUCTUREMATRIX(CABLEATTACHMENTS, CABLEVECTORS)
%   determines the structure matrix for the given cable attachment points
%   and the given cable vectors. Cable vectors can but must not be a matrix
%   of normalized vectors
%   
%   Inputs:
%   
%   CABLEATTACHMENTS: Matrix of cable attachment points w.r.t. the
%   platforms coordinate system. Each attachment point has its own column
%   and the rows are the x, y, and z-value, respectively, i.e.,
%   CABLEATTACHMENTS must be a matrix of 3xM values. The number of cables
%   i.e., N, must match the number of winches in WINCHPOSITIONS (i.e., its
%   column count) and the order must match the real linkage of cable
%   attachment on the platform to winch.
%   
%   CABLEVECTORS: Matrix of cable direction vectors from CABLEATTACHMENTS
%   to the winch attachment point. Must not be a matrix of normalized
%   values, however, must be a 3xM matrix of coordinates [x, y, z]'
% 
%   Outputs:
% 
%   STRUCTUREMATRIX: Structure matrix A' for the given attachment points
%   given the cable vectors. Is of size 6xM
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-06-25
% Changelog:
%   2015-06-25:
%       * Make this function only return the structure matrix for a 3R3T cable
%       robot
%   2015-06-13:
%       * Add optional argument for the current rotation to method
%   2015-04-22:
%       * Initial release



%% Parse Variables
% Get number of wires
nNumberOfWires = size(CableAttachments, 2);
% Create the structure matrix's matrix
aStructureMatrix = zeros(6, nNumberOfWires);
% Keeping variable names consistent
aCableVectors = CableVectors;
aCableAttachments = CableAttachments;

% Rotation may be given or not, so check for its existence
if nargin >= 3
    aRotation = Rotation;
% Platform rotation defaults to the "zero"-rotation if not provided
else
    aRotation = eye(3);
end



%% Create the structure matrix
% Loop over the wires being placed into the columns of A'
for iUnit = 1:nNumberOfWires
    % Ensure the cable vector is normalized
    if norm(aCableVectors(:,iUnit)) ~= 1
        aCableVectors(:,iUnit) = aCableVectors(:,iUnit)./norm(aCableVectors(:,iUnit));
    end
    
    % Each column of A' is [u; cross((R*b), u)]';
    aStructureMatrix(1:3,iUnit) = aCableVectors(:,iUnit);
    aStructureMatrix(4:6,iUnit) = cross(aRotation*aCableAttachments(:,iUnit), aCableVectors(:,iUnit));
end



%% Assign output quantities
StructureMatrix = aStructureMatrix;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
