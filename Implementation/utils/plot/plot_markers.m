function plot_markers(varargin)
% PLOT_MARKERS Plot some markers on the lines given in Axes
% 
%   PLOT_MARKERS() plots 25 markers along all of the lines of the current axes
%   
%   Inputs:
%   
%   TIME: Column vector of increasing values representing the timestamps at wich
%   the poses are gathered. Only needed in any '2D' mode.
%   
%   POSES: Matrix of poses of the platform center of gravity where each row is
%   the [x, y, z] tuple of platform center of gravity positon at the time
%   corresponding to that value
%
%   See also: VIEW, PLOT, PLOT3, LINESPEC, GRID, TITLE, XLABEL, YLABEL, ZLABEL,
%   DATESTR
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-04-01
% Changelog:
%   2016-04-01
%       * Initial release



%% Pre-process inputs
% By default we don't have any axes handle
haAxes = false;
% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && isallaxes(varargin{1})
    haAxes = varargin{1};
    varargin = varargin(2:end);
end



%% Define the input parser
ip = inputParser;

% Let user decide on the plot style
% Plot style can be chosen anything from the list below
valFcn_Count = @(x) validateattributes(x, {'numeric'}, {'row', '>=', 1}, mfilename, 'Count');
addOptional(ip, 'Count', '25', valFcn_Count);

% Optional 2: Markers to set or order of markers
valFcn_Order = @(x) assert(all(ismember(strsplit(x, '|'), {'o', '+', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'})));
addOptional(ip, 'Order', 'o|+|*|x', valFcn_Order);

% Optional 3: Spacing between the markers
valFcn_Spacing = @(x) assert(any(validatestring(x, {'x', 'curve', 'logx'}, mfilename, 'Spacing')));
addOptional(ip, 'Spacing', 'x', valFcn_Spacing);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, varargin{:});



%% Process arguments
% If we don't have an axes handle we will grab the current one
haAxes = gca;
% Get the number of markers
vMarkersCount = ip.Results.Count;
% The default order style
chMarkerOrder = ip.Results.Order;
assert(length(chMarkerOrder) == 1 | any(strfind(chMarkerOrder, '|')), 'Invalid format for marker order given. Multiple markers must be separated by a |');
ceMarkerOrder = strsplit(chMarkerOrder, '|');
% Get the spacing as reqeusted by the user
chSpacing = lower(ip.Results.Spacing);

% Currently, we only allow adding markers to the following plot types
ceSupportedPlotTypesSelector = {'Type', 'line'};



%% Pre-process data
% Get all children of the axes
ceChildren = get(haAxes, 'Children');
% Grab only the valid children from the current axes' children
ceValidChildren = findobj(ceChildren, ceSupportedPlotTypesSelector{:});
nValidChildren = numel(ceValidChildren);
% Ensure we have enough markers for all children
if isscalar(vMarkersCount)
    vMarkersCount = vMarkersCount.*ones(nValidChildren, 1);
elseif numel(vMarkersCount) < nValidChildren
    vMarkersCount = repmat(vMarkersCount, 1, ceil(nValidChildren/numel(vMarkersCount)));
end
% Repeat the markers until we have enough for every child
if numel(ceMarkerOrder) < nValidChildren
    ceMarkerOrder = repmat(ceMarkerOrder, 1, ceil(nValidChildren/numel(ceMarkerOrder)));
end

% Holds the handles to the generated plots
hMarkers = zeros(nValidChildren, 1);
hMarkerStart = zeros(nValidChildren, 1);



%% Here is where all the adjustment happens
% For every child...
for iChild = 1:nValidChildren
    mxChild = ceChildren(iChild);
    
    %%% Create two copies of the current graphics type
    % First copy will be used to display only the markers
    hMarkers(iChild) = copyobj(mxChild, haAxes);
    % Second copy will be only the first item so that we can have it set
    % properly into the legends
    hMarkerStart(iChild) = copyobj(mxChild, haAxes);
    
    %%% Work on the original object
    set(mxChild, 'HandleVisibility', 'off');
    chOriginalLinestyle = get(mxChild, 'LineStyle');
    vXData = get(mxChild, 'XData');
    vYData = get(mxChild, 'YData');
    vZData = get(mxChild, 'ZData');
    
    % Fall back to spacing along x if the data is 3D (currently we do not
    % support 'curve' spacing for 3D plots. I honestly don't know the equations
    % to determine the arc length of a 3D plot though it most likely will be
    % similar to the 2D version $s = \int_{x_1}^{x_2}{ 1 + \frac{\partial f}{\partial x} \mathrm{d}\,x }$
    if ~isempty(vZData) && strcmp(chSpacing, 'curve')
        chSpacing = 'x';
    end
    
    % Determine the point selector based on the desired input
    switch chSpacing
        % Uniform along x
        case 'x'
            vSelector = round(linspace(1, numel(vXData), vMarkersCount(iChild)));
        % Logarithmic along x
        case 'logx'
            vSelector = floor(interp1(vXData, 1:length(vXData), logspace(log10(vXData(2)), log10(vXData(end-1)), vMarkersCount(iChild))));
        % Uniform along the curve
        case 'curve'
            dFigureScale = 3/4;
            vNormalizedYData = (vYData - min(vYData))./(max(vYData) - min(vYData))*dFigureScale;             %NORMALIZE y scale in [0 1], height of display is prop to max(abs(y))        
            vNormalizedXData = (vXData - min(vXData))./(max(vXData) - min(vXData));                    %NORMALIZE x scale in [0 1]   

            % Spacing along curves with Infs in it not possible
            if any(isinf(vNormalizedYData)) || any(isinf(vXData))
                vSelector = round(linspace(1,length(x),num_Markers)); 
            else
                vXIndex = 1:length(vXData);                                
                % Measure length along curve
                vArcLength = [0 cumsum(sqrt(diff(vNormalizedXData).^2 + diff(vNormalizedYData).^2))];
                % Vector equally spaced along s
                vArcSpaced = (0:vMarkersCount(iChild) - 1)*vArcLength(end)/(vMarkersCount(iChild) - 1);
                % Make sure last point is on the curve
                vArcSpaced(end) = vArcLength(end);
                % And get the x-indices of these values of y
                vSelector = round(interp1(vArcLength, vXIndex, vArcSpaced));
            end
    end
    
    % Grab the actual data to be plotted
    vMarkerXData = vXData(vSelector);
    vMarkerYData = vYData(vSelector);
    if ~isempty(vZData)
        vMarkerZData = vZData(vSelector);
    end
    
    %%% Work on the "marker only" object
    set(hMarkers(iChild), ...
        'LineStyle', 'none', ...
        'Marker', ceMarkerOrder{iChild}, ...
        'XData', vMarkerXData, ...
        'YData', vMarkerYData, ...
        'HandleVisibility', 'off');
    % If there is previous z-data we will update that as well
    if ~isempty(vZData)
        set(hMarkers(iChild), 'ZData', vMarkerZData);
    end
    
    
    %%% Work on the "first marker" object
    set(hMarkerStart(iChild), ...
        'XData', vXData(1), ...
        'YData', vYData(1), ...
        'LineStyle', chOriginalLinestyle, ...
        'Marker', ceMarkerOrder{iChild}, ...
        'HandleVisibility', 'on');
    
    if ~isempty(vZData)
        set(hMarkerStart(iChild), 'ZData', vZData(1));
    end
end


drawnow

end
