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
%   EvenX       Switch to toggle even x-axis extension 'on' or 'off'. If 'EvenX'
%       is 'on' then the by magnitude larger x-axis limit is projected onto the
%       other one. For example, xlims of [-3, 4] will become [-4, 4].
%
%   Fps         Number of frames per second to draw. This values is being
%       used for the timer's period. Defaults to 25.
%
%   Fun         Function to be used for plotting the data. By default,
%       'plot' will be used but this way, 'log' or 'stem' can be used to
%       plot ALL data (line-specific plot functions are not yet supported).
%
%   MarkStart   Switch to mark the first row of the plotted data. This can be
%       useful to e.g., highlight the initial condition. Defaults to 'off'. Can
%       be 'on' or 'off'.
%
%   Time        Mx1 vector of time values to use. By default, this
%       function iterates over the first dimension of X and Y. If a time
%       vector is given, then the row with the value closest to the current
%       animation time is being used for animation. Additionally, this
%       value is passed to the title of the plot to display the progress.
%
%   Title       String to be displayed in the title. Can also be set to 'timer'
%       to enable automatic rendering of the time in the axes' title. If a
%       user-specific string is provided, it will be passed to `sprintf` where
%       the current time is being parsed as first argument, the current frame
%       index as second.
%
%   StartFcn    String or function handle that shall be called after the
%       animation is set up and before it is started.
%       If you specify this property using a string, when MATLAB executes
%       the callback, it evaluates the MATLAB code contained in the string. This
%       code has access to the variables 'ax', 'plt', and 'idx' representing the
%       target axes, the plot object, and the current frame index, respectively.
%       If you specify this property using a function handle, when MATLAB
%       executes the callback it passes the axes handle, the current time
%       step number, and the plot handle to the callback function.
%       If you specify this property as a cell array, you can make combinations
%       of strings or function handles as you like.
%
%   StopFcn     String or function handle that shall be called after the
%       animation has stopped.
%       If you specify this property using a string, when MATLAB executes
%       the callback, it evaluates the MATLAB code contained in the string. This
%       code has access to the variables 'ax', 'plt', and 'idx' representing the
%       target axes, the plot object, and the current frame index, respectively.
%       If you specify this property using a function handle, when MATLAB
%       executes the callback it passes the axes handle, the current time
%       step number, and the plot handle to the callback function.
%       If you specify this property as a cell array, you can make combinations
%       of strings or function handles as you like.
%
%   UpdateFcn   String or function handle that shall be called after the
%       animation is updated at each frame.
%       If you specify this property using a string, when MATLAB executes
%       the callback, it evaluates the MATLAB code contained in the string. This
%       code has access to the variables 'ax', 'plt', and 'idx' representing the
%       target axes, the plot object, and the current frame index, respectively.
%       If you specify this property using a function handle, when MATLAB
%       executes the callback it passes the axes handle, the current time
%       step number, and the plot handle to the callback function.
%       If you specify this property as a cell array, you can make combinations
%       of strings or function handles as you like.
%
%   See also TIMER
%
%   Known Bugs:
%
%   Due to some weird behavior (of feval probably) the order of plots is changed
%       i.e., X(:,:,1) is plot into plt(n) while X(:,:,n) is plot into plt(1).
%       This is a bit unexpected behavior if you want to adjust the lines
%       styles, colors, or markers. However, this behavior cannot be reproduced
%       in standalone code so it is unclear where exactly it is coming from.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-10-14
% TODO:
%   * Line-specific plot-functions like 'plot' for 1:3, and 'stem' for 4:6'
% Changelog:
%   2016-10-14
%       * Fix wrong name/value pair description in help
%       * Fix error when removing field `Timer` in timer end callback
%   2016-09-21
%       * Update 'StartFcn', 'UpdateFcn', and 'StopFcn' to support cell arrays
%       of function handles. This way, multiple functions can be called at the
%       same time (for as long as cellfun is "at the same time") allowing better
%       anonymous function inclusion
%       * Add support for displaying a title on the axes
%       * Add support for automatically displaying the initial state with dashed
%       lines
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

    % Parameter: EvenX. Char. Matches {'on', 'off', 'yes' 'no'}.
    valFcn_EvenX = @(x) any(validatestring(lower(x), {'on', 'yes', 'off', 'no'}, mfilename, 'EvenX'));
    addParameter(ip, 'EvenX', 'off', valFcn_EvenX);

    % Parameter: FPS. Numeric. Non-empty; Scalar; Positive; Finite;
    valFcn_Fps = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'size', [1, 1], 'positive', 'finite'}, mfilename, 'Fps');
    addParameter(ip, 'Fps', 25, valFcn_Fps);

    % Parameter: Fun. Char; Function Handle. Non-empty;
    valFcn_Fun = @(x) validateattributes(x, {'char', 'cell', 'function_handle'}, {'nonempty'}, mfilename, 'Fun');
    addParameter(ip, 'Fun', @plot, valFcn_Fun);

    % Parameter: MarkStart. Char. Matches {'on', 'off', 'yes' 'no'}.
    valFcn_MarkStart = @(x) any(validatestring(lower(x), {'on', 'yes', 'off', 'no'}, mfilename, 'MarkStart'));
    addParameter(ip, 'MarkStart', 'off', valFcn_MarkStart);
    
    % Parameter: StartFcn. Charl Function Handle. Non-empty;
    valFcn_StartFcn = @(x) validateattributes(x, {'char', 'cell', 'function_handle'}, {'nonempty'}, mfilename, 'StartFcn');
    addParameter(ip, 'StartFcn', {}, valFcn_StartFcn);
    
    % Parameter: StopFcn. Char; Function Handle. Non-empty;
    valFcn_StopFcn = @(x) validateattributes(x, {'char', 'cell', 'function_handle'}, {'nonempty'}, mfilename, 'StopFcn');
    addParameter(ip, 'StopFcn', {}, valFcn_StopFcn);

    % Parameter: Title. Char. Non-empty;
    valFcn_Title = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Title');
    addParameter(ip, 'Title', '', valFcn_Title);
    
    % Parameter: UpdateFcn. Char. Function Handle. Non-empty;
    valFcn_UpdateFcn = @(x) validateattributes(x, {'char', 'cell', 'function_handle'}, {'nonempty'}, mfilename, 'UpdateFcn');
    addParameter(ip, 'UpdateFcn', {}, valFcn_UpdateFcn);

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
try
    ceStartCallbacks = in_parseCallbacks(ip.Results.StartFcn, 'StartFcn');
