function res = isplot3d(Axis, varargin)
% ISPLOT3D Check the given axes against being a 3D plot i.e., created by plot3()
% 
%   ISPLOT3D() checks the current axes against being a 3D plot
% 
%   ISPLOT3D(AXES) checks the given axes against being a 3D plot
%
%   Basically, what this function does is exam all current axes childrens
%   whether they have valid ZData. If any of them has it will return false
%   
%   Inputs:
%   
%   AXES: Use axes AXES instead of current axes to check
%
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-07-14
% Changelog:
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%   2016-04-01
%       * Update checking for proper plot types. This should be a more fail-safe
%       code now
%   2016-03-25
%       * Initial release



%% Pre-process inputs
if nargin == 0
    Axis = gca;
end



%% Define the input parser
ip = inputParser;

% Require: Time column vector
% Time must be an increasing column vector
valFcn_Axis = @(x) validateattributes(x, {'matlab.graphics.axis.Axes'}, {'vector', 'nonempty'}, mfilename, 'Axis');
addRequired(ip, 'Axis', valFcn_Axis);

% Parse the provided inputs
try
    parse(ip, Axis, varargin{:});
catch me
    throw(MException(me.identifier, me.message));
end



%% Process inputs
% Get the axes handle
haAxes = ip.Results.Axis;



%% Local variables
% These plot types are all 3D plots
cePlotTypes3D = {...
    'plot3', 'ezplot3', ... % Line plots
    'pie3', 'bar3', 'bar3h', ... % Pie charts, Bar-plots, and histograms
    'stem3', 'scatter3', ... % Discrete data plots
    'contour3', 'contourslice', ... % Contour plots
    'quiver3', 'streamline', 'streamribbon', 'streamtube', ... % Vector fields
    'surf', 'surfc', 'surfl', 'ezsurf', 'ezsurfc', 'ribbon', 'mesh', 'meshc', 'mehsz', 'waterfall', 'ezmesh', 'ezmeshc', ... % Surface and mesh plots
    'fill3', 'patch', ... % Polygons
    'comet3' % Animation
};



%% Magic
% Try getting all children' types from the axes
try
    ceTypes = get(get(haAxes, 'Children'), 'Type');
    
    bIsPlot3d = any(ismember(ceTypes, cePlotTypes3D));
catch ME
    bIsPlot3d = false;
end

% There are some plot types which can be used for both 2D and 3D plots that's
% why we are going to make a fallback for the check to ensure the view port is
% unequal to anything of [{0,90,180,270}, {0,90,180,270}]
if bIsPlot3d
    % Get azimuth and elevation of current viewport
    [az, el] = view(gca);
    
    % If the azimuth is 0+/-n*90 or the elevation is 0+/-n*90, it is no 3D plot
    bIsPlot3d = all(rem([az, el], 90));
end



%% Assign output quantities
% First and only output
res = bIsPlot3d;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
