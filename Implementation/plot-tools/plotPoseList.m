function varargout = plotPoseList(PoseList, varargin)


%% Preprocess inputs (allows to have the axis defined as first argument)
% By default we don't have any axes handle
hAxes = false;
% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && allAxes(PoseList)
    hAxes = PoseList;
    PoseList = varargin{1};
    varargin = varargin(2:end);
end



%% Define the input parser
ip = inputParser;

%%% This fills in the parameters for the function
% We need the pose list
valFcn_PoseList = @(x) validateattributes(x, {'numeric'}, {'2d', 'nonempty'}, mfilename, 'PoseList');
addRequired(ip, 'PoseList', valFcn_PoseList);

% We request a plot style
valFcn_PlotStyle = @(x) any(validatestring(lower(x), {'Single2D', 'Single2D+3D', 'Multi2D', 'Multi2D+3D', '3D', '3D+Single2D', '3D+Multi2d'}));
addOptional(ip, 'PlotStyle', '3D', valFcn_PlotStyle);

% Allow the figure to have user-defined properties
valFcn_FigureSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'FigureSpec');
addOptional(ip, 'FigureSpec', {}, valFcn_FigureSpec);

% Allow the lines drawn to have user-defined properties
valFcn_LineSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'LineSpec');
addOptional(ip, 'LineSpec', {}, valFcn_LineSpec);

% If time column should not be detected automatically, it may be set
% explicitely
valFcn_ColumnTime = @(x) isinteger(x) && x >= 0 && x < size(PoseList, 2);
addOptional(ip, 'IndexTime', 0, valFcn_ColumnTime)

% Allow the columns of X, Y, and Z to be set explicitely, otherwise we are
% assuming them to be in columns [2, 3, 4]
valFcn_ColumnsXYZ = @(x) isrow(x) && issize(x, 1, 3);
addOptional(ip, 'IndexXYZ', [2, 3, 4], valFcn_ColumnsXYZ);

% User might want to change the 3D view port
valFcn_Viewport = @(x) validateattributes(x, {'logical', 'numeric'}, {'2d'}, mfilename, 'Viewport');
addOptional(ip, 'Viewport', [-20, 6], valFcn_Viewport);

% Maybe the direction of the 3D-plot's trajectory is desired, too?
valFcn_PlotDirection3D = @(x) any(validatestring(x, {'on', 'off', 'minor'}, mfilename, 'Grid'));
addOptional(ip, 'PlotDirection3D', 'off', valFcn_PlotDirection3D);

% Allow user to choose grid style (either 'on', 'off', or 'minor')
valFcn_Grid = @(x) any(validatestring(x, {'on', 'off', 'minor'}, mfilename, 'Grid'));
addOptional(ip, 'Grid', 'off', valFcn_Grid);

% Allow user to set the xlabel ...
valFcn_XLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'XLabel');
addOptional(ip, 'XLabel', '', valFcn_XLabel);

% Allow user to set the ylabel ...
valFcn_YLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'YLabel');
addOptional(ip, 'YLabel', '', valFcn_YLabel);

% And allow user to set the zlabel
valFcn_ZLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'ZLabel');
addOptional(ip, 'ZLabel', '', valFcn_ZLabel);

% Maybe a title is provided and shall be plotted, too?
valFcn_Title = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Title');
addOptional(ip, 'Title', '', valFcn_Title);

% Configuratio nfor the input parser
ip.KeepUnmatched = true;
ip.FunctionName = 'plotPoseList';

% Parse the provided inputs
parse(ip, PoseList, varargin{:});



%% Parse the variables for local
% Get the pose list
aPoseList = ip.Results.PoseList;
% Get the plot style
cPlotStyle = lower(ip.Results.PlotStyle);
% Get the cell array of figure properties
% ceFigureProperties = ip.Results.FigureProperties;
% Properties on the line plot of the pose
ceLineProperties = ip.Results.LineSpec;
% Set the column that keeps the time here
iColumnTime = ip.Results.IndexTime;
% The vecotr that holds the keys of the XYZ data
vColumnsXYZ = ip.Results.IndexXYZ;
% A vector to set the viewport data
mxdViewport = ip.Results.Viewport;
% Boolean whether to plot the 3d direction or not
ch3DPlotDireciton = inCharToValidArgument(ip.Results.PlotDirection3D);
% Parse the option for the grid
% chGrid = ip.Results.Grid;
% % bGrid = ~isequal(chGrid, 0);
% % Get the desired figure title (works only in standalone mode)
% chTitle = ip.Results.Title;
% % Get provided axes labels
% chXLabel = ip.Results.XLabel;
% chYLabel = ip.Results.YLabel;
% chZLabel = ip.Results.ZLabel;



