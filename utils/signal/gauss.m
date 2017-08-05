function GF = gauss(X, varargin)
% GAUSS calculates the 1D gaussian function along X
%
%   GF = GAUSS(X)
%
%   GS = GAUSS(X, A)
%
%   GS = GAUSS(X, A, SIGMAX)
%
%   GS = GAUSS(X, 'Name', 'Value', ...) allows setting optional inputs
%   using name/value pairs.
%
%   Optional Inputs -- specified as parameter value pairs
%
%   A               Amplitude.
%
%   SigmaX          Spread along X.
%
%   X0              Center of gaussian curve.
%
%   Inputs:
%
%   X                   1xM vector or NxM matrix of grid along X
%
%   Outputs:
%
%   GF                  Gaussian function along the 1xM grid



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-05-15
% Changelog:
%   2017-05-15
%       * Initial release



%% Do your code magic here
% Set defaults
stDefaults = struct();
stDefaults.A = 1;
stDefaults.SigmaX = 1;
stDefaults.X0 = 0;



%% Define the input parser
ip = inputParser;

% X
valFcn_X = @(x) validateattributes(x, {'numeric'}, {'2d', 'nonempty', 'nondecreasing', 'nonsparse', 'finite'}, mfilename, 'X');
addRequired(ip, 'X', valFcn_X);

% A
valFcn_A = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'nonsparse', 'finite'}, mfilename, 'A');
addOptional(ip, 'A', stDefaults.A, valFcn_A);

% SigmaX
valFcn_SigmaX = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'nonsparse', 'finite'}, mfilename, 'SigmaX');
addOptional(ip, 'SigmaX', stDefaults.SigmaX, valFcn_SigmaX);

% X0
valFcn_X0 = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'nonsparse', 'finite'}, mfilename, 'X0');
addOptional(ip, 'X0', stDefaults.X0, valFcn_X0);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    args = [{X}, varargin];
    
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results
% Grid along X
vGrid_X = ip.Results.X;
% Amplitude
dAmplitude = ip.Results.A;
if isempty(dAmplitude)
    dAmplitude = stDefaults.A;
end
% Sigma of Gaussian function along axes
dSigma_X = ip.Results.SigmaX;
if isempty(dSigma_X)
    dSigma_X = stDefaults.SigmaX;
end
% Offset along the axis
dZero_X = ip.Results.X0;
if isempty(dZero_X)
    dZero_X = stDefaults.X0;
end



%% Do your code magic here

% Determine the Guassian
GF = dAmplitude.*exp(-( ( vGrid_X - dZero_X ).^2./(2*dSigma_X^2) ) );


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
