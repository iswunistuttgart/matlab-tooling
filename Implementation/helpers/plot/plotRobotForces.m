function varargout = plotRobotForces(Time, Forces, varargin)



%% Preprocess inputs (allows to have the axis defined as first argument)
% By default we don't have any axes handle
haTarget = false;
% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && isallaxes(Time)
    narginchk(3, Inf)
    haTarget = Time;
    Time = Forces;
    Forces = varargin{1};
    varargin = varargin(2:end);
end



%% Define the input parser
ip = inputParser;

% Require: Winch Positions. Must be a matrix of size 3xM
% valFcn_WinchPositions = @(x) ismatrix(x) && isequal(size(x, 1), 3);
valFcn_Time = @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 1}, mfilename, 'Time');
addRequired(ip, 'Time', valFcn_Time);

% Allow the plot to have user-defined spec
valFcn_Forces = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', size(Time, 1)}, mfilename, 'Forces');
addRequired(ip, 'Forces', valFcn_Forces);

% Allow user to define how forces shall be plotted. If nothing is given, we
% will plot all forces into a single 2D-plot. If a matrix is given, each
% row will be a separate figure
% valFcn_PlotLayout = @(x) validateattributes(x, {'numeric'}, {'2d', 'numel', size(Forces, 2)}, mfilename, 'PlotLayout');
% addOptional(ip, 'PlotLayout', false, valFcn_PlotLayout);

% Allow the plot to have user-defined spec
valFcn_PlotSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'PlotSpec');
addOptional(ip, 'PlotSpec', {}, valFcn_PlotSpec);

% Allow user to choose grid style (either 'on', 'off', or 'minor')
valFcn_Grid = @(x) any(validatestring(x, {'on', 'off', 'minor'}, mfilename, 'Grid'));
addOptional(ip, 'Grid', false, valFcn_Grid);

% Allow user to set the xlabel ...
valFcn_XLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'XLabel');
addOptional(ip, 'XLabel', false, valFcn_XLabel);

% Allow user to set the ylabel ...
valFcn_YLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'YLabel');
addOptional(ip, 'YLabel', false, valFcn_YLabel);

% Maybe a title is provided and shall be plotted, too?
valFcn_Title = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Title');
addOptional(ip, 'Title', false, valFcn_Title);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, Time, Forces, varargin{:});



%% Parse variables of the input parser to local parser
% Ensure the handle for the axes is a valid handle. If none given, we will
% create our own figure with handle
if ~ishandle(haTarget)
    haTarget = gca;
% Check we are not looking a 3D plot, if a plot is given
else
    [az, el] = view(haTarget);
    assert(isequaln([az, el], [0, 90]), 'Cannot plot a 2D plot into an existing 3D plot.');
end
bOwnPlot = ~isempty(get(haTarget, 'Children'));
% Column vector time
vcTime = ip.Results.Time;
% Matrix of cable forces
maForces = ip.Results.Forces;
% Get the plot layout
% maPlotLayout = ip.Results.PlotLayout;
% % No plot layout given? Then we will plot all forces into one plot
% if isequal(maPlotLayout, 0)
%     maPlotLayout = 1:1:size(maForces, 2);
% end
% % Assert that for a "append" plot we only have to create one plot
% assert(isequal(bOwnPlot, 0) && isrow(maPlotLayout), 'If plotting into given axes we cannot have more than one plot to create given by format of ''PlotLayout''');
% Plot spec
cPlotSpec = ip.Results.PlotSpec;
% Get the char for the grid
chGrid = ip.Results.Grid;
% Get the desired figure title (works only in standalone mode)
chTitle = ip.Results.Title;
% Get provided axes labels
chXLabel = ip.Results.XLabel;
chYLabel = ip.Results.YLabel;



%% Do the magic
% Select the given axes as target axes
axes(haTarget);

% Ensure we are not overwriting anything
hold(haTarget, 'on');

% First, plot the winch positions as circles
hPlotForces = plot(vcTime, maForces);
% If the plot spec were given, we need to set them on the plot
if ~isempty(cPlotSpec)
    set(hPlotWinchPositions, hPlotForces{:});
end

% This is stuff we are only going to do if we're in our own plot
if bOwnPlot
    % Set x-axis label, if provided
    if chXLabel
        xlabel(haTarget, chXLabel);
    end
    % Set y-axis label, if provided
    if chYLabel
        ylabel(haTarget, chYLabel);
    end
    
    % Set a figure title?
    if chTitle
        title(haTarget, chTitle);
    end
    
    % Set a grid?
    if chGrid
        % Set grid on
        grid(haTarget, chGrid);
        % For minor grids we will also enable the "major" grid
        if strcmpi(chGrid, 'minor')
            grid(haTarget, 'on');
        end
    end
end

% Make sure the figure is being drawn before anything else is done
drawnow

% Finally, set the active axes handle to be the first most axes handle we
% have created or were given a parameter to this function
axes(haTarget);

% Enforce drawing of the image before returning anything
drawnow

% Clear the hold off the current axes
hold(haTarget, 'off');



%% Assign output quantities

% First output argument is the axes handle
if nargout >= 1
    varargout{1} = haTarget;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
