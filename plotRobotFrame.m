function [varargout] = plotRobotFrame(winchPositions, varargin)
% PLOTROBOTFRAME Plot the robot frame as given by the winch positions
% 
%   PLOTROBOTFRAME(WINCHPOSITIONS) plots the winch positions in a new 3D plot
%   
%   PLOTROBOTFRAME(WINCHPOSITIONS, ax) plots the winch positions into the
%   given axes. May be used to add the winch positions to e.g., the plot of
%   the trajectory or a subplot of a multiplot figure.
%   
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'Axes', ax) plots the winch positions
%   into the given axes. May be used to add the winch positions to e.g.,
%   the plot of a trajectory or a subplot of a multiplot figure.
% 
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'PlotProperties', {'Color', 'r'}, ...)
%   allows to adjust the plot properties for the winch position markers. By
%   default, the 'o' markers are plotted in the first default axis color.
%   
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'BoundingBox', true, ...) will also
%   print the bounding box of the winch positions.
%   
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'BoundingBoxProperties', {'Color', 'r'},
%   ...) will print the bounding box with 'r' lines instead of the default
%   'k' lines. See documentation of Patch Properties for available options.
%   
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'Viewport', viewport, ...) adjusts the
%   viewport of the 3d plot to the set values. Allowed values are [az, el],
%   [x, y, z], 2, 3. See documentation of view for more info. Only works in
%   standalone mode.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'WinchLabels', true, ...) if you want to
%   label the winches according to their column index of winch positions.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'WinchLabels', {'W1', 'W2', ..., 'WM'},
%   ...) to set specific labels for the corresponding winch. In case of a
%   cell array, it must be a row cell array and have as many entries as
%   WINCHPOSITIONS has rows.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'WinchLabelProperties',
%   {'VerticalAlignment', 'bottom'}, ...) to set further properties on the
%   winch labels. Check the documentation for Text Properties on more info.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'HomePosition', true, ...) will plot the
%   home position defined by [0, 0, 0] into the current plot. Home position
%   will be a diamond 'd' marker colored in 'k'.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'HomePosition', [1, 1, 1], ...) will
%   plot the home position as the specified position given as a [x, y, z]
%   row vector. Home position will be a diamond 'd' marker colored in 'k'.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'HomePositionProperties', {'Color',
%   'r'}, ...) to set the properties of the home position as e.g., color,
%   marker, marker size, etc.. See Chart Line Properties for available
%   options.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'Title', 'Robot frame') puts a title on the
%   figure. Only works in standalone mode.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'XLabel', '$x$') sets the x-axis label to the
%   specified char. Only works in standalone mode.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'YLabel', '$y$') sets the y-axis label to the
%   specified char. Only works in standalone mode.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'ZLabel', '$z$') sets the z-axis label to the
%   specified char. Only works in standalone mode.
%   
%   Inputs:
%   
%   WINCHPOSITIONS: Matrix of winch positions of size Mx3 where each row
%   represents one winch with its columns sorted as [x, y, z]. Any number of
%   winches may be given in any order.
%
%   See also:
%   VIEW
%   PLOT3
%   TEXT
%   PATCH
%   GRID
%
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-04-26
% Changelog:
%   2015-04-26: Introduce options 'XLabel', 'YLabel', 'ZLabel', 'Title'. Also
%               fix the logic behind {'WinchLabels', true} so we won't have
%               duplicate code for doing basically the same thing in a different
%               way
%   2015-04-24: Initial release



%% Define the input parser
ip = inputParser;