%% Automagic
if ~ishandle(hAxes)
    hFig = figure;
    hAxes = gca;
% Check we are looking at a 3D plot, if a plot is given
% else
%     [az, el] = view(hAxes);
%     assert(~isequaln([az, el], [0, 90]), 'Cannot plot a 3D plot into an existing 2D plot.');
end

% If the time column wasn't set, we will automatically detect it
if iColumnTime == 0
    for iCol = 1:size(PoseList, 2)
        try
            validateattributes(PoseList(:,iCol), {'numeric'}, {'increasing'});
            iColumnTime = iCol;
            break;
        catch me
            clear me;
            continue;
        end
    end
end

% bOwnPlot = isempty(get(hAxes, 'Children'));




%% Actual plotting
% Select the given axes as target
axes(hAxes);

% Ensure we have the axes on hold so we don't accidentaly overwrite its
% content
hold(hAxes, 'on');



%%% Plot the pose list, all commands furthermore passed to PLOTPOSELIST
%%% will be arguments to either plot3 or plot
switch cPlotStyle
    case 'single2d'
        plot(NaN, NaN);
        hold on;
        plot(aPoseList(:,iColumnTime), aPoseList(:,vColumnsXYZ), ceLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $\left[ \rm m \right]$');
        legend('$x$', '$y$', '$z$');
    case 'single2d+3d'
        % Plot 3d
        subplot(2, 1, 2);
        plot3(aPoseList(:,vColumnsXYZ(1)), aPoseList(:,vColumnsXYZ(2)), aPoseList(:,vColumnsXYZ(3)), ceLineProperties{:});
        axis('tight')
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        grid on;
        view(mxdViewport);
        
        % Plot [x, y, z] vs t
        subplot(2, 1, 1);
        plot(aPoseList(:,iColumnTime), aPoseList(:,vColumnsXYZ), ceLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $\left[ \rm m \right]$');
        legend('$x$', '$y$', '$z$');
    case 'multi2d'
        % Plot x vs t
        subplot(3, 1, 1);
        plot(aPoseList(:,iColumnTime), aPoseList(:,vColumnsXYZ(1)), ceLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $x \left[ \rm m \right]$');
        
        % Plot y vs t
        subplot(3, 1, 2);
        plot(aPoseList(:,iColumnTime), aPoseList(:,vColumnsXYZ(2)), ceLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $y \left[ \rm m \right]$');
        
        % Plot z vs t
        subplot(3, 1, 3);
        plot(aPoseList(:,iColumnTime), aPoseList(:,vColumnsXYZ(3)), ceLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $z \left[ \rm m \right]$');
    case 'multi2d+3d'
        % Plot 3d
        subplot(2, 3, [4, 5, 6]);
        plot3(aPoseList(:,vColumnsXYZ(1)), aPoseList(:,vColumnsXYZ(2)), aPoseList(:,vColumnsXYZ(3)), ceLineProperties{:});
        axis('tight')
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        grid on;
        view(mxdViewport);
        
        % Plot x vs t
        subplot(2, 3, 1);
        plot(aPoseList(:,iColumnTime), aPoseList(:,vColumnsXYZ(1)), ceLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $x \left[ \rm m \right]$');
        
        % Plot y vs t
        subplot(2, 3, 2);
        plot(aPoseList(:,iColumnTime), aPoseList(:,vColumnsXYZ(2)), ceLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $y \left[ \rm m \right]$');
        
        % Plot z vs t
        subplot(2, 3, 3);
        plot(aPoseList(:,iColumnTime), aPoseList(:,vColumnsXYZ(3)), ceLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $z \left[ \rm m \right]$');
    case '3d'
        % Plot 3d
        plot3(aPoseList(:,vColumnsXYZ(1)), aPoseList(:,vColumnsXYZ(2)), aPoseList(:,vColumnsXYZ(3)), ceLineProperties{:});
        if strcmp(ch3DPlotDireciton, 'on')
            hold on
            quiver3(aPoseList(:,vColumnsXYZ(1)), aPoseList(:,vColumnsXYZ(2)), aPoseList(:,vColumnsXYZ(3)), gradient(aPoseList(:,vColumnsXYZ(1))), gradient(aPoseList(:,vColumnsXYZ(2))), gradient(aPoseList(:,vColumnsXYZ(3))));
        end
        axis('tight')
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        grid on;
        view(mxdViewport);
    case '3d+single2d'
        % Plot 3d
        subplot(1, 2, 1);
        plot3(aPoseList(:,vColumnsXYZ(1)), aPoseList(:,vColumnsXYZ(2)), aPoseList(:,vColumnsXYZ(3)), ceLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        grid on;
        view(mxdViewport);
        
        % Plot [x, y, z] vs t
        subplot(1, 2, 2);
        plot(aPoseList(:,iColumnTime), aPoseList(:,vColumnsXYZ), ceLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $\left[ \rm m \right]$');
        legend('$x$', '$y$', '$z$');
    case '3d+multi2d'
        % Plot 3d
        subplot(3, 2, [1, 3, 5]);
        plot3(aPoseList(:,vColumnsXYZ(1)), aPoseList(:,vColumnsXYZ(2)), aPoseList(:,vColumnsXYZ(3)), ceLineProperties{:});
        axis('tight')
        xlabel('$x \left[ m \right]$');
        ylabel('$y \left[ m \right]$');
        zlabel('$z \left[ m \right]$');
        
        grid on;
        view(mxdViewport);
        
        % Plot x vs t
        subplot(3, 2, 2);
        plot(aPoseList(:,iColumnTime), aPoseList(:,vColumnsXYZ(1)), ceLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $x \left[ \rm m \right]$');
        
        % Plot y vs t
        subplot(3, 2, 4);
        plot(aPoseList(:,iColumnTime), aPoseList(:,vColumnsXYZ(2)), ceLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $y \left[ \rm m \right]$');
        
        % Plot z vs t
        subplot(3, 2, 6);
        plot(aPoseList(:,iColumnTime), aPoseList(:,vColumnsXYZ(3)), ceLineProperties{:});
        axis('tight')
        ylim(ylim().*1.10);
        xlabel('Time $t \left[ \rm s \right]$');
        ylabel('Position $z \left[ \rm m \right]$');
        
    otherwise
end

% % This is stuff we are only going to do if we're in our own plot
% if bOwnPlot
%     % Set x-axis label, if provided
%     if ~isempty(strtrim(chXLabel))
%         xlabel(hAxes, chXLabel);
%     end
%     % Set y-axis label, if provided
%     if ~isempty(strtrim(chYLabel))
%         ylabel(hAxes, chYLabel);
%     end
%     % Set z-axis label, if provided
%     if ~isempty(strtrim(chZLabel))
%         zlabel(hAxes, chZLabel);
%     end
%     
%     % Set a figure title?
%     if ~isempty(strtrim(chTitle))
%         title(hAxes, chTitle);
%     end
%     
%     % Set the viewport
%     view(hAxes, mxdViewport);
%     
%     % Set a grid?
%     if any(strcmp(chGrid, {'on', 'minor'}))
%         % Set grid on
%         grid(hAxes, chGrid);
%         % For minor grids we will also enable the "major" grid
%         if strcmpi(chGrid, 'minor')
%             grid(hAxes, 'on');
%         end
%     end
% end

% Put the figure in the foreground
axes(hAxes);

% And draw the image
drawnow;

% Clear the hold off the current axes
hold(hAxes, 'off');



%% Define return values

% First return value will be the handle to the figure
if nargout > 0
    varargout{1} = hFig;
end

end

function result = allAxes(h)

result = all(all(ishghandle(h))) && ...
         length(findobj(h,'type','axes','-depth',0)) == length(h);

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

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
