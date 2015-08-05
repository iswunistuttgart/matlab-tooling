function [varargout] = plotRobotFrame(winchPositions, varargin)
% PLOTROBOTFRAME Plot the robot frame as given by the winch positions
% 
%   PLOTROBOTFRAME(WINCHPOSITIONS) plots the winch positions in a new 3D plot
% 
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'PlotSpec', PlotSpec, ...) allows to adjust
%   the plot spec for the winch position markers. By default, the 'o' markers
%   are plotted as markers for the winches in the first default axis color.
%   
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'BoundingBox', true, ...) will also
%   print the bounding box of the winch positions.
%   
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'BoundingBoxSpec', BoundingBoxSpec, ...)
%   will print the bounding box with 'r' lines instead of the default 'k' lines.
%   See documentation of Patch Spec for available options.
%   
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'Viewport', viewport, ...) adjusts the
%   viewport of the 3d plot to the set values. Allowed values are [az, el],
%   [x, y, z], 2, 3. See documentation of view for more info. Only works in
%   standalone mode.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'WinchLabels', WinchLabels, ...) to set
%   specific labels for the corresponding winch. In case of a cell array, it
%   must be a row cell array and have as many entries as WINCHPOSITIONS has
%   columns.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'WinchLabelSpec', WinchLabelSpec, ...) to
%   set further spec on the winch labels. Check the documentation for Text
%   Properties on more info.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'HomePosition', HomePosition, ...) will plot
%   the home position as the specified position given as a [x; y; z] column
%   vector. Home position will be a diamond 'd' marker colored in 'k'.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'HomePositionSpec', HomePositionSpec, ...)
%   to set the spec of the home position as e.g., color, marker, marker size,
%   etc.. See Chart Line Properties for available options.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'Grid', Grid, ...) to define the grid style.
%   Any of the following options are allowed
%   
%       'on'        turns major grid on
%       'off'       turns all grids off
%       'minor'     turns minor and major grid on
%   
%   Only works in standalone mode.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'Title', Title) puts a title on the figure.
%   Only works in standalone mode.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'XLabel', XLabel) sets the x-axis label to
%   the specified char. Only works in standalone mode.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'YLabel', YLabel) sets the y-axis label to
%   the specified char. Only works in standalone mode.
%
%   PLOTROBOTFRAME(WINCHPOSITIONS, 'ZLabel', ZLabel) sets the z-axis label to
%   the specified char. Only works in standalone mode.
%
%   PLOTROBOTFRAME(AX, WINCHPOSITIONS, ...) plots the winch positions into the
%   specified axes
%   
%   Inputs:
%   
%   WINCHPOSITIONS: Matrix of winch positions of size 3xM where each column
%   represents one winch with its rows defined as [x; y; z]. Any number of
%   winches may be given in any order.
%
%   See also: VIEW, PLOT3, TEXT, PATCH, GRID, TITLE, XLABEL, YLABEL, ZLABEL
%
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-04-26
% Changelog:
%   2015-04-26: Introduce options 'XLabel', 'YLabel', 'ZLabel', 'Title'. Also
%               fix the logic behind {'WinchLabels', true} so we won't have
%               duplicate code for doing basically the same thing in a different
%               way.
%               Change all inputs to have column major i.e., one column is a
%               logical unit whereas between columns, the "thing" might change.
%               That means, given the winches, if we look at one column, we see
%               the data of one winch, whereas if we looked at the first row, we
%               can read info on the x-values of all winches
%   2015-04-24: Initial release



%% Preprocess inputs (allows to have the axis defined as first argument)
% By default we don't have any axes handle
hAxes = false;
% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && allAxes(winchPositions)
    hAxes = winchPositions;
    winchPositions = varargin{1};
    varargin = varargin(2:end);
end



%% Define the input parser
ip = inputParser;

% Require: Winch Positions. Must be a matrix of size 3xM
% valFcn_WinchPositions = @(x) ismatrix(x) && isequal(size(x, 1), 3);
valFcn_WinchPositions = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3}, mfilename, 'WinchPositions');
addRequired(ip, 'WinchPositions', valFcn_WinchPositions);

