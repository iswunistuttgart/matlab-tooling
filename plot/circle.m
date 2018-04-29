function varargout = circle(Center, Radius, varargin)
% CIRCLE draws a circle of specified radius
%
%   CIRCLE(CENTER, RADIUS) draws a circle located at CENTER with radius of RHO.
%
%   CIRCLE(CENTER, RADIUS, ...) passes additional arguments that are not processed
%   by this function to the underlying patch command for drawing the circle
%   object. This allows user-defined plot data to be easily appended like e.g.,
%       CIRLCE(1, [0;0], 'FaceColor', 'red', 'EdgeColor', 'green');
%
%   CIRCLE(AX, ...) plots into the given axes.
%
%   H = CIRCLE(...) returns the handle of the patch graphics object.
%
%   CIRCLE('Name', 'Value', ...) allows setting optional inputs using name/value
%   pairs.
%
%   Inputs:
%
%   RADIUS              1xN array of radius of each circle to draw
%
%   CENTER              2xN array of positions of each circle to draw
%
%   Optional Inputs -- specified as parameter value pairs
%
%   See also: PATCH



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-09-09
% Changelog:
%   2017-09-09
%       * Change order of arguments to (CENTER, RADIUS)
%       * Update to allow drawing more than one circle at a time
%   2017-01-05
%       * Initial release



%% Define the input parser
ip = inputParser;

% Parse possibly given axes
varargin = [{Center}, {Radius}, varargin];
[haTarget, args, ~] = axescheck(varargin{:});

% Extract center from the axes-cleaned cell
Center = args{1};

% Count circles
nCircles = size(Center, 2);

% Center: numeric; 2d, nrows 2, ncols N, finite, nonempty, nonnan, nonsparse
valFcn_Center = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 2, 'finite', 'nonempty', 'nonnan', 'nonsparse'}, mfilename, 'Center');
addRequired(ip, 'Center', valFcn_Center);

% Radius: numeric; row, finite, nonempty, nonnan, nonsparse
valFcn_Radius = @(x) validateattributes(x, {'numeric'}, {'vector', 'row', 'ncols', nCircles, 'positive', 'finite', 'nonempty', 'nonnan', 'nonsparse'}, mfilename, 'Radius');
addRequired(ip, 'Radius', valFcn_Radius);

% Samples: numeric; vector, finite, nonnan, nonsparse, positive
valFcn_Samples = @(x) validateattributes(x, {'numeric'}, {'vector', 'nrows', 1, 'ncols', nCircles, 'nonempty', 'positive', 'nonnan', 'nonsparse'}, mfilename, 'Samples');
addParameter(ip, 'Samples', 500, valFcn_Samples);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results
% Center location
aCenter = ip.Results.Center;
% Number of circles
nCircles = size(aCenter, 2);
% Radius
vRadius = ip.Results.Radius;
% Sample points
vSamples = ip.Results.Samples;
if numel(vSamples) ~= nCircles
    vSamples = repmat(vSamples, 1, nCircles);
end
% Additional plot styles for the circle are the ones we didn't match with the IP
stLinespec = ip.Unmatched;
ceLinespec = {};
% Convert the structure of possible linespecs to a proper cell
ceFields_Linespec = fieldnames(stLinespec);
if numel(ceFields_Linespec)
    ceLinespec = cell(1, numel(ceFields_Linespec)*2, 1);
    ceLinespec(1:2:end) = ceFields_Linespec;
    ceLinespec(2:2:end) = struct2cell(stLinespec);
end
loIsColor = strcmpi(ceLinespec, 'color');
loIsEdgeColor = strcmpi(ceLinespec, 'edgecolor');
if any(loIsColor)
    ceLinespec{loIsColor} = 'FaceColor';
    if ~any(loIsEdgeColor)
        ceLinespec{end+1} = 'EdgeColor';
        ceLinespec{end+1} = ceLinespec{find(loIsColor) + 1};
    end
end
% Get a valid axes handle
haTarget = newplot(haTarget);
% Old hold state
lOldHold = ishold(haTarget);
% Tell figure to add next plots
hold(haTarget, 'on');



%% Draw the circle
% Linear space of the angle
ceThetas = arrayfun(@(s) linspace(0, 2*pi, s), vSamples, 'UniformOutput', false);

% Create a placeholder object for all drawn circles
hpCircles = gobjects(nCircles, 1);

% Draw the circles
for iCircle = 1:nCircles
    hpCircles(iCircle) = patch(haTarget, aCenter(1,iCircle) + vRadius(iCircle)*cos(ceThetas{iCircle}), aCenter(2,iCircle) + vRadius(iCircle)*sin(ceThetas{iCircle}), 0);
end

% Set user-defined plot styles?
if ~isempty(ceLinespec)
    set(hpCircles, ceLinespec{:});
end



%% Cleanup
% Draw the figure
drawnow

% Reset the old hold state if it wasn't set
if ~lOldHold
    hold(haTarget, 'off');
end



%% Assign output quantities
% Return the plot handle?
if nargout > 0
    varargout{1} = hpCircles;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
