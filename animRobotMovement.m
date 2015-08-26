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
%   ROTATION: Matrix of Mx3 or Mx3x3 values which represent the alpha, beta, and
%   gamma angles or the rotation matrix respectively over the M time steps of
%   TIME. If given as [alpha, beta, gamma], a rotation of ZYX is applied to the
%   platform's cable attachment points
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
if ~isempty(varargin) && allAxes(Time)
    hAxes = Time;
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

% Require: Matrix of poses
% List of poses must be a matrix with as many columns as Time has rows
valFcn_Poses = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', size(Time, 1), 'ncols', 3}, mfilename, 'Position');
addRequired(ip, 'Position', valFcn_Poses);

% Require: Matrix of rotation
valFcn_Rotation = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', size(Time, 1), 'ncols', 3}, mfilename, 'Rotation');
addRequired(ip, 'Rotation', valFcn_Rotation);

% Require: Matrix of rotation
valFcn_AttachmentPoints = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'nonempty'}, mfilename, 'AttachmentPoints');
addRequired(ip, 'AttachmentPoints', valFcn_AttachmentPoints);

% % Let user decied on the plot style
% % Plot style can be chosen anything from the list below
% valFcn_PlotStyle = @(x) any(validatestring(x, {'2D', '2DXY', '2DYX', '2DYZ', '2DZY', '2DXZ', '2DZX', '3D'}, mfilename, 'PlotStyle'));
% addOptional(ip, 'PlotStyle', '2D', valFcn_PlotStyle);
% 
% % Let user decied on the plot spec
% valFcn_LineSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'LineSpec');
% addOptional(ip, 'LineSpec', {}, valFcn_LineSpec);
% 
% The 3d view may be defined, too
% Viewport may be 2, 3, [az, el], or [x, y, z]
valFcn_Viewport = @(x) validateattributes(x, {'numeric'}, {'row'}, mfilename, 'Viewport') || validateattributes(x, {'numeric'}, {'ncols', '>=', 2, 'ncols', '<=', 3}, mfilename, 'Viewport');
addOptional(ip, 'Viewport', [-13, 10], valFcn_Viewport);

% Allow user to choose grid style (either 'on', 'off', or 'minor')
valFcn_Grid = @(x) any(validatestring(x, {'on', 'off', 'minor'}, mfilename, 'Grid'));
addOptional(ip, 'Grid', 'off', valFcn_Grid);

% Allow user to enable/disable plotting a trace of the trajectory
valFcn_TraceTrajectory = @(x) any(validatestring(x, {'on', 'off', 'yes'}, mfilename, 'TraceTrajectory'));
addOptional(ip, 'TraceTrajectory', 'off', valFcn_TraceTrajectory);

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
addOptional(ip, 'Title', 'Time passed: $%0.3f$ $\\left[ \\mathrm{s} \\right]$', valFcn_Title);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, Time, Position, Rotation, AttachmentPoints, varargin{:});



%% Parse and prepare variables locally
% Vector of time
vTime = ip.Results.Time;
% Vector of poses
aPoses = ip.Results.Position;
% Matrix of Rotations
aRotations = ip.Results.Rotation;
% Get the cable attachment points
aAttachmentPoints = ip.Results.AttachmentPoints;
% New figure handle
if ~ishandle(hAxes)
    hFig = figure;
    hAxes = gca;
end
% New axes handle
hAxes = gca;
% General plot style
% chPlotStyle = upper(ip.Results.PlotStyle);
% Ensure we have the right given axes for the given plot style i.e., no 2D plot
% into a 3D axes, nor a 3D plot into a 2D axis
[az, el] = view(hAxes);
% if ~ ( isempty(regexp(chPlotStyle, '^2.*$', 'once')) || isequaln([az, el], [0, 90]) )
%     error('PHILIPPTEMPEL:plotRobotPoses:invalidAxesType', 'Given plot styles does not match provided axes type. Cannot plot a 2D image into a 3D plot.');
% end

% Plotting spec
% cLineSpec = ip.Results.LineSpec;
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
chTraceTrajectory = ip.Results.TraceTrajectory;

% Is this our own plot?
bOwnPlot = isempty(get(hAxes, 'Children'));



