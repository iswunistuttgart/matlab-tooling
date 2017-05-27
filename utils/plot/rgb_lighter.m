function lighter = rgb_lighter(rgb, factor, varargin)
% RGB_LIGHTER 
%
%   Inputs:
%
%   RGB                 Description of argument RGB
%
%   FACTOR              Description of argument FACTOR
%
%   Outputs:
%
%   LIGHTER             Description of argument LIGHTER



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-02-24
% Changelog:
%   2017-02-24
%       * Initial release



%% Define the input parser
ip = inputParser;

% Required: RGB; numeric; 2d, ncols 3, non-empty, non-sparse, non-negative, <=
% 1,
valFcn_Rgb = @(x) validateattributes(x, {'numeric'}, {'2d', 'nonempty', 'ncols', 3, 'nonsparse', 'nonnegative', '<=', 1}, mfilename, 'rgb');
addRequired(ip, 'rgb', valFcn_Rgb);

% Required: factor; numeric; scalar, non-empty, non-sparse, non-negative, <= 1,
valFcn_Factor = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'scalar', 'nonsparse', 'nonnegative', '<=', 1}, mfilename, 'factor');
addRequired(ip, 'factor', valFcn_Factor);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    args = [{rgb}, {factor}, varargin];
    
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results
% Values to transform
aRgb = ip.Results.rgb;
% Factor to scale each color
dFactor = ip.Results.factor;


%% Do your code magic here

lighter = fix(aRgb  + (1 - aRgb)*dFactor);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
