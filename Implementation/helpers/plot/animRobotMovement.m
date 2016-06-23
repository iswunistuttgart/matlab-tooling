function [varargout] = animRobotMovement(Time, Position, Rotation, AttachmentPoints, varargin)
% ANIMROBOTMOVEMENT Animates the robot movement over time
% 
%   ANIMROBOTMOVEMENT(TIME, POSITION, ROTATION) animates the movement of the
%   robot over the given time with respect to its position and rotation.
%   
%   Inputs:
%   
%   TIME: Column vector of increasing values representing the timestamps at wich
%   the poses and rotations are gathered
%   
%   POSITION: Matrix of position in tuple of [x, y, z] per time step in TIME of
%   the platform center of gravity
%   
%   ROTATION: Matrix of Tx3 or Tx3x3 values which represent the alpha, beta, and
%   gamma angles or the rotation matrix respectively over the T time steps of
%   TIME. If given as [alpha, beta, gamma], a rotation of ZYX is applied to the
%   platform's cable attachment points
%
%   ANCHORPOINTS: Matrix of 3xM points that represent the platforms cable
%   attachment points given per column
%
%   See also: VIEW, PLOT, PLOT3, LINESPEC, GRID, TITLE, XLABEL, YLABEL, ZLABEL,
%   AXIS
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-05-01
% Changelog:
%   2016-05-01
%       * Update function ```inferCurrentRotation``` to use EUL2ROTM and
%       QUAT2ROTM instead of manually typed code
%   2016-03-29
%       * Code cleanup
%   2015-09-02
%       * Add option 'Axis' to allow setting the axis to either 'tight',
%       'equal', or anything else supported by >> axis
%       * Code cleanup
%   2015-04-26
%       * Introduce options 'XLabel', 'YLabel', 'ZLabel', 'Title'. Also fix the
%       logic behind {'WinchLabels', true} so we won't have duplicate code for
%       doing basically the same thing just in a different way.
%       * Change all to have column major i.e., one column is a logical unit
%       whereas between columns, the "thing" might change. That means, given the
%       winches, if we look at one column, we see the data of one winch, whereas
%       if we looked at the first row, we can read info on the x-values of all
%       winches
%   2015-04-24
%       * Initial release



%% Preprocess inputs (allows to have the axis defined as first argument)
% By default we don't have any axes handle
haAxes = false;
% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && isallaxes(Time)
    haAxes = Time;
    Time = Position;
    Position = Rotation;
    Rotation = AttachmentPoints;
    AttachmentPoints = varargin{1};
    varargin = varargin(2:end);
end



%% Parse the input
% Define the input parser
ip = inputParser;

% Require: Time column vector
% Time must be an increasing column vector
valFcn_Time = @(x) validateattributes(x, {'numeric'}, {'vector', 'column', 'increasing'}, mfilename, 'Time');
addRequired(ip, 'Time', valFcn_Time);

% Require: Matrix of positions
% List of poses must be a matrix with as many columns as Time has rows
valFcn_Poses = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', size(Time, 1), 'ncols', 3}, mfilename, 'Position');
addRequired(ip, 'Position', valFcn_Poses);

% Require: Matrix of rotation
valFcn_Rotation = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', size(Time, 1)}, mfilename, 'Rotation');
addRequired(ip, 'Rotation', valFcn_Rotation);

% Require: Matrix of rotation
valFcn_AttachmentPoints = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'nonempty'}, mfilename, 'AttachmentPoints');
addRequired(ip, 'AttachmentPoints', valFcn_AttachmentPoints);

% The 3d view may be defined, too
% Viewport may be 2, 3, [az, el], or [x, y, z]
valFcn_Viewport = @(x) validateattributes(x, {'logical', 'numeric'}, {'2d'}, mfilename, 'Viewport');
addOptional(ip, 'Viewport', [-13, 10], valFcn_Viewport);

% Allow user to choose grid style (either 'on', 'off', or 'minor')
valFcn_Grid = @(x) any(validatestring(x, {'on', 'off', 'minor'}, mfilename, 'Grid'));
addOptional(ip, 'Grid', 'off', valFcn_Grid);

% Allow user to enable/disable plotting a trace of the trajectory
valFcn_TraceTrajectory = @(x) any(validatestring(x, {'on', 'off', 'yes'}, mfilename, 'TraceTrajectory'));
addOptional(ip, 'TraceTrajectory', 'off', valFcn_TraceTrajectory);

% Require: Matrix of rotation
valFcn_SaveAs = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'SaveAs');
addOptional(ip, 'SaveAs', '', valFcn_SaveAs);

% Allow user to set the xlabel ...
valFcn_XLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'XLabel');
addOptional(ip, 'XLabel', '', valFcn_XLabel);

% Allow user to set the ylabel ...
valFcn_YLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'YLabel');
addOptional(ip, 'YLabel', '', valFcn_YLabel);

% And allow user to set the zlabel
valFcn_ZLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'ZLabel');
addOptional(ip, 'ZLabel', '', valFcn_ZLabel);

