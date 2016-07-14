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
%       2DTX    plot [X] against T
%       2DTY    plot [Y] against T
%       2DTZ    plot [Z] against T
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
%   PLOTROBOTPOSES(TIME, POSES, 'Viewport', viewport, ...) adjusts the
%   viewport of the 3d plot to the set values. Allowed values are 2, 3, [az,
%   el], or [x, y, z]. See documentation of view for more info. Only works in
%   standalone mode.
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
%   PLOTROBOTPOSES(TIME, POSES, 'Box', Box, ...) sets the state on the plot box.
%
%   PLOTROBOTPOSES(TIME, POSES, 'Title', Title, ...) puts a title on the figure.
%   Only works in standalone mode.
%
%   PLOTROBOTPOSES(TIME, POSES, 'TitleSpec', TitleSpec, ...) allows for setting
%   custom properties on the title by providing a cell array compliant with text
%   properties.
%
%   PLOTROBOTPOSES(TIME, POSES, 'XLabel', XLabel, ...) sets the x-axis label to
%   the specified char. Only works in standalone mode.
%
%   PLOTROBOTPOSES(TIME, POSES, 'YLabel', YLabel, ...) sets the y-axis label to
%   the specified char. Only works in standalone mode.
%
%   PLOTROBOTPOSES(TIME, POSES, 'ZLabel', ZLabel, ...) sets the z-axis label to
%   the specified char. Only works in standalone mode.
%
%   PLOTROBOTPOSES(TIME, POSES, 'Animate', Toggle, ...) animates the movement
%   over time in a real-time like feel. Speed can be adjusted by 'Fps'. Toggle
%   can be any value of the valid ones {'on', 'off', 'yes', 'no', 'please'}.
%
%   PLOTROBOTPOSES(TIME, POSES, 'Fps', Fps, ...) animate the movement with a
%   different frames per seconds setting. Defaults to 25. Must be larger or
%   equal to 1.
%
%   PLOTROBOTPOSES(TIME, POSES, 'TraceTrajectory', Toggle, ...) traces the
%   trajectory over the last 4 seconds. Only works for animations. Toggle can be
%   any value of the valid ones {'on', 'off', 'yes', 'no', 'please'}.
%
%   PLOTROBOTPOSES(TIME, POSES, 'TraceTrajectoryLength', Length, ...) traces the
%   trajectory over the last LENGTH seconds instead of the default 4. Only works
%   for animations. Must be larger than 0.
%
%   PLOTROBOTPOSES(TIME, POSES, 'VideoSave', Toggle, ...) saves the video to a
%   a file. Toggle can be any value of the valid ones {'on', 'off', 'yes', 'no',
%   'please'}.
%
%   PLOTROBOTPOSES(TIME, POSES, 'VideoFilename', Filename, ...) saves the video
%   to the given filename. If none is given, the current timestamp will be
%   chosen formatted to 'yyyymmdd_HHMMSSFFF' e.g., '20160330_172556671'
%   
%   PLOTROBOTPOSES(AX, TIME, POSES, ...) plots the poses into the specified
%   axes.
%
%   PLOTROBOTPOSES(TS, ...) plots the poses given in the timeseries object TS.
%
%   PLOTROBOTPOSES(STRUCT, ...) plots the poses given in the struct object
%   STRUCT which must have the fields 'Time', and 'Pose'
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
%   See also: VIEW, PLOT, PLOT3, LINESPEC, GRID, TITLE, XLABEL, YLABEL, ZLABEL,
%   DATESTR
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-07-14
% Changelog:
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%   2016-04-01
%       * More code cleanup
%   2016-03-30
%       * Code cleanup
%   2015-04-26
%       * Introduce options 'XLabel', 'YLabel', 'ZLabel', 'Title'. Also fix the
%       logic behind {'WinchLabels', true} so we won't have duplicate code for
%       doing basically the same thing in a different way.
%       * Change all inputs to have column major i.e., one column is a logical
%       unit whereas between columns, the "thing" might change. That means,
%       given the winches, if we look at one column, we see the data of one
%       winch, whereas if we looked at the first row, we can read info on the
%       x-values of all winches
%   2015-04-24:
%       * Initial release



%% Preprocess inputs (allows to have the axis defined as first argument)
% By default we don't have any axes handle
hAxes = false;
% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && isallaxes(Time)
    hAxes = Time;
    Time = Poses;
    Poses = varargin{1};
    varargin = varargin(2:end);
end

% Check if Time is of type timeseries, then we will extract information from
% there
if isa(Time, 'timeseries')
    Poses = Time.Data(:,1:3);
    Time = Time.Time;
