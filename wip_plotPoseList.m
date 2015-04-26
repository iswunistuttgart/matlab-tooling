function varargout = plotPoseList(PoseList, varargin)



%% Define the input parser
ip = inputParser;

%%% Define validation methods
% Pose list must be validated to have 13 columns
valFcn_PoseList = @(x) ismatrix(x) && size(x, 2) == 13;
% Option to 'axes' must be a handle and also a 'axes' handle
valFcn_Axes = @(x) ishandle(x) && strcmp(get(x, 'type'), 'axes');
% Allow the plot style to be chosen
valFcn_PlotStyle = @(x) ischar(x) && any(strcmpi(x, {'Single2D', 'Single2D+3D', 'Multi2D', 'Multi2D+3D', '3D', '3D+Single2D', '3D+Multi2d'}));
% Integer to determine the column of time can be passed, too
valFcn_ColumnTime = @(x) isinteger(x) && x >= 0 && x < size(PoseList, 2);
% Columns of X, Y, and Z may be provided, too but must be a row vector of
% exactly three entries
valFcn_ColumnsXYZ = @(x) isrow(x) && issize(x, 1, 3);
% Validate the 3d viewport argument is correct
valFcn_Viewport3D = @(x) isrow(x) && isequal(size(x, 2), 2);
% Grid may be true, false, 1, 0, 'on', 'off', or 'minor'
valFcn_Grid = @(x) islogical(x) || ( isequal(x, 1) || isequal(x, 0) ) || any(strcmpi(x, {'on', 'off', 'minor'}));

