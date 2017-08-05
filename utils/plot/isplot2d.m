function res = isplot2d(varargin)
% ISPLOT2D Check the given axes against being a 2D plot i.e., created by plot()
% 
%   ISPLOT2D() checks the current axes against being a 2D plot.
% 
%   ISPLOT2D(AXES) checks the given axes against being a 2D plot.
%
%   Basically, what this function does is exam all given or current axes have a
%   view azimuth and elevation that equals to [90, 90]*n with n being a real
%   integer i.e, (0, 1, ...) and negative thereof. Seems to be the safest way to
%   check for 2D plots.
%   
%   Inputs:
%   
%   AXES:       Mx1 array of axes to check for being 2D.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-08-01
% Changelog:
%   2017-08-01
%       * Fix error in function that failed for passing multiple plot axes as
%       argument
%   2016-12-23
%       * Speed up process by making use of `axis` which returns a 1x4 vector if
%       the given axis is 2D and a 1x6 vector otherwise
%   2016-09-20
%       * Add support for checking multiple axes at once
%   2016-09-13
%       * Update to just use the [az,el] check which seems to be the safest
%       * Update to new file information header
%   2016-03-25
%       * Initial release



%% Define the input parser
ip = inputParser;

% Optional: Axis. matlab.graphics.axis.axes
valFcn_Axis = @(x) validateattributes(x, {'matlab.graphics.axis.Axes'}, {'vector', 'nonempty'}, mfilename, 'Axis');
addOptional(ip, 'Axis', false, valFcn_Axis);

% Parse the provided inputs
try
    parse(ip, varargin{:});
catch me
    throwAsCaller(me);
end



%% Process inputs
% Get the axes handle
haTarget = ip.Results.Axis;
if ~ishandle(haTarget)
    haTarget = gca;
end



%% Checking
% Loop over all given axes
% for iAx = 1:numel(haTarget)
%     vAxisNumel(iAx) = numel(axis(haTarget(iAx)));
% end

% The plot is a 2D plot if the numel of its axis size is 4, otherwise it is a 3D
% plot
res = arrayfun(@(x) numel(x) == 4, axis(haTarget));


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
