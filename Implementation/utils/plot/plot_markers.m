function varargout = plot_markers(varargin)
% PLOT_MARKERS Plot some markers on the lines given in Axes
% 
%   PLOT_MARKERS() plots 25 markers along all of the lines of the current axes.
%
%   PLOT_MARKERS(COUNT) plots COUNT markers along all of the lines of the
%   current axes. If count is given as a vector, then the values will be used
%   according to the lines found in the current axes. For example, if there are
%   4 lines in the current plot, PLOT_MARKERS([25, 50, 30, 60]) will add 25
%   markers on the first line, 50 on the second, 30 on the third, and 60 on the
%   fourth/last. If the number of markers is smaller than the number of child
%   charts found in the given axes, the markers will cyclically repeat.
% 
%   PLOT_MARKERS(COUNT, ORDER) uses the given order of marker styles to plot
%   into the given axes. Defaults to 'o|+|*|x'. Markers will be applied in order
%   of found child objects in the current axis. If the number of markers is
%   smaller than the number of valid charts then markers will be cyclically
%   repeated.
%
%   PLOT_MARKERS(COUNT, ORDER, SPACING) does spacing according to the value
%   chosen. Possible options for SPACING are
%       x       equidistant spacing along the x-axis (primary axis).
%       curve   equidistant along curve y
%       logx    used with logarithmix x-scale
%
%   PLOT_MARKERS(COUNT, ORDER, SPACING, 'PropertyName', 'PropertyValue', ...)
%   plots markers for the given axis.
%
%   PLOT_MARKERS(AX, ...) plots into the given axes handle.
%
%   MARKERHANDLES = PLOT_MARKERS(...) returns a vector of N handles of markers
%   having been placed for each of the N children of the given axes.
%
%   [MARKERHANDLES, LEGENDMARKERHANDLES] = PLOT_MARKERS(...) also returns vector
%   of N handles representing the legend markers which will be set into the
%   legend.
%   
%   Inputs:
%
%   Outputs:
%
%   MARKERHANDLES: Vector of N handles (one for each child of axes) to all the
%   plotted marker lines.
%
%   LEGENDMARKERHANDLES: Vector of handles of single item plots (one per child)
%   that can be used to mark the handles in the legend).
%
%   Optional Inputs -- specified as parameter value pairs
%   Count       - Number of markers per line. Default is 25
%
%   Order       - [char] Pipe-separated list of marker order for the lines found
%               in the given axes. Default is 'o|+|*|x'.
%
%   Spacing     - Spacing according to which the markers should be spaced. Valid
%               values are:
%               x     - equidistant spacing along the x-axis (primary axis)
%               curve - equidistant along curve y
%               logx  - equidistant along a log-x axis
%
%   See also: PLOT



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-06
% Changelog:
%   2016-09-06
%       * Update types of arguments from Parameter to Optional
%   2016-08-02
%       * Change to using gobjects for holding returned graphic handles
%       * Change to using ```axescheck``` and ```newplot```
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%   2016-05-23
%       * Update help doc
%       * Fix bug when plotting more markers than actual data points caused an
%       'subscript indices' error
%       * Remove diff and add gradient into determining the arc length of the
%       given curve
%       * Fix bug that caused script to always open a new axes to plot into
%       instead of plotting into the current one
%   2016-04-01
%       * Initial release



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
try
    [haTarget, args, ~] = axescheck(varargin{:});
    
    parse(ip, args{:});
catch me
    throw(MException(me.identifier, me.message));
end



%% Process arguments
% Get a valid new plot handle
haTarget = newplot(haTarget);
% Get old hold state
lOldHold = ishold(haTarget);
% Set axes to hold
hold(haTarget, 'on');
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
ceChildren = get(haTarget, 'Children');
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
hMarkers = gobjects(nValidChildren, 1);
hMarkerStart = gobjects(nValidChildren, 1);



%% Here is where all the adjustment happens
% For every child...
for iChild = 1:nValidChildren
    mxChild = ceChildren(iChild);
    
    %%% Create two copies of the current graphics type
    % First copy will be used to display only the markers
    hMarkers(iChild) = copyobj(mxChild, haTarget);
    % Second copy will be only the first item so that we can have it set
    % properly into the legends
    hMarkerStart(iChild) = copyobj(mxChild, haTarget);
    
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
            % Make sure we do not want to plot more markers than there are
            % actual data points
            if vMarkersCount(iChild) > numel(vXData)
                vMarkersCount(iChild) = numel(vXData);
            end
            
            % @TODO Determine this value automatically from the axes dimensions
            dFigureScale = 3/4;
            vNormalizedYData = (vYData - min(vYData))./(max(vYData) - min(vYData))*dFigureScale;             %NORMALIZE y scale in [0 1], height of display is prop to max(abs(y))        
            vNormalizedXData = (vXData - min(vXData))./(max(vXData) - min(vXData));                    %NORMALIZE x scale in [0 1]   

            % Spacing along curves with Infs in it not possible
            if any(isinf(vNormalizedYData)) || any(isinf(vXData))
                vSelector = round(linspace(1,length(x),num_Markers)); 
            else
                vXIndex = 1:length(vXData);
                % Measure length along curve
                vArcLength = cumsum(sqrt(gradient(vNormalizedXData).^2 + gradient(vNormalizedYData).^2));
                % Vector equally spaced along s
                vArcSpaced = (0:vMarkersCount(iChild) - 1).*vArcLength(end)./(vMarkersCount(iChild) - 1);
                % Make sure first and last point are on the curve
                vArcSpaced(1) = vArcLength(1);
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

% Restore old hold value
if ~lOldHold
    hold(haTarget, 'off');
end

% Update the figure
drawnow



%% Assign output quantities
% First optional return argument is the handles of markers
if nargout > 0
    varargout{1} = hMarkers;
end

% Second optional return argument is the handles of the start markers
if nargout > 1
    varargout{2} = hMarkerStart;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