%%% This fills in the parameters for the function
% We need the pose list
addRequired(ip, 'PoseList', valFcn_PoseList);
addOptional(ip, 'PlotStyle', '3D', valFcn_PlotStyle);
% % We allow the user to explicitley flag which algorithm to use
% addOptional(ip, 'Plot3d', false, @islogical);
% Allow options to be passed to the figure
addOptional(ip, 'Axes', gca, valFcn_Axes);
% Allow the figure to have user-defined properties
% addOptional(ip, 'FigureProperties', {}, @iscell);
% Allow the lines drawn to have user-defined properties
addOptional(ip, 'LineProperties', {}, @iscell);
% If time column should not be detected automatically, it may be set
% explicitely
addOptional(ip, 'ColumnTime', 0, valFcn_ColumnTime)
% Allow the columns of X, Y, and Z to be set explicitely, otherwise we are
% assuming them to be in columns [2, 3, 4]
addOptional(ip, 'ColumnsXYZ', [2, 3, 4], valFcn_ColumnsXYZ);
% User might want to change the 3D view port
addOptional(ip, 'Viewport3D', [-13, 10], valFcn_Viewport3D);
% Maybe the direction of the 3D-plot's trajectory is desired, too?
addOptional(ip, 'PlotDirection3D', false, @islogical);
% Allow user to choose grid style (either false 'on', 'off', or 'minor'
addOptional(ip, 'Grid', false, valFcn_Grid);

% Configuratio nfor the input parser
ip.KeepUnmatched = true;
ip.FunctionName = 'plotPoseList';

% Parse the provided inputs
parse(ip, PoseList, varargin{:});



%% Parse the variables for local
% This helps us in not having to write ```ip.Results.``` over and over
% again
mPoseList = ip.Results.PoseList;
cPlotStyle = lower(ip.Results.PlotStyle);
hAxes = ip.Results.Axes;
% clFigureProperties = ip.Results.FigureProperties;
clLineProperties = ip.Results.LineProperties;
% Set the column that keeps the time here
iColumnTime = ip.Results.ColumnTime;
% If column is set to 0, then we need to detect it automatically
if iColumnTime == 0
    iColumnTime = 1;
end
vColumnsXYZ = ip.Results.ColumnsXYZ;
v3DViewport = ip.Results.Viewport3D;
b3DPlotDireciton = ip.Results.PlotDirection3D;
chGrid = ip.Results.Grid;

% If this is a single plot i.e., the given axes does not have any children, then
% we are completely free at plotting stuff like labels, etc., Otherwise, we will
% really just plot the robot frame
bNewPlot = isempty(get(hAxes, 'Children'));



%% Automagic




%% Actual plotting
% Select the provided figure handle to be the active handle
axes(hAxes);

% Ensure we are not overriding any previously plotted data in the given axex
hold(hAxes, 'on');

%%% Plot the pose list, all commands furthermore passed to PLOTPOSELIST
%%% will be arguments to either plot3 or plot
switch cPlotStyle
    case 'single2d'
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ), clLineProperties{:});
        
        if bNewPlot
            ylim(hAxes, ylim().*1.05);
            xlabel('Time $t \left[ \rm s \right]$');
            ylabel('Position $\left[ \rm m \right]$');
            legend('$x$', '$y$', '$z$');
        end
    case 'single2d+3d'
        % Plot 3d
        subplot(2, 1, 2);
        plot3(mPoseList(:, vColumnsXYZ(1)), mPoseList(:, vColumnsXYZ(2)), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        if chGrid
            grid(hAxes, chGrid);
        end
        
        view(v3DViewport);
        
        % Plot [x, y, z] vs t
        subplot(2, 1, 1);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ), clLineProperties{:});
        
        ylim(hAxes, ylim().*1.05);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $\left[ \rm m \right]$');
        legend('$x$', '$y$', '$z$');
    case 'multi2d'
        % Plot x vs t
        subplot(3, 1, 1);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(1)), clLineProperties{:});
        
        ylim(hAxes, ylim().*1.05);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $x \left[ \rm m \right]$');
        
        % Plot y vs t
        subplot(3, 1, 2);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(2)), clLineProperties{:});
        
        ylim(hAxes, ylim().*1.05);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $y \left[ \rm m \right]$');
        
        % Plot z vs t
        subplot(3, 1, 3);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        
        ylim(hAxes, ylim().*1.05);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $z \left[ \rm m \right]$');
    case 'multi2d+3d'
        % Plot 3d
        subplot(2, 3, [4, 5, 6]);
        plot3(mPoseList(:, vColumnsXYZ(1)), mPoseList(:, vColumnsXYZ(2)), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        if chGrid
            grid(hAxes, chGrid);
        end
        
        view(v3DViewport);
        
        % Plot x vs t
        subplot(2, 3, 1);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(1)), clLineProperties{:});
        
        ylim(hAxes, ylim().*1.05);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $x \left[ \rm m \right]$');
        
        % Plot y vs t
        subplot(2, 3, 2);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(2)), clLineProperties{:});
        
        ylim(hAxes, ylim().*1.05);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $y \left[ \rm m \right]$');
        
        % Plot z vs t
        subplot(2, 3, 3);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        
        ylim(hAxes, ylim().*1.05);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $z \left[ \rm m \right]$');
    case '3d'
        % Plot 3d
        plot3(mPoseList(:, vColumnsXYZ(1)), mPoseList(:, vColumnsXYZ(2)), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        
        if b3DPlotDireciton
%             vIndexArrowStart = 1:(size(mPoseList(:, iColumnTime)) - 1);
%             vIndexArrowEnd = vIndexArrowStart + 1;
%             vArrowX = 0.5.*(mPoseList(vIndexArrowEnd, vColumnsXYZ(1)) - mPoseList(vIndexArrowStart, vColumnsXYZ(1)));
%             vArrowY = 0.5.*(mPoseList(vIndexArrowEnd, vColumnsXYZ(2)) - mPoseList(vIndexArrowStart, vColumnsXYZ(2)));
%             vArrowZ = 0.5.*(mPoseList(vIndexArrowEnd, vColumnsXYZ(3)) - mPoseList(vIndexArrowStart, vColumnsXYZ(3)));
            quiver3(mPoseList(:, vColumnsXYZ(1)), mPoseList(:, vColumnsXYZ(2)), mPoseList(:, vColumnsXYZ(3)), gradient(mPoseList(:, vColumnsXYZ(1))), gradient(mPoseList(:, vColumnsXYZ(2))), gradient(mPoseList(:, vColumnsXYZ(3))));
%             quiver3(mPoseList(vIndexArrowStart, vColumnsXYZ(1)), mPoseList(vIndexArrowStart, vColumnsXYZ(2)), mPoseList(vIndexArrowStart, vColumnsXYZ(3)), vArrowX, vArrowY, vArrowZ, 0);
        end
        
        xlim(hAxes, xlim().*1.05);
        ylim(hAxes, ylim().*1.05);
        zlim(hAxes, zlim().*1.05);
        
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        if chGrid
            grid(hAxes, chGrid);
        end
        
        view(v3DViewport);
    case '3d+single2d'
        % Plot 3d
        subplot(1, 2, 1);
        plot3(mPoseList(:, vColumnsXYZ(1)), mPoseList(:, vColumnsXYZ(2)), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        
        ylim(hAxes, ylim().*1.05);
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        if chGrid
            grid(hAxes, chGrid);
        end
        
        view(v3DViewport);
        
        % Plot [x, y, z] vs t
        subplot(1, 2, 2);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ), clLineProperties{:});
        
        ylim(hAxes, ylim().*1.05);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $\left[ \rm m \right]$');
        legend('$x$', '$y$', '$z$');
    case '3d+multi2d'
        % Plot 3d
        subplot(3, 2, [1, 3, 5]);
        plot3(mPoseList(:, vColumnsXYZ(1)), mPoseList(:, vColumnsXYZ(2)), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        if chGrid
            grid(hAxes, chGrid);
        end
        
        view(v3DViewport);
        
        % Plot x vs t
        subplot(3, 2, 2);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(1)), clLineProperties{:});
        
        ylim(hAxes, ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $x \left[ \rm m \right]$');
        
        % Plot y vs t
        subplot(3, 2, 4);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(2)), clLineProperties{:});
        
        ylim(hAxes, ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $y \left[ \rm m \right]$');
        
        % Plot z vs t
        subplot(3, 2, 6);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        
        ylim(hAxes, ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $z \left[ \rm m \right]$');
        
    otherwise
end

% And draw the image
drawnow;



%% Define return values

% First return value will be the handle to the figure
if nargout >= 1
    varargout{1} = hAxes;
end

end