%% Set figure properties
% Only if its a seaprate plot and not a subplot
if bOwnPlot
    % Set viewport
    view(hAxes, mxdViewport)
    
    % Calculate the axes limits
    dMinX = 1.1*(min(aPoses(:, 1)) - abs(max(max(aAttachmentPoints))));
    dMaxX = 1.1*(max(aPoses(:, 1)) + abs(max(max(aAttachmentPoints))));
    dMinY = 1.1*(min(aPoses(:, 2)) - abs(max(max(aAttachmentPoints))));
    dMaxY = 1.1*(max(aPoses(:, 2)) + abs(max(max(aAttachmentPoints))));
    dMinZ = 1.1*(min(aPoses(:, 3)) - abs(max(max(aAttachmentPoints))));
    dMaxZ = 1.1*(max(aPoses(:, 3)) + abs(max(max(aAttachmentPoints))));
    
    % Set the axes limits
    set(hAxes, 'XLimMode', 'manual');
    set(hAxes, 'XLim', [dMinX dMaxX]);
    set(hAxes, 'YLimMode', 'manual');
    set(hAxes, 'YLim', [dMinY dMaxY]);
    set(hAxes, 'ZLimMode', 'manual');
    set(hAxes, 'ZLim', [dMinZ dMaxZ]);

    % Set a grid?
    if any(strcmp(chGrid, {'on', 'minor'}))
        % For minor grids we will also enable the "major" grid
        if strcmpi(chGrid, 'minor')
            grid(hAxes, 'on');
        end
        % Set grid on
        grid(hAxes, chGrid);
    end
    
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
end

% We will be plotting multiple objects, so we'll have to hold the plot
hold on;



%% Draw the actual movement
%%% Initialize the target plots
% Transformation group for the platform bounding box
hTargetGroupPlatform = hgtransform('Parent', hAxes);
% Plot for the trajectory trace
hTargetPlotTrajectory = plot3(NaN, NaN, NaN);
% Calculate the platform bounding box
[aInitialAttachmentPointsBoundingBox, aInitialAttachmentPointsBoundingBoxFaces] = boundingbox3(aAttachmentPoints(1, :), aAttachmentPoints(2, :), aAttachmentPoints(3, :));
% Patch of the platform
hTargetPlotPlatform = patch('Faces', aInitialAttachmentPointsBoundingBoxFaces, 'Vertices', aInitialAttachmentPointsBoundingBox, 'FaceColor', 'none');
set(hTargetPlotPlatform, 'Parent', hTargetGroupPlatform);
% Create the title handle
hTitle = title(hAxes, 'Initializing...');
set(hTitle, 'Interpreter', 'latex');

% Time counter to pace the drawing
dTimeStart = tic;
dMaxAnimationTime = vTime(end);

% Step over the simulation time
for iTime = 1:1:size(vTime)
    % Adjust the title to display the current time
    if bOwnPlot
        set(hTitle, 'String', sprintf(chTitle, vTime(iTime)));
    end
    % Extract the current pose and rotation
    vCurrentPose = aPoses(iTime, :)';
    aCurrentRotation = aRotations(iTime, :);
    
    % Make a transformation matrix given the current pose (i.e., shift) and
    % rotation to be used with the hgtransform group
%     aTransformationPlatform = makehgtform('translate', vCurrentPose)*...
%         makehgtform('zrotate', aCurrentRotation(3))*...
%         makehgtform('yrotate', aCurrentRotation(2))*...
%         makehgtform('xrotate', aCurrentRotation(1));
%     
%     % Apply the calculated transformation to the platform
%     set(hTargetGroupPlatform, 'Matrix', aTransformationPlatform);
    
    % Calculate the position of each cable attachment's actual position
    aCurrentRotation = rotz(rad2deg(aCurrentRotation(3)))*roty(rad2deg(aCurrentRotation(2)))*rotx(rad2deg(aCurrentRotation(1)));
    aCurrentAttachmentPointsBoundingBox = transpose(repmat(vCurrentPose, 1, size(aAttachmentPoints, 2)) + aCurrentRotation*transpose(aInitialAttachmentPointsBoundingBox));
    % And update the platform patch to a new position
    set(hTargetPlotPlatform, ...
        'Vertices', aCurrentAttachmentPointsBoundingBox);
    
    % Plot the path of the trajectory that has passed so far (if requested)
    if any(strcmp(chTraceTrajectory, {'on', 'yes'}))
        set(hTargetPlotTrajectory, 'XData', aPoses(1:iTime, 1), 'YData', aPoses(1:iTime, 2), 'ZData', aPoses(1:iTime, 3));
    end
    
    % Pacer to draw only at a rate of about 30 frames per second
    if toc(dTimeStart) > 1/30
%         drawnow update;
        drawnow;
        
        dTimeStart = tic;
    end
end



%% Assign output quantities


end

function result = allAxes(h)

result = all(all(ishghandle(h))) && ...
         length(findobj(h,'type','axes','-depth',0)) == length(h);

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