% Check if time might be a struct, then we will get the information from there
elseif isa(Time, 'struct')
    assert(isfield(Time, 'Time') && isfield(Time, 'Pose'), 'Struct provided does not contain required fields ''Time'' and ''Pose''');
    Poses = Time.Pose(:,1:3);
    Time = Time.Time;
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

% Let user decide on the plot style
% Plot style can be chosen anything from the list below
valFcn_PlotStyle = @(x) any(validatestring(x, {'2D', '2DTX', '2DTY', '2DTZ', '2DXY', '2DYX', '2DYZ', '2DZY', '2DXZ', '2DZX', '3D'}, mfilename, 'PlotStyle'));
addOptional(ip, 'PlotStyle', '2D', valFcn_PlotStyle);

% Let user decied on the plot spec
valFcn_LineSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'LineSpec');
addOptional(ip, 'LineSpec', {}, valFcn_LineSpec);

% The 3d view may be defined, too
% Viewport may be 2, 3, [az, el], or [x, y, z]
valFcn_Viewport = @(x) validateattributes(x, {'numeric'}, {'row'}, mfilename, 'Viewport') || validateattributes(x, {'numeric'}, {'ncols', '>=', 2, 'ncols', '<=', 3}, mfilename, 'Viewport');
addOptional(ip, 'Viewport', [-13, 10], valFcn_Viewport);

% Allow user to choose whether a figure bounding box should be plotted
valFcn_Box = @(x) any(validatestring(x, {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'Box'));
addOptional(ip, 'Box', 'off', valFcn_Box);

% Allow user to choose grid style (either 'on', 'off', or 'minor')
valFcn_Grid = @(x) any(validatestring(x, {'on', 'off', 'yes', 'no', 'please', 'minor'}, mfilename, 'Grid'));
addOptional(ip, 'Grid', 'off', valFcn_Grid);

% Allow user to set the xlabel ...
valFcn_XLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'XLabel');
addOptional(ip, 'XLabel', '', valFcn_XLabel);

% Allow user to set properties of the xlabel ...
valFcn_XLabelSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'XLabelSpec');
addOptional(ip, 'XLabelSpec', {}, valFcn_XLabelSpec);

% Allow user to set the ylabel ...
valFcn_YLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'YLabel');
addOptional(ip, 'YLabel', '', valFcn_YLabel);

% Allow user to set properties of the ylabel ...
valFcn_YLabelSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'YLabelSpec');
addOptional(ip, 'YLabelSpec', {}, valFcn_YLabelSpec);

% And allow user to set the zlabel
valFcn_ZLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'ZLabel');
addOptional(ip, 'ZLabel', '', valFcn_ZLabel);

% Allow user to set properties of the zlabel ...
valFcn_ZLabelSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'ZLabelSpec');
addOptional(ip, 'ZLabelSpec', {}, valFcn_ZLabelSpec);

% Maybe a title is provided and shall be plotted, too?
valFcn_Title = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Title');
addOptional(ip, 'Title', '', valFcn_Title);

% Allow user to set properties of the title ...
valFcn_TitleSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'TitleSpec');
addOptional(ip, 'TitleSpec', {}, valFcn_TitleSpec);

