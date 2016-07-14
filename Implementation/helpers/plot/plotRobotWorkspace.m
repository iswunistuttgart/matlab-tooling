function [varargout] = plotRobotWorkspace(XData, YData, ZData, varargin)



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-07-14
% Changelog:
%   2016-07-14
%       * Update IP with more experience
%       * Wedge out param-value pairs to only the needed ones
%       * Introduce option 'LabelSpec'
%   2016-04-01
%       * Initial release



%% Preprocess inputs (allows to have the axis defined as first argument)
% By default we don't have any axes handle
haTarget = false;
% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && isallaxes(XData)
    haTarget = XData;
    XData = YData;
    YData = ZData;
    ZData = varargin{1};
    varargin = varargin(2:end);
end



%% Define the input parser
ip = inputParser;

% Require: XData. Must be a 3xN array
valFcn_XData = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3}, mfilename, 'XData');
addRequired(ip, 'XData', valFcn_XData);

% Require: YData. Must be a 3xN array
valFcn_YData = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3}, mfilename, 'YData');
addRequired(ip, 'YData', valFcn_YData);

% Require: ZData. Must be a 3xN array
valFcn_ZData = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3}, mfilename, 'ZData');
addRequired(ip, 'ZData', valFcn_ZData);

% Optional 1: HullSpec. One-dimensional or two-dimensional cell-array
valFcn_HullSpec = @(x) validateattributes(x, {'cell'}, {'nonempty', 'row'}, mfilename, 'HullSpec');
addParameter(ip, 'HullSpec', {}, valFcn_HullSpec);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    parse(ip, XData, YData, ZData, varargin{:});
catch me
    throw(MException(me.identifier, me.message));
end



%% Parse Variables
% XData of patch
aXData = ip.Results.XData;
% YData of patch
aYData = ip.Results.YData;
% ZData of patch
aZData = ip.Results.ZData;
% Patch specifications
ceHullSpec = ip.Results.HullSpec;

% Ensure the handle hAxes is a valid handle. If none given, create a new
% figure handle, otherwise select the given one to be the active axes
% handle
if ~ishandle(haTarget)
    haTarget = gca;
    % If the current axis is a new i.e., blank axis i.e., has no children, we
    % will rotate it into the default 3D viewport
    if isempty(haTarget.Children)
        view([-37.5, 30]);
    end
end



%% Plotting it all

% Do not overwrite the current axis content but append
hold(haTarget, 'on');
% Plot the patch of X, Y, Z data with solid color
hpHull = patch(aXData, aYData, aZData, 1);

% Set properties on the patch?
if ~isempty(ceHullSpec)
    set(hpHull, ceHullSpec{:});
end
% Make sure the figure is being drawn before anything else is done
drawnow;



%% Assign output quantities
% Return the axes handle as the first output
if nargout > 0
    varargout{1} = haTarget;
end

% Return the patch object as the second output argument
if nargout > 1
    varargout{2} = hpHull;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
