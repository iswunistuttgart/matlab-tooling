function point(X, Y, varargin)



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
try
    varargin = [{X}, {Y}, varargin];
    [haTarget, args, ~] = axescheck(varargin{:});
    
    parse(ip, args{:});
catch me
    throw(MException(me.identifier, me.message));
end



%% Process inputs
% Get the x-coordinate(s) of point(s)
vCoordsX = ip.Results.X;
% Get the y-coordinate(s) of point(s)
vCoordsY = ip.Results.Y;
% Parse the points into an array of [x, y]
aPoints = [vCoordsX(:), vCoordsY(:)];
% Axes handle
haTarget = newplot(haTarget);
% What's the old hold status?
lOldHold = ishold(haTarget);
% Make sure we don't overwrite anything
hold(haTarget, 'on');
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

% Clear the hold off the current axes
if ~lOldHold
    hold(haTarget, 'off');
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