catch me
    throwAsCaller(me);
end;

% Get update function callback handle
try
    ceUpdateCallbacks = in_parseCallbacks(ip.Results.UpdateFcn, 'UpdateFcn');
catch me
    throwAsCaller(me);
end;

% Get start function callback handle
try
    ceStopCallbacks = in_parseCallbacks(ip.Results.StopFcn, 'StopFcn');
catch me
    throwAsCaller(me);
end

% Even x-axis?
chEvenX = parseswitcharg(ip.Results.EvenX);
% Title of the axis
chTitle = ip.Results.Title;
% Mark start?
chMarkStart = parseswitcharg(ip.Results.MarkStart);
% Get a valid axes handle
haTarget = newplot(haTarget);



%% Create all data
% Collect all data we need into one struct that we will assign to the axes
stUserData = struct();
stUserData.DataCount = size(aXData, 3);
stUserData.EvenX = chEvenX;
stUserData.Fun = mxFun;
stUserData.InitialPlot = [];
stUserData.MarkStart = chMarkStart;
stUserData.StartFcn = ceStartCallbacks;
stUserData.StopFcn = ceStopCallbacks;
stUserData.Time = vTime;
stUserData.Title = '';
if strcmpi('timer', chTitle)
    stUserData.TitleString = 'Time: %.2f';
else
    stUserData.TitleString = chTitle;
end
stUserData.UpdateFcn = ceUpdateCallbacks;
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
    , 'StartDelay', 1 ... % Just so that the StartFcn can actually change the drawing
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
% If no return arguments are wanted
if nargout == 0
    % Start the timer
    start(tiUpdater)
end

% If return arguments are wanted, this function will return the timer so the
% user can/must start it manually
if nargout > 0
    varargout{1} = tiUpdater;
end


end


function cb_timerstart(ax, timer, event)
    try
        % Make the target axes active
%         axes(ax);
        
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
        % If no x-axis limits are given, we wil make some of our own
        if vXLim(1) == vXLim(2)
            vXLim = vXLim + [-1, +1];
        end
        % If no Y-axis limits are given, we will make some of our own
        if vYLim(1) == vYLim(2)
            vYLim = vYLim + [-1, +1];
        end
        
        % Force even x-axis limits?
        if strcmp('on', ax.UserData.EvenX)
            vXLim = max(abs(vXLim)).*[-1, 1];
        end

        % Set the limits to the min and max of the plot data ...
        axis(ax, [vXLim, vYLim]);
        % And then equalize the axes' aspect ratio
        axis(ax, 'square')
        % Set the axes limits to manual...
        axis(ax, 'manual');
        
        % Set the title, if any title is given
        if ~isempty(ax.UserData.TitleString)
            ax.UserData.Title = title(ax, sprintf(ax.UserData.TitleString, ax.UserData.Time(ax.UserData.Frame2Time(1))));
        end

        % Call the user supplied start callback(s) (we do not rely on cellfun as
        % we do not know in what order the functions will be executed and the
        % user might want to have their callbacks executed in a particular
        % order).
        % @see http://stackoverflow.com/questions/558478/how-to-execute-multiple-statements-in-a-matlab-anonymous-function#558868
        for iSF = 1:numel(ax.UserData.StartFcn)
            ax.UserData.StartFcn{iSF}(ax, ax.Children(1:ax.UserData.DataCount), timer.TasksExecuted);
        end
        
        % Mark the initial plot?
        if strcmp('on', stUserData.MarkStart)
            % Copy the plot objects quickly
            stUserData.InitialPlot = copyobj(ax.Children, ax);
            % Adjust all 'initial state' objects to be dashed lines
            set(ax.Children((stUserData.DataCount + 1):end), 'LineStyle', '--');
        end
        
        % Update figure
        drawnow
    catch me
        stop(timer)
        
        throwAsCaller(addCause(me, MException('PHILIPPTEMPEL:MATLAB_TOOLING:ANIM2D:AnimationStartFailed', 'Start of animation failed.')));
    end
    
    % That's it for the start
