function [box, varargout] = boundingbox3(X, Y, Z, varargin)
% BOUNDINGBOX3 Calculates the bounding box for the given points
%  
%   box = BOUNDINGBOX3(X, Y, Z) calculates the bounding box for the given
%   points in X, Y, Z position and returns a matrix of size 3x8 where each
%   column is one of the bounding box' corners.
%   Basically, what BOUNDINGBOX3 does is take all the mins and max' from
%   the values of X, Y, and Z and assigns them properly into box.
%   
%   INPUTS
%       X   Vector or matrix of points on the YZ-plane
%       Y   Vector or matrix of points on the XZ-plane
%       Z   Vector or matrix of points on the XY-plane
%       


%% AUTHOR       : Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
%% DATE         : 2014-01-21
%% REVISION     : 1.0
%% DEVELOPED    : 8.2.0.701 R2013b
%% FILENAME     : boundingbox3.m
%% HISTORY
%   2014-01-21  * File created, full description at top
%%-------------------------------------------------------------------------



%% Check and prepare the arguments
% Only accept vetors or matrices
if ( ~ ( isvector(X) || ismatrix(X) ) )
    throw(MException('PHILIPPTEMPEL:boundingbox3:invalidArgumentFormat', 'Argument ''X'' must be a vector or a matrix, but it''s not'));
end
if ( ~ ( isvector(Y) || ismatrix(Y) ) )
    throw(MException('PHILIPPTEMPEL:boundingbox3:invalidArgumentFormat', 'Argument ''Y'' must be a vector or a matrix, but it''s not'));
end
if ( ~ ( isvector(Z) || ismatrix(Z) ) )
    throw(MException('PHILIPPTEMPEL:boundingbox3:invalidArgumentFormat', 'Argument ''Z'' must be a vector or a matrix, but it''s not'));
end

% Ensure we are working on column vectors
if isrow(X)
    X = X';
end
if isrow(Y)
    Y = Y';
end
if isrow(Z)
    Z = Z';
end

if ( numel(X(:)) ~= numel(Y(:)) || numel(X(:)) ~= numel(Z(:)) || numel(Y(:)) ~= numel(Z(:)) )
    throw(MException('PHILIPPTEMPEL:boundingbox3:invalidArgumentFormat', 'All vectors must have the same size'));
end



%% Do the magic!
% First, get all minimum and maximum values of X, Y, and Z
minVals = min([X(:), Y(:), Z(:)]);
maxVals = max([X(:), Y(:), Z(:)]);

% Holds our output
box = zeros(8, 3);

% The first set of points will be all points on the lower side of the cube
box(1, :) = [minVals(1), minVals(2), minVals(3)];
box(2, :) = [maxVals(1), minVals(2), minVals(3)];
box(3, :) = [maxVals(1), maxVals(2), minVals(3)];
box(4, :) = [minVals(1), maxVals(2), minVals(3)];
% Second half of points will be all points on the upper side of the cube
box(5, :) = [minVals(1), minVals(2), maxVals(3)];
box(6, :) = [maxVals(1), minVals(2), maxVals(3)];
box(7, :) = [maxVals(1), maxVals(2), maxVals(3)];
box(8, :) = [minVals(1), maxVals(2), maxVals(3)];

% This allows to use results of boundingbox3 as input to patch('Vertices', box, 'Faces', traversal)
traversal = [1, 2, 3, 4; ...
    5, 6, 7, 8; ...
    1, 2, 6, 5; ...
    2, 3, 7, 6; ...
    3, 4, 8, 7; ...
    4, 1, 5, 8];



%% Assign output quantities
if nargout >= 2
    varargout{1} = traversal;
end

end