% We need the axes handle which is allowed to be the first optional
% argument which must not be used with a parameter name
% valFcn_Axes = @(x) validateattributes(x, {'handle', 'matlab.graphics.axis.Axes'}, {}, mfilename, 'Axes');
% addOptional(ip, 'Axes', false, valFcn_Axes);

% Allow the plot to have user-defined spec
valFcn_PlotSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'PlotSpec');
addOptional(ip, 'PlotSpec', {}, valFcn_PlotSpec);

% Bounding box about the winch positions? May be any numeric or logical value
valFcn_BoundingBox = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'BoundingBox'));
addOptional(ip, 'BoundingBox', 'off', valFcn_BoundingBox);

% Maybe the bounding box must have other spec as the ones we use here?
valFcn_BoundingBoxSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'BoundingBoxSpec');
addOptional(ip, 'BoundingBoxSpec', {}, valFcn_BoundingBoxSpec);

% The 3d view may be defined, too. Viewport may be 2, 3, [az, el], or [x, y, z]
valFcn_Viewport = @(x) validateattributes(x, {'logical', 'numeric'}, {'2d'}, mfilename, 'Viewport');
addOptional(ip, 'Viewport', [-13, 10], valFcn_Viewport);

% Maybe also display the winch labels? Or custom labels?
valFcn_WinchLabels = @(x) validateattributes(x, {'numeric', 'cell'}, {'2d', 'ncols', size(winchPositions, 2)}, mfilename, 'WinchLabels');
addOptional(ip, 'WinchLabels', {}, valFcn_WinchLabels);

% Some style spec to set on the winch labels?
valFcn_WinchLabelSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'WinchLabelSpec');
addOptional(ip, 'WinchLabelSpec', {}, valFcn_WinchLabelSpec);

% Also print the home position? Can be either a logical 'true' to print at
% [0, 0, 0], or the explicit home position as a 1x3 column vector
valFcn_HomePosition = @(x) validateattributes(x, {'numeric'}, {'column', 'nrows', 3}, mfilename, 'HomePosition');
addOptional(ip, 'HomePosition', false, valFcn_HomePosition);

% Some style spec for the home position to plot?
valFcn_HomePositionSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'HomePositionSpec');
addOptional(ip, 'HomePositionSpec', {}, valFcn_HomePositionSpec);

% Allow user to choose grid style (either 'on', 'off', or 'minor')
valFcn_Grid = @(x) any(validatestring(x, {'on', 'off', 'minor'}, mfilename, 'Grid'));
addOptional(ip, 'Grid', 'off', valFcn_Grid);

% Allow user to set the xlabel ...
valFcn_XLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'XLabel');
addOptional(ip, 'XLabel', false, valFcn_XLabel);

% Allow user to set the ylabel ...
valFcn_YLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'YLabel');
addOptional(ip, 'YLabel', false, valFcn_YLabel);

% And allow user to set the zlabel
valFcn_ZLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'ZLabel');
addOptional(ip, 'ZLabel', false, valFcn_ZLabel);

% Maybe a title is provided and shall be plotted, too?
valFcn_Title = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Title');
addOptional(ip, 'Title', false, valFcn_Title);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, winchPositions, varargin{:});



%% Parse variables of the input parser to local parser
% Ensure the handle for the axes is a valid handle. If none given, we will
% create our own figure with handle
if ~ishandle(hAxes)
    hFig = figure;
    hAxes = gca;
% Check we are looking at a 3D plot, if a plot is given
else
    [az, el] = view(hAxes);
    assert(isequaln([az, el], [0, 90]), 'Cannot plot a 3D plot into an existing 2D plot.');
end

