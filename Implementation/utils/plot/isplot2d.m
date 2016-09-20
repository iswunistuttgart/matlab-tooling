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
% Date: 2016-09-20
% Changelog:
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

% Stores the azimuths and elevations of each axis
vAzimuths = zeros(numel(haTarget), 1);
vElevations = zeros(numel(haTarget), 1);



%% Checking
% Loop over all given axes
for iAx = 1:numel(haTarget)
    % Get azimuth and elevation of current viewport
    [vAzimuths(iAx), vElevations(iAx)] = view(haTarget(iAx));
end

% If the azimuth is 0+/-n*90 or the elevation is 0+/-n*90, it is no 3D plot
% bIsPlot2d = isequaln(rem([vAzimuths, vElevations], 90), [0,0]);
bIsPlot2d = all(rem([vAzimuths, vElevations], 90) == repmat([0, 0], numel(haTarget), 1), 2);



%% Output assignment
res = bIsPlot2d;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
