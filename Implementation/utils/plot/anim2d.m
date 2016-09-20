function [varargout] = anim2d(X, Y, varargin)
% ANIM2D animates 2-dimensional data over time.
%
%   ANIM2D(X, Y) animates over the first dimension of X and Y the
%   corresponding items in the matrices. The values must be given in
%   absolute X and Y coordinates while there is no limitation on how much
%   data will be plotted. The inputs must follow a specific format for
%   proper rendering. Let X and Y be MxNxP matrices, then the dimensions
%   represent the following information
%       M:  Number of snapshots of the data at different time frames.
%       N:  Number of markers of each plot
%       P:  Number of different plots
%
%   Internally, ANIM2D uses a timer object that is bound to a new or a
%   given axes. The timer is called at specified periods and changes the
%   XData and YData properties of each child plot found in the axes.
%
%   BEWARE: The actual speed of animating your plot largely depends on the
%   amount of data being plotted, the speed of custom callback functions,
%   and the size and resolution of the figure. Small figure windows animate
%   much much more quickly than larger ones.
%
%   ANIM2D(X, Y, T) uses the time T to plot over. By default, 25 frames per
%   second are drawn thus the row of T closest to the current frame's time
%   is used to gather data from. Helpful to animate results of a simulation
%   with a variable step-size solver.
%
%   ANIM2D(X, Y, 'Name', 'Value', ...) plots with additional
%   name/value-arguments.
%
%   Inputs:
%
%   X       MxNxP matrix or MxN matrix of X-data of plots. Defines P lines
%       to be plotted with N nodes over at most M items.
%
%   Y       MxNxP matrix or MxN matrix of Y-data of plots. Defines P lines
%       to be plotted with N nodes over at most M items.
%
%   Optional Inputs -- specified as parameter value pairs
%
%   Fps         Number of frames per second to draw. This values is being
%       used for the timer's period. Defaults to 25.
%
%   Fun         Function to be used for plotting the data. By default,
%       'plot' will be used but this way, 'log' or 'stem' can be used to
%       plot ALL data (line-specific plot functions are not yet supported).
%
%   Time        Mx1 vector of time values to use. By default, this
%       function iterates over the first dimension of X and Y. If a time
%       vector is given, then the row with the value closest to the current
%       animation time is being used for animation. Additionally, this
%       value is passed to the title of the plot to display the progress.
%
%   StartFcn    Name of function or function handle that shall be called
%       after the figure is set up and before animation is started.
%       If you specify this property using a string, when MATLAB executes
%       the callback, it evaluates the MATLAB code contained in the string.
%       If you specify this property using a function handle, when MATLAB
%       executes the callback it passes the axes handle, the current time
%       step number, and the plot handle to the callback function.
%
%   StopFcn     Name of function or function handle that shall be called
%       after the figure is completely animated.
%       If you specify this property using a string, when MATLAB executes
%       the callback, it evaluates the MATLAB code contained in the string.
%       If you specify this property using a function handle, when MATLAB
%       executes the callback it passes the axes handle, the current time
%       step number, and the plot handle to the callback function.
%
%   UpdateFcn   Name of function or function handle that shall be called
%       after the animation is advanced to the next time step and the data
%       are drawn.
%       If you specify this property using a string, when MATLAB executes
%       the callback, it evaluates the MATLAB code contained in the string.
%       If you specify this property using a function handle, when MATLAB
%       executes the callback it passes the axes handle, the current time
%       step number, and the plot handle to the callback function.
%
%   See also TIMER



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-18
% ToDo:
%   * Line-specific plot-functions like 'plot' for 1:3, and 'stem' for 4:6'
% Changelog:
%   2016-09-18
%       * Change order of arguments for StartFcn, StopFcn, UpdateFcn from
%       (ax,idx,plt) to (ax,plt,idx)
%   2016-09-17
%       * Initial release



%% Define the input parser
ip = inputParser;

% Parse the provided inputs
varargin = [{X}, {Y}, varargin];
[haTarget, varargin, ~] = axescheck(varargin{:});

