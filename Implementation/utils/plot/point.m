function point(X, Y, varargin)

%% Pre-Process inputs
haAxes = false;
if ~isempty(varargin) && isallaxes(X)
    haAxes = X;
    X = Y;
    Y = varargin{1};
    varargin = varargin(2:end);
end

% if ismatrix(X)
%     if size(X, 1) == 2
%         varargin = [{Y}; varargin];
%         Y = X(2,:);
%         X = X(1,:);
%     elseif size(X, 2) == 2
%         varargin = [{Y}; varargin];
%         Y = X(:,2);
%         X = X(:,1);
%     else
%         error('PHILIPPTEMPEL:point:invalidDataArgument', 'Invalid value for Points given. Can only accept 2xN or Nx2 matrices');
%     end
% end



%% Define the input parser
ip = inputParser;

% Required First: x-coordinate(s) of point(s)
valFcn_X = @(x) validateattributes(x, {'numeric'}, {'vector', 'nonempty', 'real', 'finite', 'size', size(Y)}, mfilename, 'X');
addRequired(ip, 'X', valFcn_X);

% Required Two: y-coordinate(s) of point(s)
valFcn_Y = @(x) validateattributes(x, {'numeric'}, {'vector', 'nonempty', 'real', 'finite', 'size', size(X)}, mfilename, 'Y');
addRequired(ip, 'Y', valFcn_Y);

% Plot intersections with the x and y axis?
valFcn_Intersections = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'Intersections'));
addOptional(ip, 'Intersections', 'off', valFcn_Intersections);

% Allow the axes to have user-defined spec
valFcn_PointSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'PointSpec');
addOptional(ip, 'PointSpec', {}, valFcn_PointSpec);

% Allow the axes to have user-defined spec
valFcn_IntersectSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'IntersectSpec');
addOptional(ip, 'IntersectSpec', {}, valFcn_IntersectSpec);

% Allow the x-axis to have user-defined spec
valFcn_IntersectXSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'IntersectXSpec');
addOptional(ip, 'IntersectXSpec', {}, valFcn_IntersectXSpec);

% Allow the y-axis to have user-defined spec
valFcn_IntersectYSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'IntersectYSpec');
addOptional(ip, 'IntersectYSpec', {}, valFcn_IntersectYSpec);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, X, Y, varargin{:});


%% Process inputs
% Get the x-coordinate(s) of point(s)
vCoordsX = ip.Results.X;
% Get the y-coordinate(s) of point(s)
vCoordsY = ip.Results.Y;
% Parse the points into an array of [x, y]
aPoints = [vCoordsX(:), vCoordsY(:)];
% If we don't have a valid axes handle, we will grab the active one
if ~ishandle(haAxes)
    haAxes = gca;
end
% Also plot intersection lines?
chPlotIntersections = inCharToValidArgument(ip.Results.Intersections);
% Point Specs
cePointSpec = ip.Results.PointSpec;
% Line specs
ceIntersectSpec = ip.Results.IntersectSpec;
ceIntersectXSpec = ip.Results.IntersectXSpec;
ceIntersectYSpec = ip.Results.IntersectYSpec;

% Number of points we'll be plotting
nPoints = size(aPoints, 1);



%% And draw it
% Make sure we don't overwrite previous plot data
hold(haAxes, 'on');

% Since we allow for drawing many points
% for iPoint = 1:nPoints
%     hMarkers(iPoint) = plot(aPoints(iPoint,1), aPoints(iPoint,2));
%     drawnow;
%     hIntersectionsX(iPlot) = plot([vCoordsX(iPoint), vCoordsX(iPoint)], [vCoordsY(iPoint), 0]);
%     hIntersectionsY(iPlot) = plot([vCoordsX(iPoint), 0], [vCoordsY(iPoint), vCoordsY(iPoint)]);
% end
hMarkers = plot(aPoints(:,1), aPoints(:,2), 'o');
% Set some default marker styles
set(hMarkers(:), 'Marker', 'o');

% Draw intersections only when requested
if strcmp('on', chPlotIntersections)
    % Draw intersection with x-axis
    hIntersectionsX = plot([aPoints(:,1), aPoints(:,1)].', [aPoints(:,2), zeros(nPoints, 1)].');
    % Intersection with y-axis
    hIntersectionsY = plot([aPoints(:,1), zeros(nPoints, 1)].', [aPoints(:,2), aPoints(:,2)].');
    % Apply some default line styles
    set(hIntersectionsX(:), 'Color', [150, 150, 150]./255, 'LineStyle', '--');
    set(hIntersectionsY(:), 'Color', [150, 150, 150]./255, 'LineStyle', '--');
end


%% Post-processing
% Set marker spects
if ~isempty(cePointSpec)
    set(hMarkers(:), cePointSpec{:});
end
% Set line specs for both intersection lines
if ~isempty(ceIntersectSpec) && strcmp('on', chPlotIntersections)
    set(hIntersectionsX(:), ceIntersectSpec{:});
    set(hIntersectionsY(:), ceIntersectSpec{:});
end
% Set line specs for x-intersection lines
if ~isempty(ceIntersectXSpec) && strcmp('on', chPlotIntersections)
    set(hIntersectionsX(:), ceIntersectXSpec{:});
end
% Set line specs for y-intersection lines
if ~isempty(ceIntersectYSpec) && strcmp('on', chPlotIntersections)
    set(hIntersectionsY(:), ceIntersectYSpec{:});
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