end


function cb_timerupdate(ax, timer, event)
    try
        % Update the XData and YData of each of the children but only over the
        % data we have (this way we won't be looping of possible start or end
        % plots of the data)`
        for iChild = 1:ax.UserData.DataCount
            set(ax.Children(iChild) ...
                , 'XData', squeeze(ax.UserData.XData(ax.UserData.Frame2Time(timer.TasksExecuted),:,iChild)) ...
                , 'YData', squeeze(ax.UserData.YData(ax.UserData.Frame2Time(timer.TasksExecuted),:,iChild)) ...
            );
        end
        
        % Update the title
        if ~isempty(ax.UserData.Title)
            ax.UserData.Title.String = sprintf(ax.UserData.TitleString, ax.UserData.Time(ax.UserData.Frame2Time(timer.TasksExecuted)));
        end
        
        % Call the user supplied update callback(s)
        for iSF = 1:numel(ax.UserData.UpdateFcn)
            ax.UserData.UpdateFcn{iSF}(ax, ax.Children(1:ax.UserData.DataCount), timer.TasksExecuted);
        end
        
        % Update figure
        drawnow
    catch me
        stop(timer)
        
        throwAsCaller(addCause(me, MException('PHILIPPTEMPEL:MATLAB_TOOLING:ANIM2D:AnimationUpdateFailed', 'Update of animation failed at time step %i.', timer.TasksExecuted)));
    end
end


function cb_timerend(ax, timer, event)
    try
        % Call the user supplied end/stop/delete callback
        for iSF = 1:numel(ax.UserData.StopFcn)
            ax.UserData.StopFcn{iSF}(ax, ax.Children(1:ax.UserData.DataCount), timer.TasksExecuted);
        end
        
        % Update figure
        drawnow

        % Let go off our axes
        hold(ax, 'off');

        % Try deleting the timer and removing it from the workspace
        try
            delete(timer);
            if isfield(ax.UserData, 'Timer')
                ax.UserData = rmfield(ax.UserData, 'Timer');
            end
        catch me
            warning(me.identifier, me.message);
        end
    catch me
        stop(timer)
        
        throwAsCaller(addCause(me, MException('PHILIPPTEMPEL:MATLAB_TOOLING:ANIM2D:AnimationStopFailed', 'End of animation failed.')));
    end
end


function cb_cleanup(ax, event)
    % If the timer exists in the axes and is running, we will stop if
    if isfield(ax.UserData, 'Timer') && strcmp('on', ax.UserData.Timer.Running)
        stop(ax.UserData.Timer);
    end
end


function ceCallbacks = in_parseCallbacks(ceCallbackArgs, Type)

% Default start callback: Does nothing
ceCallbacks = {@(ax, plt, idx) false};

if ~isempty(ceCallbackArgs)
    ceCallbacks = cell(size(ceCallbackArgs));
    % If given as a cell...
    if iscell(ceCallbackArgs)
        % Loop over every callback and check its a char or function_handle;
        for iFh = 1:numel(ceCallbackArgs)
            if ~ ( ischar(ceCallbackArgs{iFh}) || isa(ceCallbackArgs{iFh}, 'function_handle') )
                throwAsCaller(MException('PHILIPPTEMPEL:MATLAB_TOOLING:ANIM2D:InvalidStartFcn', 'All %s callbacks must be char or function_handle.', Type));
            end

            % Convert char functions to actual callable functions
            if ischar(ceCallbackArgs{iFh})
                ceCallbacks{iFh} = @(ax, plt, idx) eval(ceCallbackArgs{iFh});
            % Move function_handles right to the return value
            else
                ceCallbacks{iFh} = ceCallbackArgs{iFh};
            end
        end
    % Not a cell, then make it one
    else
        ceCallbacks = {ceCallbackArgs};
    end
end

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
