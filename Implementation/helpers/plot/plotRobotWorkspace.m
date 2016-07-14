function [varargout] = plotRobotWorkspace(XData, YData, ZData, varargin)



%% Preprocess inputs (allows to have the axis defined as first argument)
% By default we don't have any axes handle
hAxes = false;
% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && isallaxes(XData)
    hAxes = XData;
    XData = YData;
    YData = ZData;
    ZData = varargin{1};
    varargin = varargin(2:end);
end



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
try
    parse(ip, XData, YData, ZData, varargin{:});
catch me
    throw(MException(me.identifier, me.message));
end



%% Parse Variables
mxXData = ip.Results.XData;
mxYData = ip.Results.YData;
mxZData = ip.Results.ZData;
hAxes = ip.Results.Axes;
cePatchProperties = ip.Results.PatchProperties;
vViewport = ip.Results.Viewport;

% Ensure the handle hAxes is a valid handle. If none given, create a new
% figure handle, otherwise select the given one to be the active axes
% handle
if ~ishandle(hAxes)
    hAxes = gca;
end



%% Do the magic plotting

% If an axes was given, we want to make sure we won't overwrite its content
hold(hAxes, 'on');
% Plot the patch of X, Y, Z data with solid color
hPatch = patch(mxXData, mxYData, mxZData, 1);
% Set properties on the patch?
if ~isempty(cePatchProperties)
    set(hpatch, cePatchProperties);
end

% Set the viewport
view(vViewport);

% Make sure the figure is being drawn before anything else is done
drawnow;



%% Assign output quantities
% Return the axes handle as the first output
if nargout > 0
    varargout{1} = hAxes;
end

% Return the patch object as the second output argument
if nargout > 1
    varargout{2} = hPatch;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
