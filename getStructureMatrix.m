function [StructureMatrix, varargout] = getStructureMatrix(CableAttachments, CableVectors, varargin)
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
%   
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-05-10
% Changelog:
%   2015-05-10: Initial release



%% Create an input parser
% Input parse to easily parse input arguments
ip = inputParser;

%%% This fills in the parameters for the function
% We need the b_i's
valFcn_CableAttachmens = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'ncols', size(CableVectors, 2)}, mfilename, 'CableAttachments');
addRequired(ip, 'CableAttachments', valFcn_CableAttachmens);

% We need the cable (unit) vectors
valFcn_CableVectors = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'ncols', size(CableAttachments, 2)}, mfilename, 'CableVectors');
addRequired(ip, 'CableVectors', valFcn_CableVectors);

% Rotation of the platform is needed to transform the b_i into the global frame
valFcn_Rotation = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'ncols', 3}, mfilename, 'Rotation');
addOptional(ip, 'Rotation', eye(3), valFcn_Rotation);

% Configuration for the input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, CableAttachments, CableVectors, varargin{:});



%% Parse variables so we can use them natively
mCableAttachments = ip.Results.CableAttachments;
mCableVectors = ip.Results.CableVectors;
mRotation = ip.Results.Rotation;



%% Do the magic
mStructureMatrix = algoStructureMatrix(mRotation*mCableAttachments, mCableVectors);



%% Assign output quantities
StructureMatrix = mStructureMatrix;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