% Allow user to enable/disable animate movement rather than getting a complete plot
valFcn_Animate = @(x) any(validatestring(x, {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'Animate'));
addOptional(ip, 'Animate', 'off', valFcn_Animate)

% Allow user to set the frames per second manually
valFcn_Fps = @(x) validateattributes(x, {'double'}, {'nonempty', 'scalar', 'positive', 'finite'}, mfilename, 'Fps');
addOptional(ip, 'Fps', 25, valFcn_Fps);

% Allow user to enable/disable plotting a trace of the trajectory
valFcn_TraceTrajectory = @(x) any(validatestring(x, {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'TraceTrajectory'));
addOptional(ip, 'TraceTrajectory', 'off', valFcn_TraceTrajectory);

% Length of the traced trajectory may be adjusted
valFcn_TraceTrajectoryLength = @(x) validateattributes(x, {'double'}, {'nonempty', 'scalar', 'positive', 'finite'}, mfilename, 'TraceTrajectoryLength');
addOptional(ip, 'TraceTrajectoryLength', 4, valFcn_TraceTrajectoryLength);

% Allow user to enable/disable saving of video to file
valFcn_SaveVideo = @(x) any(validatestring(x, {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'VideoSave'));
addOptional(ip, 'VideoSave', 'off', valFcn_SaveVideo);

% Allow user to specify the filename that the file shall have
valFcn_VideoFilename = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'VideoFilename');
addOptional(ip, 'VideoFilename', '', valFcn_VideoFilename);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    parse(ip, Time, Poses, varargin{:});
catch me
    throw(MException(me.identifier, me.message));
end



%% Parse and prepare variables locally
% Vector of time
vTime = ip.Results.Time;
% Vector of poses
mPoses = ip.Results.Poses;
% Axes handle
if ~ishandle(hAxes)
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
ceLineSpec = ip.Results.LineSpec;
% 3D viewport (only used for 3d plot style)
vViewport = ip.Results.Viewport;
% Grid options
if strcmp(ip.Results.Grid, 'minor')
    chGrid = ip.Results.Grid;
else
    chGrid = inCharToValidArgument(ip.Results.Grid);
end
% Get the desired figure title (works only in standalone mode)
chTitle = ip.Results.Title;
ceTitleSpec = ip.Results.TitleSpec;
% Get provided x-axis label
chXLabel = ip.Results.XLabel;
% and the specs for the x-axis label
ceXLabelSpec = ip.Results.XLabelSpec;
% Get provided y-axis label
chYLabel = ip.Results.YLabel;
% and the specs for the y-axis label
ceYLabelSpec = ip.Results.YLabelSpec;
% Get provided z-axis label
chZLabel = ip.Results.ZLabel;
% and the specs for the z-axis label
ceZLabelSpec = ip.Results.ZLabelSpec;
% Box option
chBox = inCharToValidArgument(ip.Results.Box);
% Animate toggle
chAnimate = inCharToValidArgument(ip.Results.Animate);
% Animation speed / fps
nFps = str2double(ip.Results.Fps);
% Trajectory tracing
chTraceTrajectory = inCharToValidArgument(ip.Results.TraceTrajectory);
% Trajectory tracing length
dTraceTrajectoryLength = str2double(ip.Results.TraceTrajectoryLength);
% Save video?
chVideoSave = inCharToValidArgument(ip.Results.VideoSave);
% Video filename
chVideoFilename = ip.Results.VideoFilename;
% Holds a flag whether the video file could successfully be opened or not
bVideoFileOpen = false;
% If no filename is given but a video is to be saved, we will get the filename
% from the current time as yyyymmdd_HHMMSSFFF
if strcmp('on', chVideoSave) && isempty(chVideoFilename)
    chVideoFilename = datestr(now, 'yyyymmdd_HHMMSSFFF');
end

% Is this our own plot?
bOwnPlot = isempty(get(hAxes, 'Children'));



%% Do the magic
% Select the given axes to be active
axes(hAxes);

% Hold on so we don't overwrite anything existing
hold(hAxes, 'on');

% Switch the plot style
switch chPlotStyle
    case '3D'
        % Plot X, Y, Z three dimensionally
        hPlot3d = plot3(mPoses(:, 1), mPoses(:, 2), mPoses(:, 3));
        
        % Set custom line specs on the plot?
        if ~isempty(ceLineSpec)
            set(hPlot3d, ceLineSpec{:});
        end
        
        % In our own plot? Then we're free to add stuff as we want
        if bOwnPlot
            % Adjust the limits
%             axis(hAxes, 'tight');
%             xlim(hAxes, xlim().*1.05);
%             ylim(hAxes, ylim().*1.05);
%             zlim(hAxes, zlim().*1.05);
            
            % Set x-axis label, if provided
            if ~isempty(strtrim(chXLabel))
                hXLabel = xlabel(hAxes, chXLabel);
                
                if ~isempty(ceXLabelSpec)
                    set(hXLabel, ceXLabelSpec{:});
                end
            end
            % Set y-axis label, if provided
            if ~isempty(strtrim(chYLabel))
                hYLabel = ylabel(hAxes, chYLabel);
                
                if ~isempty(ceYLabelSpec)
                    set(hYLabel, ceYLabelSpec{:});
                end
            end
            % Set z-axis label, if provided
            if ~isempty(strtrim(chZLabel))
                hZLabel = zlabel(hAxes, chZLabel);
                
                if ~isempty(ceZLabelSpec)
                    set(hZLabel, ceZLabelSpec{:});
                end
            end
            
            % Set a figure title?
            if ~isempty(strtrim(chTitle))
                hTitle = title(hAxes, chTitle);
                
                if ~isempty(ceTitleSpecs)
                    set(hTitle, ceTitleSpec{:});
                end
            end
            
            % Adjust the view port
            view(vViewport);
            
            % Set a grid?
            if any(strcmp(chGrid, {'on', 'minor'}))
                % Set grid on
                grid(hAxes, chGrid);
                % For minor grids we will also enable the "major" grid
                if strcmpi(chGrid, 'minor')
                    grid(hAxes, 'on');
                end
            end
            
            % Print a box?
            if strcmp(chBox, 'on')
                box on;
            end
        end
    case {'2DXY', '2DYZ', '2DZX', '2DYX', '2DZY', '2DXZ'}
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
        hPlot2d = plot(mPoses(:,vIndex(1)), mPoses(:,vIndex(2)));
        
        % Set custom line specs on the plot?
        if ~isempty(ceLineSpec)
            set(hPlot2d, ceLineSpec);
        end
        
        % In our own plot? Then we're free to add stuff as we want
        if bOwnPlot
            % Adjust the limits
%             axis(hAxes, 'tight');
%             ylim(hAxes, ylim().*1.05);
            
            % Set x-axis label, if provided
            if ~isempty(strtrim(chXLabel))
                hXLabel = xlabel(hAxes, chXLabel);
                
                if ~isempty(ceXLabelSpec)
                    set(hXLabel, ceXLabelSpec{:});
                end
            end
            % Set y-axis label, if provided
            if ~isempty(strtrim(chYLabel))
                hYLabel = ylabel(hAxes, chYLabel);
                
                if ~isempty(ceYLabelSpec)
                    set(hYLabel, ceYLabelSpec{:});
                end
            end
            % Set z-axis label, if provided
            if ~isempty(strtrim(chZLabel))
                hZLabel = zlabel(hAxes, chZLabel);
                
                if ~isempty(ceZLabelSpec)
                    set(hZLabel, ceZLabelSpec{:});
                end
            end
            
            % Set a figure title?
            if ~isempty(strtrim(chTitle))
                hTitle = title(hAxes, chTitle);
                
                if ~isempty(ceTitleSpecs)
                    set(hTitle, ceTitleSpec{:});
                end
            end
            
            % Set a grid?
            if any(strcmp(chGrid, {'on', 'minor'}))
                % Set grid on
                grid(hAxes, chGrid);
                % For minor grids we will also enable the "major" grid
                if strcmpi(chGrid, 'minor')
                    grid(hAxes, 'on');
                end
            end
            
            % Print a box?
            if strcmp(chBox, 'on')
                box on;
            end
        end
    case {'2D', '2DTX', '2DTY', '2DTZ'}
        switch chPlotStyle
            case '2D'
                vIndex = [1, 2, 3];
            case '2DTX'
                vIndex = 1;
            case '2DTY'
                vIndex = 2;
            case '2DTZ'
                vIndex = 3;
        end
        % Plot t-vs-{something} where something can be [x], [y], [z], or all of
        % them
        hPlot2d = plot(vTime, mPoses(:,vIndex));
        
        % Set custom line specs on the plot?
        if ~isempty(ceLineSpec)
            set(hPlot2d, ceLineSpec);
        end
        
        % In our own plot? Then we're free to add stuff as we want
        if bOwnPlot
            % Adjust the limits
%             axis(hAxes, 'tight');
%             ylim(hAxes, ylim().*1.05);
            
            % Set x-axis label, if provided
            if ~isempty(strtrim(chXLabel))
                hXLabel = xlabel(hAxes, chXLabel);
                
                if ~isempty(ceXLabelSpec)
                    set(hXLabel, ceXLabelSpec{:});
                end
            end
            % Set y-axis label, if provided
            if ~isempty(strtrim(chYLabel))
                hYLabel = ylabel(hAxes, chYLabel);
                
                if ~isempty(ceYLabelSpec)
                    set(hYLabel, ceYLabelSpec{:});
                end
            end
            % Set z-axis label, if provided
            if ~isempty(strtrim(chZLabel))
                hZLabel = zlabel(hAxes, chZLabel);
                
                if ~isempty(ceZLabelSpec)
                    set(hZLabel, ceZLabelSpec{:});
                end
            end
            
            % Set a figure title?
            if ~isempty(strtrim(chTitle))
                hTitle = title(hAxes, chTitle);
                
                if ~isempty(ceTitleSpecs)
                    set(hTitle, ceTitleSpec{:});
                end
            end
            
            % Set a grid?
            if any(strcmp(chGrid, {'on', 'minor'}))
                % Set grid on
                grid(hAxes, 'on');
            end
            
            % For minor grids we will also enable the "minor" grid
            if strcmpi(chGrid, 'minor')
                grid(hAxes, 'minor');
            end
            
            % Print a box?
            if strcmp(chBox, 'on')
                box on;
            end
        end
    otherwise
        error('Requested unsupported plot style. Exiting!');
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
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
