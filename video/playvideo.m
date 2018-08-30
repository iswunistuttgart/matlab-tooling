function varargout = playvideo(v, varargin)
% PLAYVIDEO plays a video from file or VideoReader object
%
%   PLAYVIDEO(V) plays the video V in a new figure
%
%   PLAYVIDEO(V, 'Name', 'Value', ...) allows setting optional inputs using
%   name/value pairs.
%
%   T = PLAYVIDEO(V) returns a timer object T that can be used to start, stop,
%   delete video playback.
%
%   Inputs:
%
%   V                   Char of video file name or a VideoReader object.
%
%   Optional Inputs -- specified as parameter value pairs
%
%   Fps                 Frame rate per second to use for video display. Must no
%                       match the frame rate of the video, in this case the
%                       closest frame in time will be chosen.
%
%   See also:
%   VIDEOREADER TIMER TIMER/START



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-08-26
% Changelog:
%   2018-08-26
%       * Initial release



%% Validate arguments
ip = inputParser;

% Video
valFcn_Video = @(x) validateattributes(x, {'char', 'VideoReader'}, {'nonempty'}, mfilename, 'Video');
addRequired(ip, 'Video', valFcn_Video);

% Frames per second
valFcn_Fps = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'positive', 'finite', 'nonnan', 'nonsparse'}, mfilename, 'Fps');
addParameter(ip, 'Fps', 25, valFcn_Fps);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

try
  % PLAYVIDEO(V)
  % PLAYVIDEO(V, Name, Value, ...)
  narginchk(1, Inf);
  
  % PLAYVIDEO(V)
  % T = PLAYVIDEO(V)
  nargoutchk(0, 1);
  
  % Squish arguments
  varargin = [{v}, varargin];
  
  % Grab an axes handle from the arguments
  [haTarget, args, ~] = axescheck(varargin{:});
  
  % And parse arguments
  ip.parse(args{:});
catch me
  throwAsCaller(me);
end



%% Parse inputs
% Video object
if isa(ip.Results.Video, 'char')
  vrVideo = VideoReader(ip.Results.Video);
else
  vrVideo = ip.Results.Video;
end
% Frame rate
nFps = ip.Results.Fps;
% Get a valid axes handle
haTarget = newplot(haTarget);



%% Process video
% Build the time vector
vTime = 0:1/nFps:vrVideo.Duration;

% Make sure the last time value does not exceed the video duration
vTime(end) = min([vTime(end), vrVideo.Duration]);

% Number of time steps
nTime = numel(vTime);

% Timer object that will update the video figure
tiUpdater = timer(...
      'ExecutionMode', 'fixedDelay' ...
    , 'Period', round(1000/nFps)/1000 ... % Just doing this so we don't get a warning about milliseconds being striped
    , 'StartDelay', 1 ... % Just so that the StartFcn can actually change the drawing
    , 'StartFcn', @cb_timerstart ...
    , 'TimerFcn', @cb_timerupdate ...
    , 'StopFcn', @cb_timerend ...
    , 'TasksToExecute', nTime ... % Execute only as often as we have samples
    , 'UserData', struct( ...
        'VideoReader', vrVideo ...
      , 'Axes', haTarget ...
      , 'Timestamp', vTime ...
      , 'HImshow', [] ...
    ) ...
);



%% Assign output quantities
if nargout == 0
  start(tiUpdater);
end

if nargout > 0
  varargout{1} = tiUpdater;
end


end


function cb_timerstart(t, e)
% Get user data
stUD = t.UserData;
% Set time of video
stUD.VideoReader.CurrentTime = 0;

% Display the video
stUD.HImshow = imshow(stUD.VideoReader.readFrame() ...
  , 'Parent', stUD.Axes ...
);

% Axes title
title(stUD.Axes, sprintf('%.4f', 0));

% Update userdata
t.UserData = stUD;

% Update drawing
drawnow limitrate

end


function cb_timerupdate(t, e)
% Get user data
stUD = t.UserData;
% Set time of video
stUD.VideoReader.CurrentTime = stUD.Timestamp(t.TasksExecuted);

% Only continue if there is a valid axes handle
if ishandle(stUD.Axes)
  % Update video frame
  stUD.HImshow.CData = stUD.VideoReader.readFrame();

  % Axes title
  stUD.Axes.Title.String = sprintf('%.4f', stUD.VideoReader.CurrentTime);

  % Update drawing
  drawnow limitrate
% No valid axes handle
else
  % => Stop timer
  stop(t);
end

end


function cb_timerend(t, e)
% Get user data
stUD = t.UserData;
% Set time of video
stUD.VideoReader.CurrentTime = stUD.Timestamp(t.TasksExecuted);

% Only continue if there is a valid axes handle
if ishandle(stUD.Axes)
  % Display the video
  stUD.HImshow.CData = stUD.VideoReader.readFrame();

  % Axes title
  stUD.Axes.Title.String = sprintf('%.4f', stUD.VideoReader.CurrentTime);

  % Update drawing
  drawnow limitrate
end

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
