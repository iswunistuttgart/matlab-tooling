function autosetlims(Axis, varargin)

%% Preprocess inputs (allows to have the axis defined as first argument)
% By default we don't have any axes handle
hAxes = false;
% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && isallaxes(Axis)
    hAxes = Axis;
    Axis = varargin{1};
    varargin = varargin(2:end);
end



%% Define the input parser
ip = inputParser;

% Optional a set of axis to set limits on
valFcn_Axis = @(x) any(validatestring(x, {'x', 'y', 'z', 'xy', 'yz', 'xz', 'xyz', 'all'}, mfilename, 'Axis'));
addOptional(ip, 'Axis', 'x', valFcn_Axis);

% The min and max values may be provided, otherwise it will default to whatever
% the axis has set as min and max limits
valFcn_Min = @(x) validateattributes(x, {'numeric'}, {'scalar', 'finite'}, mfilename, 'Min');
addOptional(ip, 'Min', -Inf, valFcn_Min);
valFcn_Max = @(x) validateattributes(x, {'numeric'}, {'scalar', 'finite'}, mfilename, 'Max');
addOptional(ip, 'Max', Inf, valFcn_Max);
% The extend margin may be provided, too
valFcn_Extend = @(x) validateattributes(x, {'numeric'}, {'scalar', 'finite', 'positive'}, mfilename, 'Exctend');
addOptional(ip, 'Extend', 0.05, valFcn_Extend);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, Axis, varargin{:});



%% Parse input string
% Get the string of the axis to get
chAxis = ip.Results.Axis;
% Get the provided min and max axis values
dMin = ip.Results.Min;
dMax = ip.Results.Max;
% Quickhand boolean variable to check whether we have to get the limits from the
% axis or if they're given
bGetMin = dMin == -Inf;
bGetMax = dMax == Inf;
% Check the given axis handle is an axis handle. If not, we will use the current
% axis' handle
if ~ishandle(hAxes)
%     hFig = figure;
    hAxes = gca;
end

dExtend = ip.Results.Extend;


% Keeps our target limits
vLims = zeros(6, 1);
% Get the min axis values from the provided axis
if bGetMin
    vLims(1) = min(xlim(hAxes));
    vLims(3) = min(ylim(hAxes));
    vLims(5) = min(zlim(hAxes));
% Get the min axis values from the provided value
else
    vLims(1) = dMin;
    vLims(3) = dMin;
    vLims(5) = dMin;
end
% Get the max axis values from the provided axis
if bGetMax
    vLims(2) = max(xlim(hAxes));
    vLims(4) = max(ylim(hAxes));
    vLims(6) = max(zlim(hAxes));
% Get the max axis values from the provided value
else
    vLims(2) = dMax;
    vLims(4) = dMax;
    vLims(6) = dMax;
end
% Get the span of the limits
dXSpan = vLims(2) - vLims(1);
dYSpan = vLims(4) - vLims(3);
dZSpan = vLims(6) - vLims(5);



%% Do the magic
switch chAxis
    case 'x'
        xlim(hAxes, [vLims(1), vLims(2)] + dExtend.*[-dXSpan, dXSpan]);
    case 'y'
        ylim(hAxes, [vLims(3), vLims(4)] + dExtend.*[-dYSpan, dYSpan]);
    case 'z'
        zlim(hAxes, [vLims(5), vLims(6)] + dExtend.*[-dZSpan, dzSpan]);
    case 'xy'
        xlim(hAxes, [vLims(1), vLims(2)] + dExtend.*[-dXSpan, dXSpan]);
        ylim(hAxes, [vLims(3), vLims(4)] + dExtend.*[-dYSpan, dYSpan]);
    case 'yz'
        ylim(hAxes, [vLims(3), vLims(4)] + dExtend.*[-dYSpan, dYSpan]);
        zlim(hAxes, [vLims(5), vLims(6)] + dExtend.*[-dZSpan, dZSpan]);
    case 'xz'
        xlim(hAxes, [vLims(1), vLims(2)] + dExtend.*[-dXSpan, dXSpan]);
        zlim(hAxes, [vLims(5), vLims(6)] + dExtend.*[-dZSpan, dZSpan]);
    case 'xyz'
        xlim(hAxes, [vLims(1), vLims(2)] + dExtend.*[-dXSpan, dXSpan]);
        ylim(hAxes, [vLims(3), vLims(4)] + dExtend.*[-dYSpan, dYSpan]);
        zlim(hAxes, [vLims(5), vLims(6)] + dExtend.*[-dZSpan, dZSpan]);
    case 'all'
        xlim(hAxes, [vLims(1), vLims(2)] + dExtend.*[-dXSpan, dXSpan]);
        ylim(hAxes, [vLims(3), vLims(4)] + dExtend.*[-dYSpan, dYSpan]);
        zlim(hAxes, [vLims(5), vLims(6)] + dExtend.*[-dZSpan, dZSpan]);
    otherwise;
        ylim(hAxes, [vLims(3), vLims(4)] + dExtend.*[-dYSpan, dYSpan]);
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