%%% Define validation methods
valFcn_AnythingTrueOrFalse = @(x) isequal(x, true) || isequal(x, false);
% Winch positions must be a matrix of size 3xM
% valFcn_WinchPositions = @(x) validateattributes(x, {'numeric'}, {'2d', 'ncolumns', 3}, mfilename, 'WinchPositions');
valFcn_WinchPositions = @(x) ismatrix(x) && isequal(size(x, 2), 3);
% Option to 'axes' must be a handle and also a 'axes' handle
% valFcn_Axes = @(x) validateattributes(x, {'matlab.graphics.axis.Axes'}, {}, mfilename, 'Axes');
valFcn_Axes = @(x) ishandle(x) && strcmp(get(x, 'type'), 'axes');
% Bounding box may be anything true or false (i.e., true, false, 0, 1)
valFcn_BoundingBox = @(x) valFcn_AnythingTrueOrFalse(x);
% Viewport may be 2, 3, [az, el], or [x, y, z]
% valFcn_Viewport = @(x) validateattributes(x, {'logical', 'numeric'}, {'2d'}, mfilename, 'Viewport');
valFcn_Viewport = @(x) ( isequal(x, 2) || isequal(x, 3) || ( isrow(x) && ( isequal(size(x, 2), 2) || isequal(size(x, 2), 3) ) ) );
% Winch labels may be true, false, 1, 0, or a cell array
% valFcn_WinchLabels = @(x) validateattributes(x, {'logical', 'numeric', 'cell'}, {'2d', 'cell'}, mfilename, 'WinchLabels');
valFcn_WinchLabels = @(x) valFcn_AnythingTrueOrFalse(x) || ( iscell(x) && issize(x, 1, size(winchPositions, 1)) );
% Home position may be true, false, 1, 0, or a vector of size 1x3 or 3x1
valFcn_HomePosition = @(x) valFcn_AnythingTrueOrFalse(x) || ( isrow(x) && isequal(size(x, 2), 3) );
% Grid may be true, false, 1, 0, 'on', 'off', or 'minor'
valFcn_Grid = @(x) valFcn_AnythingTrueOrFalse(x) || any(strcmpi(x, {'on', 'off', 'minor'}));

%%% This fills in the parameters for the function
% We need the winch positions
addRequired(ip, 'WinchPositions', valFcn_WinchPositions);
% We need the axes handle which is allowed to be the first optional
% argument which must not be used with a parameter name
addOptional(ip, 'Axes', false, valFcn_Axes);
% Allow the plot to have user-defined properties
addOptional(ip, 'PlotProperties', {}, @iscell);
% Allow the lines drawn to have user-defined properties
addOptional(ip, 'BoundingBox', false, valFcn_BoundingBox);
% Maybe the bounding box must have other properties as the ones we use here?
addOptional(ip, 'BoundingBoxProperties', {}, @iscell);
% The 3d view may be defined, too
addOptional(ip, 'Viewport', [-13, 10], valFcn_Viewport);
% Maybe also display the winch labels? Or custom labels?
addOptional(ip, 'WinchLabels', false, valFcn_WinchLabels);
% Some style properties to set on the winch labels?
addOptional(ip, 'WinchLabelProperties', {}, @iscell);
% Also print the home position? Can be either a logical 'true' to print at
% [0, 0, 0], or the explicit home position as a 1x3 column vector
addOptional(ip, 'HomePosition', false, valFcn_HomePosition);
% Some style properties for the home position to plot?
addOptional(ip, 'HomePositionProperties', {}, @iscell);
% Allow user to choose grid style (either false 'on', 'off', or 'minor')
addOptional(ip, 'Grid', false, valFcn_Grid);
% Allow user to set the xlabel ...
addOptional(ip, 'XLabel', false, @ischar);
% Allow user to set the ylabel ...
addOptional(ip, 'YLabel', false, @ischar);
% And allow user to set the zlabel
addOptional(ip, 'ZLabel', false, @ischar);
% Maybe a title is provided and shall be plotted, too?
addOptional(ip, 'Title', false, @ischar);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = 'plotRobotFrame';

% Parse the provided inputs
parse(ip, winchPositions, varargin{:});



%% Parse variables of the input parser to local parser
hAxes = ip.Results.Axes;
% Ensure the handle for the axes is a valid handle. If none given, we will
% create our own figure with handle
if ~ishandle(hAxes)
    hFig = figure;
    hAxes = gca;
end

mWinchPositions = ip.Results.WinchPositions;
% Parse winch labels
ceWinchLabels = ip.Results.WinchLabels;
% If just set to anything like true, we will magically create the labels by the
% number of winches we have
if isequal(ceWinchLabels, true)
    ceWinchLabels = cell(1, size(mWinchPositions, 1));
    for iUnit = 1:size(mWinchPositions, 1)
        ceWinchLabels{iUnit} = num2str(iUnit);
    end
else
    ceWinchLabels = {};
