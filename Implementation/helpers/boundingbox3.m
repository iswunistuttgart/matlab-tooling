function [Box, Traversal] = boundingbox3(X, Y, Z, varargin)
% BOUNDINGBOX3 Calculates the 3D bounding box for the given points
%  
%   Box = BOUNDINGBOX3(X, Y, Z) calculates the bounding box for the given points
%   in X, Y, Z position and returns a matrix of size 3x8 where each column is
%   one of the bounding box' corners.
%   Basically, what BOUNDINGBOX3 does is take all the mins and max' from the
%   values of X, Y, and Z and assigns them properly into box.
%
%   [Box, Traversal] = BOUNDINGBOX3(X, Y, Z) also returns the array of
%   traversals which relates to the corners of BOX to get a full patch
%   
%   Inputs:
%   
%   X: Vector or matrix of points on the YZ-plane
%   
%   Y: Vector or matrix of points on the XZ-plane
%
%   Z: Vector or matrix of points on the XY-plane
%
%   Outputs:
%
%   BOX: Matrix of 3x8 entries that correspond the corners of the bounding box
%   with their relation as given in the second output parameter TRAVERSAL
%
%   TRAVERSAL: Matrix of 6 rows of size 3 where each row corresponds to one
%   traversal of the bounding box BOX for using the patch command
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-04-01
% Changelog:
%   2016-04-01
%       * Update file-information block
%       * Update help documentation
%       * Update assertion
%   2014-01-21
%       * Initial release



%% Check and prepare the arguments
% X must not be a scalar and must be a vector
assert(~isscalar(X))
assert(isvector(X));
% Y must not be a scalar and must be a vector
assert(~isscalar(Z))
assert(isvector(Z));
% Z must not be a scalar and must be a vector
assert(~isscalar(Y))
assert(isvector(Y));
% X, Y, and Z must have the same number of elements
assert(numel(X) == numel(Y) && numel(Y) == numel(Z));



%% Do the magic!
% First, get all minimum and maximum values of X, Y, and Z
vMinVals = min([min(X), min(Y), min(Z)]);
vMaxVals = max([max(X), max(Y), max(Z)]);

% Holds our output
aBoundingBox = zeros(8, 3);

% The first set of points will be all points on the lower side of the cube
aBoundingBox(1, :) = [vMinVals(1), vMinVals(2), vMinVals(3)];
aBoundingBox(2, :) = [vMaxVals(1), vMinVals(2), vMinVals(3)];
aBoundingBox(3, :) = [vMaxVals(1), vMaxVals(2), vMinVals(3)];
aBoundingBox(4, :) = [vMinVals(1), vMaxVals(2), vMinVals(3)];
% Second half of points will be all points on the upper side of the cube
aBoundingBox(5, :) = [vMinVals(1), vMinVals(2), vMaxVals(3)];
aBoundingBox(6, :) = [vMaxVals(1), vMinVals(2), vMaxVals(3)];
aBoundingBox(7, :) = [vMaxVals(1), vMaxVals(2), vMaxVals(3)];
aBoundingBox(8, :) = [vMinVals(1), vMaxVals(2), vMaxVals(3)];

% This allows to use results of boundingbox3 as input to patch('Vertices', box, 'Faces', traversal)
aTraversal = [1, 2, 3, 4; ...
    5, 6, 7, 8; ...
    1, 2, 6, 5; ...
    2, 3, 7, 6; ...
    3, 4, 8, 7; ...
    4, 1, 5, 8];



%% Assign output quantities
% Main output is the bounding box
Box = aBoundingBox;

% First optional output is the array of traversals
if nargout > 1
    Traversal = aTraversal;
end


end
