function varargout = plotRobotTrajectory(Time, Poses, varargin)



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

% Axes may be given, too, as always, so that we could add the trajectory to the
% frame and winch plot or pose list plot
% Option to 'axes' must be a handle and also a 'axes' handle
valFcn_Axes = @(x) validateattributes(x, {'handle', 'matlab.graphics.axis.Axes'}, {}, mfilename, 'Axes');
addOptional(ip, 'Axes', false, valFcn_Axes);

% Let user decied on the plot style
% Plot style can be chosen anything from the list below
valFcn_PlotStyle = @(x) any(validatestring(x, {'2D', '2DXY', '2DYX', '2DYZ', '2DZY', '2DXZ', '2DZX', '3D'}, mfilename, 'PlotStyle'));
addOptional(ip, 'PlotStyle', '2D', valFcn_PlotStyle);

% Let user decied on the plot properties
valFcn_PlotProperties = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'PlotProperties');
addOptional(ip, 'PlotProperties', {}, valFcn_PlotProperties);

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
ip.FunctionName = 'plotRobotTrajectory';

% Parse the provided inputs
parse(ip, Time, Poses, varargin{:});



%% Parse and prepare variables locally
% Vector of time
vTime = ip.Results.Time;
% Vector of poses
mPoses = ip.Results.Poses;
% Axes handle
hAxes = ip.Results.Axes;
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
    error('PHILIPPTEMPEL:plotRobotTrajectory:invalidAxesType', 'Given plot styles does not match provided axes type. Cannot plot a 2D image into a 3D plot.');
end

% Plotting properties
cPlotProperties = ip.Results.PlotProperties;
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
        
        % Set specific properties on the plot?
        if ~isempty(cPlotProperties)
            set(hPlot3d, cPlotProperties{:});
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
        
        % Set specific properties on the plot?
        if ~isempty(cPlotProperties)
            set(hPlot2d, cPlotProperties);
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
        
        if ~isempty(cPlotProperties)
            set(hPlot2d, cPlotProperties);
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