end
% Properties for the winch labels can be set, too
cWinchLabelProperties = ip.Results.WinchLabelProperties;
% Plot properties
cPlotProperties = ip.Results.PlotProperties;
% Bounding box?
bBoundingBox = ip.Results.BoundingBox;
% Properties on the bounding box
cBoundingBoxProperties = ip.Results.BoundingBoxProperties;
% Viewport settings
mxdViewport = ip.Results.Viewport;
% Home position to plot
vHomePosition = ip.Results.HomePosition;
% Prepare the home position argument (convert logical true to [0;0;0] or
% make sure that any vector given is a row vector (just for the beauty
% of consistent vector styles;
if islogical(vHomePosition) && isequal(vHomePosition, true)
    vHomePosition = [0, 0, 0];
elseif isvector(vHomePosition) && ~row(vHomePosition)
    vHomePosition = vHomePosition(:)';
end
% Properties on the home position
cHomePositionProperties = ip.Results.HomePositionProperties;
% Parse the option for the grid
chGrid = ip.Results.Grid;
if islogical(chGrid) && isequal(chGrid, true)
    chGrid = 'on';
end
% Get the desired figure title (works only in standalone mode)
chTitle = ip.Results.Title;
% Get provided axes labels
chXLabel = ip.Results.XLabel;
chYLabel = ip.Results.YLabel;
chZLabel = ip.Results.ZLabel;


% If this is a single plot i.e., the given axes does not have any children, then
% we are completely free at plotting stuff like labels, etc., Otherwise, we will
% really just plot the robot frame
bOwnPlot = isempty(get(hAxes, 'Children'));



%% Plot the damn thing now!
% Select the given axes as target
axes(hAxes);

% Ensure we have the axes on hold so we don't accidentaly overwrite its
% content
hold(hAxes, 'on');

% First, plot the winch positions as circles
hPlotWinchPositions = plot3(mWinchPositions(:, 1), mWinchPositions(:, 2), mWinchPositions(:, 3), 'o');
% If the plot properties were given, we need to set them on the plot
if ~isempty(cPlotProperties)
    set(hPlotWinchPositions, cPlotProperties{:});
end

% Label the winches (either as given by the user or as pre-defined values)
if ~isempty(ceWinchLabels)
    for iUnit = 1:size(ceWinchLabels, 2)
        hText = text(mWinchPositions(iUnit, 1), mWinchPositions(iUnit, 2), mWinchPositions(iUnit, 3), ...
            ceWinchLabels{iUnit}, 'VerticalAlignment', 'bottom', 'FontSize', 10);
        if ~isempty(cWinchLabelProperties)
            set(hText, cWinchLabelProperties{:});
        end
    end
end

% Plot the home position?
if isrow(vHomePosition)
    % Plot the home position as a black marker
    hPlotHomePosition = plot3(vHomePosition(1), vHomePosition(2), vHomePosition(3), 'Color', 'k', 'Marker', 'd');
    
    % Set properties on the home positon?
    if ~isempty(cHomePositionProperties)
        set(hPlotHomePosition, cHomePositionProperties{:});
    end
end


% Plot the bounding box?
if bBoundingBox
    % Get the bounding box for the winch positions
    [mWinchPositionsBoundingBox, mWinchPositionsBoundingBoxFaces] = boundingbox3(mWinchPositions(:, 1), mWinchPositions(:, 2), mWinchPositions(:, 3));
    
    % And create a hollow patch from the bounding box
    hPatch = patch('Vertices', mWinchPositionsBoundingBox, 'Faces', mWinchPositionsBoundingBoxFaces, 'FaceColor', 'none');
    
    % Properties to set on the bounding box? No problemo!
    if ~isempty(cBoundingBoxProperties)
        set(hPatch, cBoundingBoxProperties{:});
    end
end

% This is stuff we are only going to do if we're in our own plot
if bOwnPlot
    % Set x-axis label, if provided
    if chXLabel
        xlabel(hAxes, chXLabel);
    end
    % Set y-axis label, if provided
    if chYLabel
        ylabel(hAxes, chYLabel);
    end
    % Set z-axis label, if provided
    if chZLabel
        zlabel(hAxes, chZLabel);
    end
    
    % Set a figure title?
    if chTitle
        title(hAxes, chTitle);
    end
    
    % Set the viewport
    view(hAxes, mxdViewport);
    
    % Set a grid?
    if chGrid
        % Set grid on
        grid(hAxes, chGrid);
        % For minor grids we will also enable the "major" grid
        if strcmpi(chGrid, 'minor')
            grid(hAxes, 'on');
        end
    end

    % And adjust the axes limits so we don't waste too much space but won't be
    % too narrow on the frame/bounding box, either
    xlim(hAxes, xlim().*1.05);
    ylim(hAxes, ylim().*1.05);
    zlim(hAxes, zlim().*1.05);
end

% Finally, set the active axes handle to be the first most axes handle we
% have created or were given a parameter to this function
axes(hAxes);

% Enforece drawing of the image before returning anything
drawnow



%% Assign output quantities
if nargout >= 1
    varargout{1} = hAxes;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