mWinchPositions = ip.Results.WinchPositions;
% Parse winch labels
ceWinchLabels = ip.Results.WinchLabels;
bWinchLabels = ~isempty(ceWinchLabels);
% If just set to anything like true, we will magically create the labels by the
% number of winches we have
% Spec for the winch labels can be set, too
cWinchLabelSpec = ip.Results.WinchLabelSpec;
% Plot spec
cPlotSpec = ip.Results.PlotSpec;
% Bounding box?
chBoundingBox = inCharToValidArgument(ip.Results.BoundingBox);
% Spec on the bounding box
cBoundingBoxSpec = ip.Results.BoundingBoxSpec;
% Viewport settings
mxdViewport = ip.Results.Viewport;
% Home position to plot
vHomePosition = ip.Results.HomePosition;
bHomePosition = ~isequal(vHomePosition, 0);
% Spec on the home position
cHomePositionSpec = ip.Results.HomePositionSpec;
% Parse the option for the grid
chGrid = ip.Results.Grid;
% bGrid = ~isequal(chGrid, 0);
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
hPlotWinchPositions = plot3(mWinchPositions(1, :), mWinchPositions(2, :), mWinchPositions(3, :), 'o');
% If the plot spec were given, we need to set them on the plot
if ~isempty(cPlotSpec)
    set(hPlotWinchPositions, cPlotSpec{:});
end

% Label the winches (either as given by the user or as pre-defined values)
if bWinchLabels
    for iUnit = 1:size(ceWinchLabels, 2)
        hText = text(mWinchPositions(1, iUnit), mWinchPositions(2, iUnit), mWinchPositions(3, iUnit), ...
            num2str(ceWinchLabels{iUnit}), 'VerticalAlignment', 'bottom', 'FontSize', 10);
        if ~isempty(cWinchLabelSpec)
            set(hText, cWinchLabelSpec{:});
        end
    end
end

% Plot the home position?
if bHomePosition
    % Plot the home position as a black marker
    hPlotHomePosition = plot3(vHomePosition(1), vHomePosition(2), vHomePosition(3), 'Color', 'k', 'Marker', 'd');
    
    % Set spec on the home positon?
    if ~isempty(cHomePositionSpec)
        set(hPlotHomePosition, cHomePositionSpec{:});
    end
end


% Plot the bounding box?
if strcmp(chBoundingBox, 'on')
    % Get the bounding box for the winch positions
    [mWinchPositionsBoundingBox, mWinchPositionsBoundingBoxFaces] = boundingbox3(mWinchPositions(1, :), mWinchPositions(2, :), mWinchPositions(3, :));
    
    % And create a hollow patch from the bounding box
    hPatch = patch('Vertices', mWinchPositionsBoundingBox, 'Faces', mWinchPositionsBoundingBoxFaces, 'FaceColor', 'none');
    
    % Spec to set on the bounding box? No problemo!
    if ~isempty(cBoundingBoxSpec)
        set(hPatch, cBoundingBoxSpec{:});
    end
end

% This is stuff we are only going to do if we're in our own plot
if bOwnPlot
    % Set x-axis label, if provided
    if ~isempty(strtim(chXLabel))
        xlabel(hAxes, chXLabel);
    end
    % Set y-axis label, if provided
    if ~isempty(strtim(chYLabel))
        ylabel(hAxes, chYLabel);
    end
    % Set z-axis label, if provided
    if ~isempty(strtim(chZLabel))
        zlabel(hAxes, chZLabel);
    end
    
    % Set a figure title?
    if ~isempty(strtim(chTitle))
        title(hAxes, chTitle);
    end
    
    % Set the viewport
    view(hAxes, mxdViewport);
    
    % Set a grid?
    if any(strcmp(chGrid, {'on', 'minor'}))
        % Set grid on
        grid(hAxes, chGrid);
        % For minor grids we will also enable the "major" grid
        if strcmpi(chGrid, 'minor')
            grid(hAxes, 'on');
        end
    end

    % And adjust the axes limits so we don't waste too much space but won't be
    % too narrow on the frame/bounding box, either
%     xlim(hAxes, xlim().*1.05);
%     ylim(hAxes, ylim().*1.05);
%     zlim(hAxes, zlim().*1.05);
end

% Make sure the figure is being drawn before anything else is done
drawnow

% Finally, set the active axes handle to be the first most axes handle we
% have created or were given a parameter to this function
axes(hAxes);

% Enforce drawing of the image before returning anything
drawnow

% Clear the hold off the current axes
hold(hAxes, 'off');



%% Assign output quantities
if nargout >= 1
    varargout{1} = hAxes;
end


end

function result = allAxes(h)

result = all(all(ishghandle(h))) && ...
         length(findobj(h,'type','axes','-depth',0)) == length(h);

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
% end ```switch lower(in)```

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
