function varargout = plotRobotPoses(Time, Poses, varargin)
% PLOTROBOTPOSES Plots the given poses of the robot
% 
%   PLOTROBOTPOSES(TIME, POSES) plots the poses against time in a new 2D
%   plot
%   
%   PLOTROBOTPOSES(TIME, POSES, 'PlotStyle', PlotStyleValue) will plot the
%   poses in a different style. Possible values are
%   
%       2D      plot [X, Y, Z] against [T]
%       2DXY    plot [Y] against [X]
%       2DYX    plot [X] against [Y]
%       2DYZ    plot [Z] against [Y]
%       2DZY    plot [Y] against [Z]
%       2DXZ    plot [Z] against [X]
%       2DZX    plot [X] against [Z]
%       3D      plot [Z] against [Y] against [X] (In conjunction with
%               PLOTROBOTAXES(AX, ...) only allowed if given axes is already a
%               3D plot
% 
%   PLOTROBOTPOSES(TIME, POSES, 'LineSpec', LineSpecs) forces the given
%   line specs on the 2D or 3D plot. See LINESPEC
%   
%   PLOTROBOTPOSES(TIME, POSES, , 'Viewport', viewport, ...) adjusts the
%   viewport of the 3d plot to the set values. Allowed values are 2, 3, [az,
%   el], or [x, y, z]. See documentation of view for more info. Only works in
%   standalone mode.
%   
%   PLOTROBOTPOSES(TIME, POSES, 'BoundingBoxSpec', {'Color', 'r'},
%   ...) will print the bounding box with 'r' lines instead of the default
%   'k' lines. See documentation of Patch Spec for available options.
%   
%   PLOTROBOTPOSES(TIME, POSES, 'Viewport', viewport, ...) adjusts the
%   viewport of the 3d plot to the set values. Allowed values are [az, el],
%   [x, y, z], 2, 3. See documentation of view for more info. Only works in
%   standalone mode.
%
%   PLOTROBOTPOSES(TIME, POSES, 'Grid', Grid, ...) to define the grid
%   style. Any of the following options are allowed
%   
%       'on'        turns major grid on
%       'off'       turns all grids off
%       'minor'     turns minor and major grid on
%   
%   Only works in standalone mode.
%
%   PLOTROBOTPOSES(TIME, POSES, 'Title', Title) puts a title on the figure.
%   Only works in standalone mode.
%
%   PLOTROBOTPOSES(TIME, POSES, 'XLabel', XLabel) sets the x-axis label to
%   the specified char. Only works in standalone mode.
%
%   PLOTROBOTPOSES(TIME, POSES, 'YLabel', YLabel) sets the y-axis label to
%   the specified char. Only works in standalone mode.
%
%   PLOTROBOTPOSES(TIME, POSES, 'ZLabel', ZLabel) sets the z-axis label to
%   the specified char. Only works in standalone mode.
%   
%   PLOTROBOTPOSES(AX, TIME, POSES, ...) plots the poses into the specified
%   axes.
%   
%   Inputs:
%   
%   TIME: Column vector of increasing values representing the timestamps at wich
%   the poses are gathered. Only needed in any '2D' mode.
%   
%   POSES: Matrix of poses of the platform center of gravity where each row is
%   the [x, y, z] tuple of platform center of gravity positon at the time
%   corresponding to that value
%
%   See also: VIEW, PLOT, PLOT3, LINESPEC, GRID, TITLE, XLABEL, YLABEL, ZLABEL
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
if ~isempty(varargin) && allAxes(Poses)
    hAxes = Time;
    Time = Poses;
    Poses = varargin{1};
    varargin = varargin(2:end);
end



%% Define the input parser
ip = inputParser;

% Require: Time column vector
% Time must be an increasing column vector
valFcn_Time = @(x) validateattributes(x, {'numeric'}, {'vector', 'column', 'increasing'}, mfilename, 'Time');
addRequired(ip, 'Time', valFcn_Time);

% Require: Matrix of poses
% List of poses must be a matrix with as many columns as Time has rows
valFcn_Poses = @(x) validateattributes(x, {'numeric'}, {'2d', 'size', [size(Time, 1), 3]}, mfilename, 'Poses');
addRequired(ip, 'Poses', valFcn_Poses);

% Axes may be given, too, as always, so that we could add the poses to the
% frame and winch plot or pose list plot
% Option to 'axes' must be a handle and also a 'axes' handle
% valFcn_Axes = @(x) validateattributes(x, {'handle', 'matlab.graphics.axis.Axes'}, {}, mfilename, 'Axes');
% addOptional(ip, 'Axes', false, valFcn_Axes);

% Let user decied on the plot style
% Plot style can be chosen anything from the list below
valFcn_PlotStyle = @(x) any(validatestring(x, {'2D', '2DXY', '2DYX', '2DYZ', '2DZY', '2DXZ', '2DZX', '3D'}, mfilename, 'PlotStyle'));
addOptional(ip, 'PlotStyle', '2D', valFcn_PlotStyle);

% Let user decied on the plot spec
valFcn_LineSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'LineSpec');
addOptional(ip, 'LineSpec', {}, valFcn_LineSpec);

% The 3d view may be defined, too
% Viewport may be 2, 3, [az, el], or [x, y, z]
valFcn_Viewport = @(x) validateattributes(x, {'numeric'}, {'row'}, mfilename, 'Viewport') || validateattributes(x, {'numeric'}, {'ncols', '>=', '2', 'ncols', '<=', 3}, mfilename, 'Viewport');
addOptional(ip, 'Viewport', [-13, 10], valFcn_Viewport);

