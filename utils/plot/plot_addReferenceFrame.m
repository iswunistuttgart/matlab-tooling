function plot_addReferenceFrame(varargin)
% PLOT_ADDREFERENCEFRAME Add a frame of reference to the current plot
% 
%   PLOT_ADDREFERENCEFRAME() adds a reference frame with axes coinciding with
%   the Cartesian unit vectors ex, ey, and ez (ez only if 3D plot). The axes
%   will be colored in RGB scheme i.e., ex is red, ey is green and ez is blue.
%   Also, arrowheads will be added to the axes to display the direction of
%   positive axis
%
%   PLOT_ADDREFERENCEFRAME(CENTER) adds reference frame positioned at CENTER
%   which can be a 2D or 3D vector for either a 2D or 3D plot. If a 3D plot is
%   detected yet only a 2D CENTER is given, the third component is set to 0.
%
%   PLOT_ADDREFERENCEFRAME(CENTER, LENGTH) draws reference frame with axes long
%   as defined in LENGTH (defaults to 1). Can be a scalar to scale all axes or a
%   vector of same size as CENTER to scale axes independently.
%
%   PLOT_ADDREFERENCEFRAME(ax, ...) adds reference frame to the given axes.
%
%   PLOT_ADDREFERENCEFRAME('Center', CENTER, ...) sets the Center argument to
%   CENTER.
%
%   PLOT_ADDREFERENCEFRAME('Length', LENGTH, ...) sets the Length argument to
%   LENGTH.
%
%   PLOT_ADDREFERENCEFRAME(CENTER, LENGTH, 'LineSpec', LineSpec) plots the
%   reference frame at CENTER with lengths LENGTH and applies the styles given
%   in cell LineSpec to all drawn lines. Must be a cell array. See QUIVER or
%   QUIVER3 for available series properties.
%
%   PLOT_ADDREFERENCEFRAME(CENTER, LENGTH, 'LineSpecX', LineSpecX) plots the
%   reference frame at CENTER with lengths LENGTH and applies the styles given
%   in cell LineSpecX to the drawn x-axis. See QUIVER or QUIVER3 for available
%   series properties.
%
%   PLOT_ADDREFERENCEFRAME(CENTER, LENGTH, 'LineSpecY', LineSpecY) plots the
%   reference frame at CENTER with lengths LENGTH and applies the styles given
%   in cell LineSpecX to the drawn y-axis. See QUIVER or QUIVER3 for available
%   series properties.
%
%   PLOT_ADDREFERENCEFRAME(CENTER, LENGTH, 'LineSpecZ', LineSpecZ) plots the
%   reference frame at CENTER with lengths LENGTH and applies the styles given
%   in cell LineSpecX to the drawn z-axis. See QUIVER or QUIVER3 for available
%   series properties.
%   
%   Inputs:
%   
%   CENTER: Position at which to place the frame of reference. In case of a 2D
%   plot, a vector of length 2 must be given. For 3D plots, a vector of length 2
%   or 3 can be given - in case it has length 2 the third component will be set
%   to Zero.
%
%   LENGTH: Length of each axis (if given a scalar) or of each axis indiviually
%   if given as a vector of equal length as CENTER.
%
%   See also: QUIVER, QUIVER3



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-08-02
% Changelog:
%   2016-08-02
%       * Change to using ```axescheck``` and ```newplot```
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%   2016-03-30
%       * Code cleanup
%   2016-03-29
%       * Fix length of axes arrows to be the specified length: last argument
%       to quiver/quiver3 before the line specs is the scaling factor. Setting
%       this to zero causes the arrow to be drawn at the desired length.
%   2016-03-24
%       * Initial release



%% Define the input parser
ip = inputParser;

% Optional first: AtPoint which will be the location of where the reference
% frame will be plotted at
valFcn_Center = @(x) validateattributes(x, {'numeric'}, {'vector', 'nonempty'}, mfilename, 'Center');
addOptional(ip, 'Center', 0, valFcn_Center);

% Optional second: AtPoint which will be the location of where the reference
% frame will be plotted at
valFcn_AxisLength = @(x) validateattributes(x, {'numeric'}, {'vector', 'nonempty'}, mfilename, 'Length');
addOptional(ip, 'Length', 1.1, valFcn_AxisLength );

