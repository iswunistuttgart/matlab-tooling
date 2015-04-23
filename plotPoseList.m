function varargout = plotPoseList(PoseList, varargin)



%% Define the input parser
ip = inputParser;

%%% Define validation methods
% Pose list must be validated to have 13 columns
valFcn_PoseList = @(x) ismatrix(x) && size(x, 2) == 13;
% Figure handles may be provided but only if they are a valid figure handle
% (duh)
valFcn_FigureHandle = @(x) ishandle(x) && strcmp(get(x, 'type'), 'figure');
% Allow the plot style to be chosen
valFcn_PlotStyle = @(x) ischar(x) && any(strcmpi(x, {'Single2D', 'Single2D+3D', 'Multi2D', 'Multi2D+3D', '3D', '3D+Single2D', '3D+Multi2d'}));
% Integer to determine the column of time can be passed, too
valFcn_ColumnTime = @(x) isinteger(x) && x >= 0 && x < size(PoseList, 2);
% Columns of X, Y, and Z may be provided, too but must be a row vector of
% exactly three entries
valFcn_ColumnsXYZ = @(x) isrow(x) && issize(x, 1, 3);
% Validate the 3d viewport argument is correct
valFcn_Viewport3D = @(x) isrow(x) && isequal(size(x, 2), 2);

