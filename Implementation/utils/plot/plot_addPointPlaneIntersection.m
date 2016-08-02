function plot_addPointPlaneIntersection(Point, varargin)
% PLOT_ADDPOINTPLANEINTERSECTION Adds intersection indicator for a point on the
%   three axes-planes
% 
%   PLOT_ADDPOINTPLANEINTERSECTION(POINT) adds the intersection lines of the
%   point POINT with the x and y axis or the x-y, y-z, and x-z plane
%   
%   Inputs:
%   
%   POINT: Point to intersect with the axes or planes



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-03-25
% Changelog:
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%       * Wedge out param-value pairs to only the needed ones
%       * Introduce option 'LabelSpec'
%   2016-03-25
%       * Initial release




%% Define the input parser
ip = inputParser;

% Optional first: AtPoint which will be the location of where the reference
% frame will be plotted at
valFcn_Point = @(x) validateattributes(x, {'numeric'}, {'vector', 'nonempty'}, mfilename, 'Point');
addOptional(ip, 'Point', 0, valFcn_Point);

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

% Allow the z-axis to have user-defined spec
valFcn_DisplayPoint = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'DisplayPoint'));
addOptional(ip, 'DisplayPoint', 'off', valFcn_DisplayPoint);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    varargin = [{Point}, varargin];
    [haAxes, args, ~] = axescheck(varargin{:});
    
    parse(ip, args{:});
catch me
    throwAsCaller(MException(me.identifier, me.message));
end



%% Assign local variables
% Axes handle
haAxes = newplot(haAxes);
% What's the old hold status?
lOldHold = ishold(haAxes);
% Make sure we don't overwrite anything
hold(haAxes, 'on');
% Point
vPoint = ip.Results.Point;
% Line specs
ceLineSpecXYZ = ip.Results.LineSpec;
ceLineSpecX = ip.Results.LineSpecX;
ceLineSpecY = ip.Results.LineSpecY;
ceLineSpecZ = ip.Results.LineSpecZ;
% Display point, too?
chDisplayPoint = inCharToValidArgument(ip.Results.DisplayPoint);


% Determine whether we will be plotting into a 2D or 3D plot by looking at the
% view option of haAxes
bThreeDimPlot = false;
[az, el] = view(haAxes);
if ~isequaln([az, el], [0, 90])
    bThreeDimPlot = true;
end

if bThreeDimPlot
    hIntersects = zeros(3, 1);
else
    hIntersects = zeros(1, 1); 
end



%% Magic plotting
% Plotting a 3D plot is different to a 2D plot
if bThreeDimPlot
    vPathOnXYPlane = [vPoint(1), 0, 0; ...
                    vPoint(1), vPoint(2), 0; ...
                    0, vPoint(2), 0];
    vPathOnYZPlane = [0, vPoint(2), 0; ...
                    0, vPoint(2), vPoint(3); ...
                    0, 0, vPoint(3)];
    vPathOnXZPlane = [vPoint(1), 0, 0; ...
                    vPoint(1), 0, vPoint(3); ...
                    0, 0, vPoint(3)];
    
    % Plot the intersection with the x-y plane i.e, z2 = 0
    hIntersects(1) = plot3(vPathOnXYPlane(:,1), vPathOnXYPlane(:,2), vPathOnXYPlane(:,3));
    % Plot the intersection with the y-z plane i.e, x2 = 0
    hIntersects(2) = plot3(vPathOnYZPlane(:,1), vPathOnYZPlane(:,2), vPathOnYZPlane(:,3));
    % Plot the intersection with the x-z plane i.e, y2 = 0
    hIntersects(3) = plot3(vPathOnXZPlane(:,1), vPathOnXZPlane(:,2), vPathOnXZPlane(:,3));
else
    vPathOnXYPlane = [vPoint(1), 0; ...
                    vPoint(1), vPoint(2); ...
                    0, vPoint(2)];
    hIntersects(1) = plot(vPathOnXYPlane(:,1), vPathOnXYPlane(:,2));
end

% Apply a less blatant style to the lines
set(hIntersects(:), 'Color', [200, 200, 200]./255, 'LineStyle', '--');



%% Post-processing
% Apply styles to all axes
if ~isempty(ceLineSpecXYZ)
    set(hIntersects(:), ceLineSpecXYZ{:});
end
% Apply styles to x-axis
if ~isempty(ceLineSpecX)
    set(hIntersects(1), ceLineSpecX{:});
end
% Apply styles to y-axis
if ~isempty(ceLineSpecY)
    set(hIntersects(2), ceLineSpecY{:});
end
% Apply styles to z-axis
if ~isempty(ceLineSpecZ) && bThreeDimPlot
    set(hIntersects(3), ceLineSpecZ{:});
end

% Finally, set the active axes handle to be the first most axes handle we
% have created or were given a parameter to this function
axes(haAxes);

% Make sure the figure is being drawn before anything else is done
drawnow

% Clear the hold off the current axes
if ~lOldHold
    hold(haAxes, 'off');
end


end

function out = inCharToValidArgument(in)

switch lower(in)
    case {'on', 'yes', 'please'}
        out = 'on';
    case {'off', 'no', 'never'}
        out = 'off';
    otherwise
        out = 'off';
end

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
