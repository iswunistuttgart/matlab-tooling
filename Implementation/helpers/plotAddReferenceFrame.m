function plotAddReferenceFrame(varargin)

%% Process arguments
% By default we don't have any axes to plot to
haAxes = false;

% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && isallaxes(varargin{1})
    haAxes = varargin{1};
    varargin = varargin(2:end);
end



%% Define the input parser
ip = inputParser;

% Optional first: AtPoint which will be the location of where the reference
% frame will be plotted at
valFcn_AtPoint = @(x) validateattributes(x, {'numeric'}, {'vector', 'nonempty'}, mfilename, 'AtPoint');
addOptional(ip, 'AtPoint', 0, valFcn_AtPoint);

% Optional second: AtPoint which will be the location of where the reference
% frame will be plotted at
valFcn_AxisLength = @(x) validateattributes(x, {'numeric'}, {'vector', 'nonempty'}, mfilename, 'Length');
addOptional(ip, 'Length', 1, valFcn_AxisLength );

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, varargin{:});



%% Process inputs
% Point at which to plot
vAtPoint = ip.Results.AtPoint;
% Length of each axis
vAxisLength = ip.Results.Length;

% Check we have a valid handle
if ~ishandle(haAxes)
    haAxes = gca;
end

% Defaults to a 2D plot
bThreeDimPlot = false;

% Determine whether we will be plotting into a 2D or 3D plot by looking at the
% view option of haAxes
[az, el] = view(haAxes);
if ~isequaln([az, el], [0, 90])
    bThreeDimPlot = true;
end

% If there is no axis length given, we will guess it from the maximum plot range
% and just plot 5% of that total
% if vAxisLength == 0
%     [vMinRange, vMaxRange] = plotrange(haAxes, 'min+max');
%     
%     dLengthX = vMaxRange(1) - vMinRange(1);
%     dLengthY = vMaxRange(2) - vMinRange(2);
%     dLengthZ = vMaxRange(3) - vMinRange(3);
%     
%     % Fallback if x length is 0 (i.e., flat y-z 3D-plot)
%     if dLengthX == 0
%         dLengthX = mean([dLengthY, dLengthZ]);
%     end
%     
%     % Fallback if x length is 0 (i.e., flat x-z 3D-plot)
%     if dLengthY == 0
%         dLengthY = mean([dLengthX, dLengthZ]);
%     end
%     
%     % Fallback if x length is 0 (i.e., flat x-y 3D-plot)
%     if dLengthZ == 0
%         dLengthZ = mean([dLengthX, dLengthY]);
%     end
%     
%     vAxisLength = [dLengthX; dLengthY; dLengthZ].*0.15;
% end

% Ensure the axis length is a vector in case it's just a scalar
if isscalar(vAxisLength)
    vAxisLength = repmat(vAxisLength, 3, 1);
% If the length given is just two dimensional, we will expand it to three
% dimensions, otherwise all our algorithms will fail
elseif numel(vAxisLength) == 2
    vAxisLength = [vAxisLength(:); 1];
end

% If there is no AtPoint given, we will create our own
if isscalar(vAtPoint)
    vAtPoint = [0; 0; 0];
% If the point given is just two dimensional, we will expand it to three
% dimensions, otherwise all our algorithms will fail
elseif numel(vAtPoint) == 2
    vAtPoint = [vAtPoint(:); 0];
end



%% Plot the damn thing now
% Select the given axes as target
axes(haAxes);

% Ensure we have the axes on hold so we don't accidentaly overwrite its
% content
hold(haAxes, 'on');

% This is our array of axes we will be plotting
vAxes = [vAtPoint(1), vAtPoint(1) + vAxisLength(1); ...
    vAtPoint(2), vAtPoint(2) + vAxisLength(2); ...
    vAtPoint(3), vAtPoint(3) + vAxisLength(3)];

% Plot differently for a 3D plot
if bThreeDimPlot
    % Plot X-axis
    plot3(vAxes(1,:), [0, 0], [0, 0], 'r-');
    % Plot Y-Axis
    plot3([0, 0], vAxes(2,:), [0, 0], 'g-');
    % Plot Z-Axis
    plot3([0, 0], [0, 0], vAxes(3,:), 'b-');
% 2D plots are differently than 3D plots
else
    % Plot X-Axis
    plot(vAxes(1,:), [0, 0], 'r-');
    % Plot Y-Axis
    plot([0, 0], vAxes(2,:), 'g-');
end

% Make sure the figure is being drawn before anything else is done
drawnow

% Finally, set the active axes handle to be the first most axes handle we
% have created or were given a parameter to this function
axes(haAxes);

% Enforce drawing of the image before returning anything
drawnow

% Clear the hold off the current axes
hold(haAxes, 'off');


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