%%% This fills in the parameters for the function
% We need the pose list
addRequired(ip, 'PoseList', valFcn_PoseList);
addOptional(ip, 'PlotStyle', '3D', valFcn_PlotStyle);
% % We allow the user to explicitley flag which algorithm to use
% addOptional(ip, 'Plot3d', false, @islogical);
% Allow options to be passed to the figure
% addOptional(ip, 'FigureHandle', false, valFcn_FigureHandle);
% Allow the figure to have user-defined properties
addOptional(ip, 'FigureProperties', {}, @iscell);
% Allow the lines drawn to have user-defined properties
addOptional(ip, 'LineProperties', {}, @iscell);
% If time column should not be detected automatically, it may be set
% explicitely
addOptional(ip, 'ColumnTime', 0, valFcn_ColumnTime)
% Allow the columns of X, Y, and Z to be set explicitely, otherwise we are
% assuming them to be in columns [2, 3, 4]
addOptional(ip, 'ColumnsXYZ', [2, 3, 4], valFcn_ColumnsXYZ);
% User might want to change the 3D view port
addOptional(ip, 'Viewport3D', [-20, 6], valFcn_Viewport3D);
% Maybe the direction of the 3D-plot's trajectory is desired, too?
addOptional(ip, 'PlotDirection3D', false, @islogical);

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
% bPlot3d = ip.Results.Plot3d;
clFigureProperties = ip.Results.FigureProperties;
clLineProperties = ip.Results.LineProperties;
% Check the figure handle provided (if a logical value
% if ishandle(ip.Results.FigureHandle)
%     hFig = ip.Results.FigureHandle;
% % if islogical(ip.Results.FigureHandle) && ~ip.Results.FigureHandle
%     hFig = figure;
% else
%     hFig = ip.Results.FigureHandle;
% end
hFig = figure;
% Set the column that keeps the time here
iColumnTime = ip.Results.ColumnTime;
% If column is set to 0, then we need to detect it automatically
if iColumnTime == 0
    iColumnTime = 1;
end
vColumnsXYZ = ip.Results.ColumnsXYZ;
v3DViewport = ip.Results.Viewport3D;
b3DPlotDireciton = ip.Results.PlotDirection3D;



%% Automagic



%% Actual plotting
% Select the provided figure handle to be the active handle
figure(hFig);

%%% Plot the pose list, all commands furthermore passed to PLOTPOSELIST
%%% will be arguments to either plot3 or plot
switch cPlotStyle
    case 'single2d'
        plot(NaN, NaN);
        hold on;
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ), clLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $\left[ \rm m \right]$');
        legend('$x$', '$y$', '$z$');
    case 'single2d+3d'
        % Plot 3d
        subplot(2, 1, 2);
        plot3(mPoseList(:, vColumnsXYZ(1)), mPoseList(:, vColumnsXYZ(2)), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        axis('tight')
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        grid on;
        view(v3DViewport);
        
        % Plot [x, y, z] vs t
        subplot(2, 1, 1);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ), clLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $\left[ \rm m \right]$');
        legend('$x$', '$y$', '$z$');
    case 'multi2d'
        % Plot x vs t
        subplot(3, 1, 1);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(1)), clLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $x \left[ \rm m \right]$');
        
        % Plot y vs t
        subplot(3, 1, 2);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(2)), clLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $y \left[ \rm m \right]$');
        
        % Plot z vs t
        subplot(3, 1, 3);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $z \left[ \rm m \right]$');
    case 'multi2d+3d'
        % Plot 3d
        subplot(2, 3, [4, 5, 6]);
        plot3(mPoseList(:, vColumnsXYZ(1)), mPoseList(:, vColumnsXYZ(2)), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        axis('tight')
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        grid on;
        view(v3DViewport);
        
        % Plot x vs t
        subplot(2, 3, 1);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(1)), clLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $x \left[ \rm m \right]$');
        
        % Plot y vs t
        subplot(2, 3, 2);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(2)), clLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $y \left[ \rm m \right]$');
        
        % Plot z vs t
        subplot(2, 3, 3);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $z \left[ \rm m \right]$');
    case '3d'
        % Plot 3d
        plot3(mPoseList(:, vColumnsXYZ(1)), mPoseList(:, vColumnsXYZ(2)), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        if b3DPlotDireciton
            hold on
%             vIndexArrowStart = 1:(size(mPoseList(:, iColumnTime)) - 1);
%             vIndexArrowEnd = vIndexArrowStart + 1;
%             vArrowX = 0.5.*(mPoseList(vIndexArrowEnd, vColumnsXYZ(1)) - mPoseList(vIndexArrowStart, vColumnsXYZ(1)));
%             vArrowY = 0.5.*(mPoseList(vIndexArrowEnd, vColumnsXYZ(2)) - mPoseList(vIndexArrowStart, vColumnsXYZ(2)));
%             vArrowZ = 0.5.*(mPoseList(vIndexArrowEnd, vColumnsXYZ(3)) - mPoseList(vIndexArrowStart, vColumnsXYZ(3)));
            quiver3(mPoseList(:, vColumnsXYZ(1)), mPoseList(:, vColumnsXYZ(2)), mPoseList(:, vColumnsXYZ(3)), gradient(mPoseList(:, vColumnsXYZ(1))), gradient(mPoseList(:, vColumnsXYZ(2))), gradient(mPoseList(:, vColumnsXYZ(3))));
%             quiver3(mPoseList(vIndexArrowStart, vColumnsXYZ(1)), mPoseList(vIndexArrowStart, vColumnsXYZ(2)), mPoseList(vIndexArrowStart, vColumnsXYZ(3)), vArrowX, vArrowY, vArrowZ, 0);
        end
        axis('tight')
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        grid on;
        view(v3DViewport);
    case '3d+single2d'
        % Plot 3d
        subplot(1, 2, 1);
        plot3(mPoseList(:, vColumnsXYZ(1)), mPoseList(:, vColumnsXYZ(2)), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        grid on;
        view(v3DViewport);
        
        % Plot [x, y, z] vs t
        subplot(1, 2, 2);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ), clLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $\left[ \rm m \right]$');
        legend('$x$', '$y$', '$z$');
    case '3d+multi2d'
        % Plot 3d
        subplot(3, 2, [1, 3, 5]);
        plot3(mPoseList(:, vColumnsXYZ(1)), mPoseList(:, vColumnsXYZ(2)), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        axis('tight')
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        grid on;
        view(v3DViewport);
        
        % Plot x vs t
        subplot(3, 2, 2);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(1)), clLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $x \left[ \rm m \right]$');
        
        % Plot y vs t
        subplot(3, 2, 4);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(2)), clLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $y \left[ \rm m \right]$');
        
        % Plot z vs t
        subplot(3, 2, 6);
        plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsXYZ(3)), clLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $z \left[ \rm m \right]$');
        
    otherwise
end
% % Plot in 3D?
% if bPlot3d
% % Plot as 2D plot
% else
%     plot(mPoseList(:, iColumnTime), mPoseList(:, ColumnsXYZ), clLineProperties{:});
%     xlabel('Time $t \left[s \right]$');
%     ylabel('Position $\left[ m \right]$');
% end

% Put the figure in the foreground
figure(hFig);

% And draw the image
drawnow;

if ~isempty(clFigureProperties)
    % Set the provided figure properties (this *MUST* be done down here because
    % plot or plo3 will change propertie slike 'Visible', and alike
    set(hFig, clFigureProperties{:});
end



%% Define return values

% First return value will be the handle to the figure
if nargout > 0
    if nargout >= 1
        varargout{1} = hFig;
    end
end

end
