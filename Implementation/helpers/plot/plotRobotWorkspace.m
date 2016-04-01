function [varargout] = plotRobotWorkspace(XData, YData, ZData, varargin)



%% Define the input parser
ip = inputParser;

%%% Define validation methods
valFcn_LogicalOrInt = @(x) islogical(x) || isequal(x, 1) || isequal(x, 0);
% Option to 'axes' must be a handle and also a 'axes' handle
valFcn_PatchData = @(x) ismatrix(x) && isequal(size(x, 1), 3);
% Option to 'axes' must be a handle and also a 'axes' handle
valFcn_Axes = @(x) ishandle(x) && strcmp(get(x, 'type'), 'axes');
% Viewport may be 2, 3, [az, el], or [x, y, z]
valFcn_Viewport = @(x) ( isequal(x, 2) || isequal(x, 3) || ( isrow(x) && ( isequal(size(x, 2), 2) || isequal(size(x, 2), 3) ) ) );
% Grid may be true, false, 1, 0, 'on', 'off', or 'minor'
valFcn_Grid = @(x) islogical(x) || ( isequal(x, 1) || isequal(x, 0) ) || any(strcmpi(x, {'on', 'off', 'minor'}));

%%% This fills in the parameters for the function
% We need the x-data of our workspace
addRequired(ip, 'XData', valFcn_PatchData);
% We need the x-data of our workspace
addRequired(ip, 'YData', valFcn_PatchData);
% We need the x-data of our workspace
addRequired(ip, 'ZData', valFcn_PatchData);
% We need the axes handle which is allowed to be the first optional
% argument which must not be used with a parameter name
addOptional(ip, 'Axes', false, valFcn_Axes);
% Allow the plot to have user-defined properties
addOptional(ip, 'PatchProperties', {}, @iscell);
% The 3d view may be defined, too
addOptional(ip, 'Viewport', [-13, 10], valFcn_Viewport);
% Allow user to choose grid style (either false 'on', 'off', or 'minor'
addOptional(ip, 'Grid', false, valFcn_Grid);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, XData, YData, ZData, varargin{:});



%% Parse Variables
mXData = ip.Results.XData;
mYData = ip.Results.YData;
mZData = ip.Results.ZData;
hAxes = ip.Results.Axes;
cPatchProperties = ip.Results.PatchProperties;
vViewport = ip.Results.Viewport;
chGrid = ip.Results.Grid;
if islogical(chGrid) && isequal(chGrid, true)
    chGrid = 'on';
end

% Ensure the handle hAxes is a valid handle. If none given, create a new
% figure handle, otherwise select the given one to be the active axes
% handle
if ~ishandle(hAxes)
    hFig = figure();
    hAxes = gca();
else
    axes(hAxes);
end



%% Do the magic plotting

% If an axes was given, we want to make sure we won't overwrite its content
hold(hAxes, 'on');
% Plot the patch of X, Y, Z data with solid color
hPatch = patch(mXData, mYData, mZData, 1);
% Set properties on the patch?
if ~isempty(cPatchProperties)
    set(hpatch, cPatchProperties);
end

% Set the viewport
view(vViewport);

% Set a grid?
if chGrid
    % Set grid to given value
    grid(hAxes, chGrid);
    if strcmpi(chGrid, 'minor')
        grid(chGrid, 'on');
    end
end

% Make sure the figure is being drawn before anything else is done
drawnow;



%% Assign output quantities
if nargout > 0
    if nargout >= 1
        varargout{1} = hAxes;
    end
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