try
    % Required: X. Numeric. Matrix; Non-empty; Columns matches columns of
    % Y;
    valFcn_X = @(x) validateattributes(x, {'numeric'}, {'3d', 'nonempty', 'finite', 'size', size(Y)}, mfilename, 'X');
    addRequired(ip, 'X', valFcn_X);

    % Required: Y. Numeric. Matrix; Non-empty; Columns matches columns of
    % X;
    valFcn_Y = @(x) validateattributes(x, {'numeric'}, {'3d', 'nonempty', 'finite', 'size', size(X)}, mfilename, 'X');
    addRequired(ip, 'Y', valFcn_Y);

    % Optional: Time. Numeric. Vector; Non-empty; Increasing; Numel matches
    % numel X and Y;
    valFcn_Time = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector', 'increasing', 'finite', 'numel', size(X, 1)}, mfilename, 'Time');
    addOptional(ip, 'Time', [], valFcn_Time);

    % Parameter: FPS. Numeric. Non-empty; Scalar; Positive; Finite;
    valFcn_Fps = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'size', [1, 1], 'positive', 'finite'}, mfilename, 'Fps');
    addParameter(ip, 'Fps', 25, valFcn_Fps);

    % Parameter: Fun. Char or Function Handle. Non-empty;
    valFcn_Fun = @(x) validateattributes(x, {'char', 'function_handle'}, {'nonempty'}, mfilename, 'Fun');
    addParameter(ip, 'Fun', @plot, valFcn_Fun);
    
    % Parameter: StartFcn. Char. Function Handle. Non-empty;
    valFcn_StartFcn = @(x) validateattributes(x, {'char', 'function_handle'}, {'nonempty'}, mfilename, 'StartFcn');
    addParameter(ip, 'StartFcn', '', valFcn_StartFcn);
    
    % Parameter: StopFcn. Char. Function Handle. Non-empty;
    valFcn_StopFcn = @(x) validateattributes(x, {'char', 'function_handle'}, {'nonempty'}, mfilename, 'StopFcn');
    addParameter(ip, 'StopFcn', '', valFcn_StopFcn);
    
    % Parameter: UpdateFcn. Char. Function Handle. Non-empty;
    valFcn_UpdateFcn = @(x) validateattributes(x, {'char', 'function_handle'}, {'nonempty'}, mfilename, 'UpdateFcn');
    addParameter(ip, 'UpdateFcn', '', valFcn_UpdateFcn);

    % Configuration of input parser
    ip.KeepUnmatched = true;
    ip.FunctionName = mfilename;
    
    parse(ip, varargin{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results
% Matrix of X-data
aXData = ip.Results.X;
% Matrix of Y-data
aYData = ip.Results.Y;
% Vector of time
vTime = ip.Results.Time;
% If time is empty, we will just loop over the samples of X and Y
if isempty(vTime)
    vTime = 1:size(aXData,1);
    loLoopItems = true;
else
    loLoopItems = false;
end
% Frames per second
nFps = ip.Results.Fps;
% Custom plot functions
mxFun = ip.Results.Fun;

% Get start function callback handle
fhStartCallback = ip.Results.StartFcn;
% Check the start function handle is set and if it's a string, convert it
% to a function handle
if ~isempty(fhStartCallback)
    if ischar(fhStartCallback)
        chStartCallback = fhStartCallback;
        fhStartCallback = @(ax, plt, idx) eval(chStartCallback);
    end
else
    fhStartCallback = @(varargin) false;
end
% Get update function callback handle
fhDeleteCallback = ip.Results.UpdateFcn;
% Check the start function handle is set and if it's a string, convert it
% to a function handle
if ~isempty(fhDeleteCallback)
    if ischar(fhDeleteCallback)
        chDeleteCallback = fhDeleteCallback;
        fhDeleteCallback = @(ax, plt, idx) eval(chDeleteCallback);
    end
else
    fhDeleteCallback = @(varargin) false;
end
% Get delete function callback handle
fhUpdateCallback = ip.Results.UpdateFcn;
% Check the start function handle is set and if it's a string, convert it
% to a function handle
if ~isempty(fhUpdateCallback)
    if ischar(fhUpdateCallback)
        chUpdateCallback = fhUpdateCallback;
        fhUpdateCallback = @(ax, plt, idx) eval(chUpdateCallback);
    end
else
    fhUpdateCallback = @(varargin) false;
end

% Get a valid axes handle
haTarget = newplot(haTarget);



%% Create all data
% Collect all data we need into one struct that we will assign to the axes
stUserData = struct();
stUserData.DataCount = size(aXData, 3);
stUserData.Fun = mxFun;
stUserData.StartFcn = fhStartCallback;
stUserData.StopFcn = fhDeleteCallback;
stUserData.Time = vTime;
stUserData.UpdateFcn = fhUpdateCallback;
stUserData.XData = aXData;
stUserData.YData = aYData;

% If we loop over the items and draw them one by one, the mapping of frame
% to time is simple:
stUserData.Frame2Time = stUserData.Time;

% Time is given explicitely, so we need to find out what time index each
% frame corresponds to
if ~loLoopItems
    % Number of frames equals end of animation time multiplied by number of
    % frames
    nFrames = vTime(end)*nFps;
    % The time stamp assigned to each frame
    vFrameTime = ((1:nFrames) - 1)/nFps;
    % If the last frame does not represent the last snapshot of time, we
    % will append this one
    if vFrameTime(end) ~= vTime(end)
        vFrameTime(end+1) = vTime(end);
    end
    % Now, find the time index closest to each frame's time
    vFrame2Time = zeros(numel(vFrameTime) - 1, 1);
    for iFrame = 1:nFrames
        vFrame2Time(iFrame) = closest(vTime, vFrameTime(iFrame));
    end
    if vFrame2Time(end) ~= numel(vTime)
        vFrame2Time(end+1) = numel(vTime);
    end
    % And move the time correctly
    stUserData.Frame2Time = vFrame2Time;
end


% Assign user data to the axes
haTarget.UserData = stUserData;

% Create a timer object
tiUpdater = timer(...
    'ExecutionMode', 'fixedDelay' ...
    , 'Period', round(1000/nFps)/1000 ... % Just doing this so we don't get a warning about milliseconds being striped
    , 'StartFcn', @(timer, event) cb_timerstart(haTarget, timer, event) ...
    , 'StopFcn', @(timer, event) cb_timerend(haTarget, timer, event)...
    , 'TimerFcn', @(timer, event) cb_timerupdate(haTarget, timer, event) ...
    , 'TasksToExecute', numel(stUserData.Frame2Time) ... % Execute only as often as we have samples
);

% Create a close function on the current axis
haTarget.DeleteFcn = @cb_cleanup;

% Add the timer to the axes, too
haTarget.UserData.Timer = tiUpdater;



%% Assign outputs
if nargout > 0
    varargout{1} = tiUpdater;
end

% And start the timer
start(tiUpdater)


end


function cb_timerstart(ax, timer, event)
    try
        % Make the target axes active
        axes(ax);
        
        % Get the current axes' user data
        stUserData = ax.UserData;

        % Plot the first row of data
        stUserData.Plot = feval(stUserData.Fun, ax, squeeze(stUserData.XData(1,:,:)), squeeze(stUserData.YData(1,:,:)));

        % Hold on to the axes!
        hold(ax, 'on');
        
        % And save the user data back into it
        ax.UserData = stUserData;
        
        % Get the limits and fallback values
        vXLim = [min(min(min(ax.UserData.XData))), max(max(max(ax.UserData.XData)))];
        vYLim = [min(min(min(ax.UserData.YData))), max(max(max(ax.UserData.YData)))];
        if vXLim(1) == vXLim(2)
            vXLim = vXLim + [-0.5, 0.5];
        end
        if vYLim(1) == vYLim(2)
            vYLim = vYLim + [-0.5, 0.5];
        end

        % Set the limits to the min and max of the plot data ...
        axis(ax, [vXLim, vYLim]);
        % And then equalize the axes' aspect ratio
        axis(ax, 'square')
        % Set the axes limits to manual...
        axis(ax, 'manual');

        % Call the user supplied start callback
        ax.UserData.StartFcn(ax, ax.UserData.Plot, timer.TasksExecuted);
    catch me
        stop(timer)
        
        me = addCause(me, MException('PHILIPPTEMPEL:MATLAB_TOOLING:ANIM2D:AnimationStartFailed', 'Start of animation failed.'));
        throwAsCaller(me);
    end
    
    % That's it for the start
end


function cb_timerupdate(ax, timer, event)
    try
        % Make the target axes active
        axes(ax);
        
        % The axes children (ax.Children) can be accessed now and just need
        % their XData and YData, respectively, updated
        for iChild = 1:numel(ax.Children)
            set(ax.Children(iChild) ...
                , 'XData', squeeze(ax.UserData.XData(ax.UserData.Frame2Time(timer.TasksExecuted),:,iChild)) ...
                , 'YData', squeeze(ax.UserData.YData(ax.UserData.Frame2Time(timer.TasksExecuted),:,iChild)) ...
            );
        end

        % Call the user supplied update callback
        ax.UserData.UpdateFcn(ax, ax.UserData.Plot, timer.TasksExecuted);
    catch me
        stop(timer)
        
        me = addCause(me, MException('PHILIPPTEMPEL:MATLAB_TOOLING:ANIM2D:AnimationUpdateFailed', 'Update of animation failed at time step %i.', timer.TasksExecuted));
        throwAsCaller(me);
    end
end


function cb_timerend(ax, timer, event)
    try
        % Call the user supplied end/stop/delete callback
        ax.UserData.StopFcn(ax, ax.UserData.Plot, timer.TasksExecuted);

        % Let go off our axes
        hold(ax, 'off');

        % Try deleting the timer and removing it from the workspace
        try
            delete(timer);
            ax.UserData = rmfield(ax.UserData, 'Timer');
        catch me
            warning(me.identifier, me.message);
        end
    catch me
        stop(timer)
        
        me = addCause(me, MException('PHILIPPTEMPEL:MATLAB_TOOLING:ANIM2D:AnimationStopFailed', 'End of animation failed.'));
        throwAsCaller(me);
    end
end


function cb_cleanup(ax, event)
    % If the timer exists in the axes and is running, we will stop if
    if isfield(ax.UserData, 'Timer') && strcmp('on', ax.UserData.Timer.Running)
        stop(ax.UserData.Timer);
    end
end


%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
