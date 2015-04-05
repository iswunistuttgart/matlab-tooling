function varargout = plotPoseList(PoseList, varargin)

%% Define the input parser
ip = inputParser;

%%% Define validation methods
% Pose list must be validated to have 13 columns
valFcn_PoseList = @(x) ismatrix(x) && size(x, 2) == 13;
% Figure handles may be provided but only if they are a valid figure handle
% (duh)
valFcn_FigureHandle = @(x) ishandle(x) && strcmp(get(x, 'type'), 'figure');

%%% This fills in the parameters for the function
% We need the pose list
addRequired(ip, 'PoseList', valFcn_PoseList);
% We allow the user to explicitley flag which algorithm to use
addOptional(ip, 'Plot3d', false, @islogical);
% Allow options to be passed to the figure
addOptional(ip, 'FigureHandle', false, valFcn_FigureHandle);
% Allow the figure to have user-defined properties
addOptional(ip, 'FigureProperties', {}, @iscell);
% Allow the lines drawn to have user-defined properties
addOptional(ip, 'LineProperties', {}, @iscell);

% Configuratio nfor the input parser
ip.KeepUnmatched = true;
ip.FunctionName = 'plotPoseList';

% Parse the provided inputs
parse(ip, PoseList, varargin{:});

%% Parse the variables for local
% This helps us in not having to write ```ip.Results.``` over and over
% again
mPoseList = ip.Results.PoseList;
bPlot3d = ip.Results.Plot3d;
clFigureProperties = ip.Results.FigureProperties;
clLineProperties = ip.Results.LineProperties;

if islogical(ip.Results.FigureHandle) && ~ip.Results.FigureHandle
    hFig = figure;
else
    hFig = ip.Results.FigureHandle;
end


%% Automagic
% Determine the column that holds the time steps
iColumnTime = 1;
% Determine the columns that keep x, y, and z
vColumnsPose = iColumnTime+[1, 2, 3];


%% Actual plotting
% Select the provided figure handle to be the active handle
figure(hFig);

%%% Plot the pose list, all commands furthermore passed to PLOTPOSELIST
%%% will be arguments to either plot3 or plot
% Plot in 3D?
if bPlot3d
    plot3(mPoseList(:, vColumnsPose(1)), mPoseList(:, vColumnsPose(2)), mPoseList(:, vColumnsPose(3)), clLineProperties{:});
    xlabel('$x \left[ m \right]$');
    ylabel('$y \left[ m \right]$');
    zlabel('$z \left[ m \right]$');
% Plot as 2D plot
else
    plot(mPoseList(:, iColumnTime), mPoseList(:, vColumnsPose), clLineProperties{:});
    xlabel('Time $t \left[s \right]$');
    ylabel('Position $\left[ m \right]$');
end

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
    varargout{1} = hFig;
end

end