% Allow the axes to have user-defined spec
valFcn_LineSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'LineSpec');
addOptional(ip, 'LineSpec', {}, valFcn_LineSpec);

% Allow the x-axis to have user-defined spec
valFcn_LineSpecX = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'LineSpecX');
addOptional(ip, 'LineSpecX', {}, valFcn_LineSpecX);

% Allow the y-axis to have user-defined spec
valFcn_LineSpecY = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'LineSpecY');
addOptional(ip, 'LineSpecY', {}, valFcn_LineSpecY);

% Allow the z-axis to have user-defined spec
valFcn_LineSpecZ = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'LineSpecZ');
addOptional(ip, 'LineSpecZ', {}, valFcn_LineSpecZ);

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



%% Process inputs
% Get a valid new plot handle
haTarget = newplot(haTarget);
% Get old hold state
lOldHold = ishold(haTarget);
% Set axes to hold
hold(haTarget, 'on');
% Point at which to plot
vCenter = ip.Results.Center;
% Length of each axis
vAxisLength = ip.Results.Length;
% Specific line specs for the axes
ceLineSpecXYZ = ip.Results.LineSpec;
ceLineSpecX = ip.Results.LineSpecX;
ceLineSpecY = ip.Results.LineSpecY;
ceLineSpecZ = ip.Results.LineSpecZ;

% Defaults to a 2D plot
bThreeDimPlot = false;

% Determine whether we will be plotting into a 2D or 3D plot by looking at the
% view option of haTarget
[az, el] = view(haTarget);
if ~isequaln([az, el], [0, 90])
    bThreeDimPlot = true;
end

% Ensure the axis length is a vector in case it's just a scalar
if isscalar(vAxisLength)
    vAxisLength = repmat(vAxisLength, 3, 1);
% If the length given is just two dimensional, we will expand it to three
% dimensions, otherwise all our algorithms will fail
elseif numel(vAxisLength) == 2
    vAxisLength = [vAxisLength(:); 1];
end

% If there is no AtPoint given, we will create our own
if isscalar(vCenter)
    vCenter = [0; 0; 0];
% If the point given is just two dimensional, we will expand it to three
% dimensions, otherwise all our algorithms will fail
elseif numel(vCenter) == 2
    vCenter = [vCenter(:); 0];
end



%% Plot the damn thing now
% Holds our quiver handles
if bThreeDimPlot
    hQuiver = zeros(3, 1);
else
    hQuiver = zeros(2, 1);
end

% Plot differently for a 3D plot
if bThreeDimPlot
    % Plot X-axis
    hQuiver(1) = quiver3(vCenter(1), vCenter(2), vCenter(3), vAxisLength(1), 0, 0, 0, 'r-');
    % Plot Y-Axis
    hQuiver(2) = quiver3(vCenter(1), vCenter(2), vCenter(3), 0, vAxisLength(2), 0, 0, 'g-');
    % Plot Z-Axis
    hQuiver(3) = quiver3(vCenter(1), vCenter(2), vCenter(3), 0, 0, vAxisLength(3), 0, 'b-');
% 2D plots are differently than 3D plots
else
    % Plot X-Axis
    quiver(vCenter(1), vCenter(2), vAxisLength(1), 0, 0, 'r-');
    % Plot Y-Axis
    quiver(vCenter(1), vCenter(2), 0, vAxisLength(2), 0, 'g-');
end

% Apply styles to all axes
if ~isempty(ceLineSpecXYZ)
    set(hQuiver(:), ceLineSpecXYZ{:});
end
% Apply styles to x-axis
if ~isempty(ceLineSpecX)
    set(hQuiver(1), ceLineSpecX{:});
end
% Apply styles to y-axis
if ~isempty(ceLineSpecY)
    set(hQuiver(2), ceLineSpecY{:});
end
% Apply styles to z-axis
if ~isempty(ceLineSpecZ) && bThreeDimPlot
    set(hQuiver(3), ceLineSpecZ{:});
end

% Restore old hold value
if ~lOldHold
    hold(haTarget, 'off');
end

% Make sure the figure is being drawn before anything else is done
drawnow


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
