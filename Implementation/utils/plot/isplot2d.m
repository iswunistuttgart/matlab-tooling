function res = isplot2d(varargin)
% ISPLOT2D Check the given axes against being a 2D plot i.e., created by plot()
% 
%   ISPLOT2D() checks the current axes against being a 2D plot
% 
%   ISPLOT2D(AXES) checks the given axes against being a 2D plot
%
%   Basically, what this function does is exam all current axes childrens
%   whether they have valid ZData. If any of them has it will return false
%   
%   Inputs:
%   
%   AXES: Use axes AXES instead of current axes to check



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-13
% Changelog:
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
    throw(MException(me.identifier, escapepath(me.message)));
end



%% Process inputs
% Get the axes handle
haTarget = ip.Results.Axis;
if ~ishandle(haTarget)
    haTarget = gca;
end



%% Checking
% Get azimuth and elevation of current viewport
[az, el] = view(haTarget);

% If the azimuth is 0+/-n*90 or the elevation is 0+/-n*90, it is no 3D plot
bIsPlot2d = isequaln(rem([az, el], 90), [0,0]);



%% Output assignment
res = bIsPlot2d;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
