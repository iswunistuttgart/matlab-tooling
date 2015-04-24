function plotRobotFrame(winchPositions, varargin)



%% Define the input parser
ip = inputParser;

%%% Define validation methods
valFcn_Axes = @(x) ishandle(x) && strcmp(get(x, 'type'), 'axes');
valFcn_WinchPositions = @(x) ismatrix(x) && isequal(size(x, 1), 3);
valFcn_Viewport = @(x) ( isequal(x, 2) || isequal(x, 3) || ( isrow(x) && ( isequal(size(x, 2), 2) || isequal(size(x, 2), 3) ) ) );
valFcn_WinchLabels = @(x) islogical(x) || ( iscell(x) && issize(x, 1, size(winchPositions, 2)) );
valFcn_HomePosition = @(x) islogical(x) || ( isvector(x) && ( issize(x, 1, 3) || issize(x, 3, 1) ) );
valFcn_Grid = @(x) islogical(x) || any(strcmpi(x, {'on', 'off', 'minor'}));

%%% This fills in the parameters for the function
% We need the winch positions
addRequired(ip, 'WinchPositions', valFcn_WinchPositions);
% We need the axes handle which is allowed to be the first optional
% argument which must not be used with a parameter name
addOptional(ip, 'Axes', false, valFcn_Axes);
% Allow the plot to have user-defined properties
addOptional(ip, 'PlotProperties', {}, @iscell);
% Allow the lines drawn to have user-defined properties
addOptional(ip, 'BoundingBox', false, @islogical);
% Maybe the bounding box must have other properties as the ones we use
% here?
addOptional(ip, 'BoundingBoxProperties', {}, @iscell);
% The 3d view may be defined, too
addOptional(ip, 'Viewport', [-13, 10], valFcn_Viewport);
% Maybe also display the winch labels? Or custom labels?
addOptional(ip, 'WinchLabels', false, valFcn_WinchLabels);
% Some style properties to set on the winch labels?
addOptional(ip, 'WinchLabelProperties', {}, @iscell);
% Also print the home position? Can be either a logical 'true' to print at
% [0; 0; 0], or the explicit home position as a 3x1 column vector
addOptional(ip, 'HomePosition', false, valFcn_HomePosition);
% Some style properties for the home position to plot?
addOptional(ip, 'HomePositionProperties', {}, @iscell);
% Allow user to choose grid style (either false 'on', 'off', or 'minor'
addOptional(ip, 'Grid', false, valFcn_Grid);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = 'plotRobotFrame';

% Parse the provided inputs
parse(ip, winchPositions, varargin{:});


%% Parse variables of the input parser to local parser
hAxes = ip.Results.Axes;
mWinchPositions = ip.Results.WinchPositions;
cPlotProperties = ip.Results.PlotProperties;
bBoundingBox = ip.Results.BoundingBox;
cBoundingBoxProperties = ip.Results.BoundingBoxProperties;
udfViewport = ip.Results.Viewport;
mxdWinchLabels = ip.Results.WinchLabels;
cWinchLabelProperties = ip.Results.WinchLabelProperties;
mxdHomePosition = ip.Results.HomePosition;
cHomePositionProperties = ip.Results.HomePositionProperties;
% Prepare the home position argument (convert logical true to [0;0;0] or
% make sure that any vector given is a column vector (just for the beauty
% of consistent vector styles;
if islogical(mxdHomePosition) && isequal(mxdHomePosition, true)
    mxdHomePosition = [0; 0; 0];
elseif isvector(mxdHomePosition) && ~iscolumn(mxdHomePosition)
    mxdHomePosition = mxdHomePosition(:);
end
mxdGrid = ip.Results.Grid;
if islogical(mxdGrid) && isequal(mxdGrid, true)
    mxdGrid = 'on';
end


%% Plot the damn thing now!
% If there is no handle given, we will create a new figure and plot into
% that, otherwise we will select the given axes as active
if ~ishandle(hAxes)
    hFig = figure();
    hAxes = gca();
else
    axes(hAxes);
end

% First, plot the winch positions as circles
hPlotWinchPositions = plot3(mWinchPositions(1, :), mWinchPositions(2, :), mWinchPositions(3, :), 'o');
% If the plot properties were given, we need to set them on the plot
if ~isempty(cPlotProperties)
    set(hPlotWinchPositions, cPlotProperties{:});
end

% Ensure we have the axes on hold so we don't accidentaly overwrite its
% content
hold(hAxes, 'on');

% Label the winches by number?
if islogical(mxdWinchLabels) && isequal(mxdWinchLabels, true)
    for iUnit = 1:size(mWinchPositions, 2)
        hText = text(mWinchPositions(1, iUnit), mWinchPositions(2, iUnit), mWinchPositions(3, iUnit), ...
            num2str(iUnit), 'VerticalAlignment', 'bottom', 'FontSize', 10);
        if ~isempty(cWinchLabelProperties)
            set(hText, cWinchLabelProperties{:});
        end
    end
% Label the winches as given by the user
elseif iscell(mxdWinchLabels) && ~isempty(mxdWinchLabels)
    for iUnit = 1:size(mxdWinchLabels, 2)
        hText = text(mWinchPositions(1, iUnit), mWinchPositions(2, iUnit), mWinchPositions(3, iUnit), ...
            mxdWinchLabels{iUnit}, 'VerticalAlignment', 'bottom', 'FontSize', 10);
        if ~isempty(cWinchLabelProperties)
            set(hText, cWinchLabelProperties{:});
        end
    end
end

% Plot the home position?
if isequal(mxdHomePosition, true) || ( ~isscalar(mxdHomePosition) && iscolumn(mxdHomePosition) )
    % Plot the home position as a black marker
    hPlotHomePosition = plot3(mxdHomePosition(1), mxdHomePosition(2), mxdHomePosition(3), 'Color', 'k', 'Marker', 'd');
    
    if ~isempty(cHomePositionProperties)
        set(hPlotHomePosition, cHomePositionProperties{:});
    end
end

% Plot the bounding box?
if bBoundingBox
    % Get the bounding box for the winch positions
    [mWinchPositionsBoundingBox, mWinchPositionsBoundingBoxFaces] = boundingbox3(mWinchPositions(1, :), mWinchPositions(2, :), mWinchPositions(3, :));
    % And create a hollow patch
    hPatch = patch('Vertices', mWinchPositionsBoundingBox', 'Faces', mWinchPositionsBoundingBoxFaces, 'FaceColor', 'none');
    if ~isempty(cBoundingBoxProperties)
        set(hPatch, cBoundingBoxProperties{:});
    end
end

% Set the viewport
view(udfViewport);
if mxdGrid
    % Set grid on
    grid(hAxes, mxdGrid);
    if strcmpi(mxdGrid, 'minor')
        grid(hAxes, 'on');
    end
end

% And adjust the axes limits so we don't waste too much space but won't be
% too narrow on the frame/bounding box, either
xlim(hAxes, xlim().*1.05);
ylim(hAxes, ylim().*1.05);
zlim(hAxes, zlim().*1.05);

% Finally, set the active axes handle to be the first most axes handle we
% have created or were given a parameter to this function
axes(hAxes);



end