% And allow user to set the axis
valFcn_Axis = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Axis');
addOptional(ip, 'Axis', '', valFcn_Axis);

% Maybe a title is provided and shall be plotted, too?
valFcn_Title = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Title');
addOptional(ip, 'Title', 'Time passed: $%0.3f$ $\\left[ \\mathrm{s} \\right]$', valFcn_Title);

% Allow user to choose the FPS by liking
valFcn_Fps = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'positive', 'finite'}, mfilename, 'Fps');
adddOptional(ip, 'Fps', 25, valFcn_Fps);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, Time, Position, Rotation, AttachmentPoints, varargin{:});



%% Parse and prepare variables locally
% Vector of time
vTime = ip.Results.Time;
% Vector of poses
aPositions = ip.Results.Position;
% Matrix of Rotations
aRotations = ip.Results.Rotation;
% Get the cable attachment points
aAttachmentPoints = ip.Results.AttachmentPoints;
% New figure handle
if ~ishandle(haAxes)
    hFig = figure;
    haAxes = gca;
end
% New axes handle
haAxes = gca;
% Is this our own plot?
bOwnPlot = isempty(get(haAxes, 'Children'));
% Ensure we have the right given axes for the given plot style i.e., no 2D plot
% into a 3D axes, nor a 3D plot into a 2D axis
% [az, el] = view(haAxes);
% if ~ ( isempty(regexp(chPlotStyle, '^2.*$', 'once')) || isequaln([az, el], [0, 90]) )
%     error('PHILIPPTEMPEL:plotRobotPoses:invalidAxesType', 'Given plot styles does not match provided axes type. Cannot plot a 2D image into a 3D plot.');
% end

% 3D viewport (only used for 3d plot style)
mxdViewport = ip.Results.Viewport;
% Grid options
chGrid = ip.Results.Grid;
% Get the desired figure title (works only in standalone mode)
chTitle = ip.Results.Title;
% Get provided axes labels
chXLabel = ip.Results.XLabel;
chYLabel = ip.Results.YLabel;
chZLabel = ip.Results.ZLabel;
% Trajectory tracing
chTraceTrajectory = inCharToValidArgument(ip.Results.TraceTrajectory);
% Axis configuration
chAxis = ip.Results.Axis;
% Save as
chMovieFilename = ip.Results.SaveAs;
bSaveMovie = ~isempty(chMovieFilename);
bMovieFileOpen = false;
% Get the frames per second from the parsed input
nFramesPerSecond = ip.Results.Fps;

% Number of wires
nNumberOfWires = size(aAttachmentPoints, 2);



%% Set figure properties
% Only if its a seaprate plot and not a subplot
if bOwnPlot
    % Set viewport
    view(haAxes, mxdViewport)
    
    % Set the axis
    if ~isempty(strtrim(chAxis))
        axis(chAxis)
    end
    
    % Calculate the axes limits
    dMinX = 1.1*(min(aPositions(:, 1)) - abs(max(max(aAttachmentPoints))));
    dMaxX = 1.1*(max(aPositions(:, 1)) + abs(max(max(aAttachmentPoints))));
    dMinY = 1.1*(min(aPositions(:, 2)) - abs(max(max(aAttachmentPoints))));
    dMaxY = 1.1*(max(aPositions(:, 2)) + abs(max(max(aAttachmentPoints))));
    dMinZ = 1.1*(min(aPositions(:, 3)) - abs(max(max(aAttachmentPoints))));
    dMaxZ = 1.1*(max(aPositions(:, 3)) + abs(max(max(aAttachmentPoints))));
    
    % Set the axes limits
    set(haAxes, 'XLimMode', 'manual');
    set(haAxes, 'XLim', [dMinX dMaxX]);
    set(haAxes, 'YLimMode', 'manual');
    set(haAxes, 'YLim', [dMinY dMaxY]);
    set(haAxes, 'ZLimMode', 'manual');
    set(haAxes, 'ZLim', [dMinZ dMaxZ]);
    axes(haAxes, 'equal');

    % Set a grid?
    if any(strcmp(chGrid, {'on', 'minor'}))
        % Set grid on
        grid(haAxes, 'on');
    end
    
    % For minor grids we will also enable the "major" grid
    if strcmpi(chGrid, 'minor')
        grid(haAxes, 'on');
    end
    
    % Set x-axis label, if provided
    if ~isempty(strtrim(chXLabel))
        xlabel(haAxes, chXLabel);
    end
    % Set y-axis label, if provided
    if ~isempty(strtrim(chYLabel))
        ylabel(haAxes, chYLabel);
    end
    % Set z-axis label, if provided
    if ~isempty(strtrim(chZLabel))
        zlabel(haAxes, chZLabel);
    end
end

% We will be plotting multiple objects, so we'll have to hold the plot
hold on;



