function StructureMatrix = algoStructureMatrix(CableAttachments, CableVectors, varargin)
% ALGOSTRUCTUREMATRIX - Calculate the structure matrix for the given cable
%   attachment points and cable vectors
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
% Date: 2015-04-22
% Changelog:
%   2015-04-22: Initial release



%% Parse Variables
% Get number of wires
iNumberOfWires = size(CableAttachments, 2);
% Create the structure matrix's matrix
mStructureMatrix = zeros(6, iNumberOfWires);
% Keeping variable names consistent
mCableVectors = CableVectors;
mCableAttachments = CableAttachments;



%% Create the structure matrix
% Loop over the wires being placed into the columns of A'
for iUnit = 1:iNumberOfWires
    % Ensure the cable vector is normalized
    if norm(mCableVectors(:, iUnit)) ~= 1
        mCableVectors(:, iUnit) = mCableVectors(:, iUnit)./norm(mCableVectors(:, iUnit));
    end
    
    % Each column of A' is [u, cross((R*b), u)]';
    mStructureMatrix(:, iUnit) = [mCableVectors(:, iUnit); ...
                                    cross(mCableAttachments(:, iUnit), mCableVectors(:, iUnit))];
end



%% Assign output quantities
StructureMatrix = mStructureMatrix;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
