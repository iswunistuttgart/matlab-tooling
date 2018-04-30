function center_cos(varargin)
% CENTER_COS centers the coordinate system at [0, 0] i.e., moves the axes
% locations
%
%   CENTER_COS() moves the coordinate system from the left and bottom side of
%   the plot to be located at the center (0,0) of the plot.
%
%   CENTER_COS(C) moves the coordinate system to be centered at (C) which must
%   be a 1x2 or 2x1 vector
%
%   CENTER_COS(ax, ...) applies it to the given axes.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-01-03
% Changelog:
%   2017-01-03
%       * Initial release



%% Define the input parser
ip = inputParser;

% Anchors. Numeric. 2D array. 3 Rows
valFcn_Center = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector', 'numel', 2, 'finite', 'nonsparse'}, mfilename, 'Center');
addOptional(ip, 'Center', valFcn_Center);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    [haTarget, args, ~] = axescheck(varargin{:});
    
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Do your code magic here
% Get a valid axes handle
haTarget = newplot(haTarget);
% Old hold state
lOldHold = ishold(haTarget);
% Tell figure to add next plots
hold(haTarget, 'on');

% Move the axis locations to the origin
haTarget.XAxisLocation = 'origin';
haTarget.YAxisLocation = 'origin';

% Reset hold state of old axes if previously not set
if lOldHold
    hold(haTarget, 'off');
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