%% Open the video file if requested
% Save a movie?
if bSaveMovie
    % Create a new video writer
    writerObj = VideoWriter(sprintf('%s.mp4', chMovieFilename), 'MPEG-4');
    
    % Cleanup function to properly close the movie object
    haCleanup = @(x) iif(bMovieFileOpen, close(writerObj), true, true);
    
    % Set the framerate to 25fps
    writerObj.FrameRate = 25;
    % Try opening the file, if it fails we will not save the video but display
    % an message
    try
        open(writerObj);
        bMovieFileOpen = true;
    catch me
        display(me.message);
        bMovieFileOpen = false;
    end
    
    % Set the figure ration to 16:9 for videos
    setfigureratio('16:9');
% Not going to save a movie
else
    % Set figure ration to 4:3
    setfigureratio('4:3');
end

% Set some properties so that the can be recorded nicely
if bMovieFileOpen
    % Set the font size to 16 for all
    set(gca, 'FontSize', 16, 'LineWidth', 0.66);
    set(hFig, 'Color', 'w');
end



%% Draw the actual movement
%%% Initialize the target plots
% Plot for the trajectory trace
hTargetPlotTrajectory = plot3(NaN, NaN, NaN);
% Calculate the platform bounding box
[aInitialAttachmentPointsBoundingBox, aInitialAttachmentPointsBoundingBoxFaces] = bbox3(aAttachmentPoints(1,:), aAttachmentPoints(2,:), aAttachmentPoints(3,:));
% Patch of the platform
hTargetPlotPlatform = patch('Faces', aInitialAttachmentPointsBoundingBoxFaces, 'Vertices', aInitialAttachmentPointsBoundingBox, 'FaceColor', 'none');
% Create the title handle
hTitle = title(haAxes, 'Initializing...');
set(hTitle, 'Interpreter', 'latex');

% Code optimization because we need this lateron in form [b1, b2, ...]
aInitialAttachmentPointsBoundingBox = transpose(aInitialAttachmentPointsBoundingBox);

% Time counter to pace the drawing
% dTimeStart = tic;
dMaxAnimationTime = vTime(end);

% Get the vector of frames we need to extract
vFramesTime = 0:1/nFramesPerSecond:dMaxAnimationTime;
vFrames = zeros(numel(vFramesTime), 1);

% This might also work as a vectorized function call
for iFrameTime = 1:numel(vFramesTime)
    vDiff = abs(vTime - vFramesTime(iFrameTime));
    vFrames(iFrameTime) = find(vDiff == min(vDiff), 1, 'first');
end

% Initialize variable for trajectory tracking
nFirstFrame = 1;

% Step over the simulation time
for iFrame = 1:1:size(vFrames)
    nFrame = vFrames(iFrame);
    % Adjust the title to display the current time
    if bOwnPlot
        set(hTitle, 'String', sprintf(chTitle, vTime(nFrame)));
    end
    
    % Extract the current position and rotation
    vCurrentPosition = aPositions(nFrame,:)';
    aCurrentRotation = aRotations(nFrame,:);
    
    % Convert the rotation of the platform given from the rotation data we
    % extracted from aRotations
    aCurrentRotation = inferCurrentRotation(aCurrentRotation);
    
    % Adjust the bounding box of the attachment points given the current
    % rotation (the 8 comes because it's a 3D plot thus the bounding box has 8
    % corners).
    aCurrentAttachmentPointsBoundingBox = transpose(repmat(vCurrentPosition, 1, 8) + aCurrentRotation*aInitialAttachmentPointsBoundingBox);
    
    % And update the platform patch to a new position
    set(hTargetPlotPlatform, ...
        'Vertices', aCurrentAttachmentPointsBoundingBox);
    
    % Plot the path of the trajectory that has passed so far (if requested)
    if strcmp(chTraceTrajectory, 'on')
        nLastFrame = nFrame;
        % We only want to plot the last 4 seconds of the trajectory, so adjust
        % the first frame counter accordingly
        if iFrame > 4*nFramesPerSecond
            nFirstFrame = vFrames(iFrame - 4*nFramesPerSecond);
        end
        set(hTargetPlotTrajectory, 'XData', aPositions(nFirstFrame:nLastFrame,1), 'YData', aPositions(nFirstFrame:nLastFrame,2), 'ZData', aPositions(nFirstFrame:nLastFrame,3));
    end
    
    % Draw the figure handle now
    drawnow;

    % If the video file was successfully opened, we can save the current frame
    % to the video
    if bMovieFileOpen
        frame = getframe(hFig);
        writeVideo(writerObj, frame);
    end
end

% Movie done, so we can close the video object
if bMovieFileOpen
    % Close the writer object
    close(writerObj);
    % And ensure the local variable is aware of the file having been closed
    bMovieFileOpen = false;
end



%% Assign output quantities


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


function CurrentRotation = inferCurrentRotation(CurrentRotation)

switch numel(CurrentRotation)
    case 3
        vEuler = [CurrentRotation(3), CurrentRotation(2), CurrentRotation(1)];
        CurrentRotation = eul2rotm(vEuler, 'ZYX');
        CurrentRotation(abs(CurrentRotation) < 2*eps) = 0;
    case 4
        CurrentRotation = quat2rotm(CurrentRotation);
    case 9
        CurrentRotation = rotrow2m(CurrentRotation);
    otherwise
        CurrentRotation = eye(3);
end
    
end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