% Allow user to choose grid style (either 'on', 'off', or 'minor')
valFcn_Grid = @(x) any(validatestring(x, {'on', 'off', 'minor'}, mfilename, 'Grid'));
addOptional(ip, 'Grid', false, valFcn_Grid);

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
parse(ip, Time, Poses, varargin{:});



%% Parse and prepare variables locally
% Vector of time
vTime = ip.Results.Time;
% Vector of poses
mPoses = ip.Results.Poses;
% Axes handle
if ~ishandle(hAxes)
    hFig = figure;
    hAxes = gca;
end
% General plot style
chPlotStyle = upper(ip.Results.PlotStyle);
% Ensure we have the right given axes for the given plot style i.e., no 2D plot
% into a 3D axes, nor a 3D plot into a 2D axis
[az, el] = view(hAxes);
if ~ ( isempty(regexp(chPlotStyle, '^2.*$', 'once')) || isequaln([az, el], [0, 90]) )
    error('PHILIPPTEMPEL:plotRobotPoses:invalidAxesType', 'Given plot styles does not match provided axes type. Cannot plot a 2D image into a 3D plot.');
end

% Plotting spec
cLineSpec = ip.Results.LineSpec;
% 3D viewport (only used for 3d plot style)
vViewport = ip.Results.Viewport;
% Grid options
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

% Is this our own plot?
bOwnPlot = isempty(get(hAxes, 'Children'));



%% Do the magic
% Select the given axes to be active
axes(hAxes);

% Hold on so we don't override anything existing
hold(hAxes, 'on');

% Switch the plot style
switch chPlotStyle
    case '3D'
        % Plot X, Y, Z three dimensionally
        hPlot3d = plot3(mPoses(:, 1), mPoses(:, 2), mPoses(:, 3));
        
        % Set specific line specs on the plot?
        if ~isempty(cLineSpec)
            set(hPlot3d, cLineSpec{:});
        end
        
        % In our own plot? Then we're free to add stuff as we want
        if bOwnPlot
            % Adjust the limits
%             axis(hAxes, 'tight');
%             xlim(hAxes, xlim().*1.05);
%             ylim(hAxes, ylim().*1.05);
%             zlim(hAxes, zlim().*1.05);
            
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
            
            % Adjust the view port
            view(vViewport);
            
            % Set a grid?
            if chGrid
                % Set grid on
                grid(hAxes, chGrid);
                % For minor grids we will also enable the "major" grid
                if strcmpi(chGrid, 'minor')
                    grid(hAxes, 'on');
                end
            end
        end
    case {'2DXY', '2DYX', '2DYZ', '2DZY', '2DXZ', '2DZX'}
        switch chPlotStyle
            case '2DXY'
                vIndex = [1, 2];
            case '2DYX'
                vIndex = [2, 1];
            case '2DYZ'
                vIndex = [2, 3];
            case '2DZY'
                vIndex = [3, 2];
            case '2DXZ'
                vIndex = [1, 3];
            case '2DZX'
                vIndex = [1, 3];
        end
        % Plot the 2d plot with defined columns as defined above
        hPlot2d = plot(mPoses(:, vIndex(1)), mPoses(:, vIndex(2)));
        
        % Set specific line specs on the plot?
        if ~isempty(cLineSpec)
            set(hPlot2d, cLineSpec);
        end
        
        % In our own plot? Then we're free to add stuff as we want
        if bOwnPlot
            % Adjust the limits
%             axis(hAxes, 'tight');
%             ylim(hAxes, ylim().*1.05);
            
            % Set x-axis label, if provided
            if chXLabel
                xlabel(hAxes, chXLabel);
            end
            % Set y-axis label, if provided
            if chYLabel
                ylabel(hAxes, chYLabel);
            end
            
            % Set a figure title?
            if chTitle
                title(hAxes, chTitle);
            end
            
            % Set a grid?
            if chGrid
                % Set grid on
                grid(hAxes, chGrid);
                % For minor grids we will also enable the "major" grid
                if strcmpi(chGrid, 'minor')
                    grid(hAxes, 'on');
                end
            end
        end
    case '2D'
        hPlot2d = plot(vTime, mPoses);
        
        if ~isempty(cLineSpec)
            set(hPlot2d, cLineSpec);
        end
        
        % In our own plot? Then we're free to add stuff as we want
        if bOwnPlot
            % Adjust the limits
%             axis(hAxes, 'tight');
%             ylim(hAxes, ylim().*1.05);
            
            % Set x-axis label, if provided
            if chXLabel
                xlabel(hAxes, chXLabel);
            end
            % Set y-axis label, if provided
            if chYLabel
                ylabel(hAxes, chYLabel);
            end
            
            % Set a figure title?
            if chTitle
                title(hAxes, chTitle);
            end
            
            % Set a grid?
            if chGrid
                % Set grid on
                grid(hAxes, chGrid);
                % For minor grids we will also enable the "major" grid
                if strcmpi(chGrid, 'minor')
                    grid(hAxes, 'on');
                end
            end
        end
    otherwise
end

% Finally, set the active axes handle to be the first most axes handle we
% have created or were given a parameter to this function
axes(hAxes);

% Enforce drawing of the image before returning anything
drawnow

% Clear the hold off the axes
hold(hAxes, 'off');



%% Assign output quantities
if nargout >= 1
    varargout{1} = hAxes;
end



end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = allAxes(h)

result = all(all(ishghandle(h))) && ...
         length(findobj(h,'type','axes','-depth',0)) == length(h);
end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
