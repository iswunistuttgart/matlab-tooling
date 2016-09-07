function [varargout] = plot_zoom(Region, Position, varargin)
% PLOT_ZOOM plots a zoom region into the given axes
%
%   PLOT_ZOOM(REGION, POSITION) plots a zoomed version of the data defined in
%   REGION into a zoomed axis located at POSITION. Region REGION may be selected
%   arbitrarily and without restrictions on the aspect ratio. The resulting axes
%   centered at POSITION will however get the parent axes' ratio and zoom in by
%   the zoom factor
%
%   PLOT_ZOOM(REGION, POSITION, ZOOM) plots a zoomed version of the data plotted
%   in REGION into a new axis located at POSITION. The zoom factor is defined by
%   ZOOM and can range between greater than 0 and Inf. Be aware that the zoom
%   factor directly affects the resulting zoomed axes' size as this scales
%   linearly with ZOOM.
%
%   PLOT_ZOOM(AX, ...) plots the inset zoom box into the given axes.
%
%   ZOOM_AX = PLOT_ZOOM(...) returns the handle to the inset zoomed axes for
%   later manipulation.
%
%   [ZOOM_AX, SOURCE_ANNO] = PLOT_ZOOM(...) also returns the handle to the
%   source annotation box.
%
%   [ZOOM_AX, SOURCE_ANNO, ZOOMLINE_ANNO] = PLOT_ZOOM(...) also returns a column
%   vector of handles to the zoom line annotation. Only available if input
%   parameter 'ZoomLines' is given with 'on';
%
%   PLOT_ZOOM(..., 'Name', 'Value') allows additional parameter value pairs to
%   be set. For a full list of these, see the help further down.
%
%   Optional Inputs -- specified as parameter value pairs
%   Zoom            Zoom factor of the source data. Must be greater than zero,
%                   but can be any value you desire. Note that, the zoom factor
%                   linearly scales the width of the resulting zoomed axes.
%
%   ZoomAxesSpec    Additional specifications to set on the inset zoomed axes
%                   like XAxisLocation or FontSize. Must be a nonempty cell
%                   array.
%
%   SourceBoxSpec   Plotting specifications on the source annotation box. Can be
%                   a cell array of valid annotation rectangle properties which
%                   can be found in the docs.
%
%   ZoomLines       Whether to also annotate the drawing with zoom lines
%                   connecting the respective corners of the source annotation
%                   box with the target axes corners. Possible values are
%                   'on', 'yes'     enable drawing zoom lines
%                   'off', 'no'     disable drawing zoom lines (default)
%
%   ZoomLineSpec    Additional line properties to set on the zoom lines. Can be
%                   a cell array of valid annotation line properties which may
%                   be found in the docs.
%
%   SEE: axes annotation



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-07
% Changelog:
%   2016-09-07
%       * Fix bug with cycliccell that caused errors when custom styles were set
%       on multiple zoom axes at once
%       * Add support for usage of parseswitcharg()
%   2016-08-12
%       * Initial release



%% Define the input parser
ip = inputParser;

% Require: Range. What region to zoom into to given as [x, y, w, h]
valFcn_Region = @(x) validateattributes(x, {'numeric'}, {'vector', 'nonempty', 'numel', 4}, mfilename, 'Region');
addRequired(ip, 'Region', valFcn_Region);

% Require: Position of the zoom in region [x, y]
valFcn_Position = @(x) validateattributes(x, {'numeric'}, {'vector', 'nonempty', 'numel', 2}, mfilename, 'Position');
addRequired(ip, 'Position', valFcn_Position);

% Optional: Zoom level. Defaults to 1
valFcn_Zoom = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'positive'}, mfilename, 'Zoom');
addOptional(ip, 'Zoom', 1, valFcn_Zoom);

% Optional: Specifications of the rectangle marking the source region
valFcn_SourceBoxSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'SourceBoxSpec');
addParameter(ip, 'SourceBoxSpec', {}, valFcn_SourceBoxSpec);

% Optional: Specifications of the rectangle marking the source region
valFcn_AxesSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'ZoomAxesSpec');
addParameter(ip, 'ZoomAxesSpec', {}, valFcn_AxesSpec);

% Optional: Zoom lines connecting the appropriate corners of the source
%           rectangle with the target rectangle
valFcn_ZoomLines = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'ZoomLines'));
addParameter(ip, 'ZoomLines', 'off', valFcn_ZoomLines);

% Optional: Specifications of the zoom lines marking the source region
valFcn_ZoomLineSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'ZoomLineSpec');
addParameter(ip, 'ZoomLineSpec', {}, valFcn_ZoomLineSpec);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    varargin = [{Region}, {Position}, varargin];
    [haTarget, args, ~] = axescheck(varargin{:});
    
    parse(ip, args{:});
catch me
    throwAsCaller(MException(me.identifier, me.message));
end



%% Parse variables of the input parser to local parser
% Get the zoom in region
vRegion = ip.Results.Region;
vRegion = [sort(vRegion(1:2)), sort(vRegion(3:4))];
% Position to center target magnified plot to
vZoomPosition = ip.Results.Position;
% Specifications of the source rectangle
ceSourceBoxSpec = ip.Results.SourceBoxSpec;
% Cell array of specs for the zoomed axes
ceZoomAxesSpec = ip.Results.ZoomAxesSpec;
% Specifications for the zoom line specs
ceZoomLinesSpec = cycliccell(ip.Results.ZoomLineSpec, 2);
% Whether to draw lines from source box to target zoom box
chZoomLines = parseswitcharg(ip.Results.ZoomLines);
% If the zoom lines are not requested, then the maximum number of output
% arguments is two (zoomed axes handle and annotation box handle)
if strcmp(chZoomLines, 'off')
    nargoutchk(0, 2);
end
% Zoom factor scaling vRange
dZoom = ip.Results.Zoom;
% Get a valid axes handle
haTarget = newplot(haTarget);
% Old hold state
lOldHold = ishold(haTarget);
% Tell figure to add next plots
hold(haTarget, 'on');
% Assert we have child data in the axes
assert(~isempty(haTarget.Children), 'Cannot create a zoom region on an empty plot');



%% Processing

%%% Plot the source rectangle
% Determine position of the source rectangle
vCor_Source_Data = [...
    vRegion(1), vRegion(3); ...
    vRegion(2), vRegion(3); ...
    vRegion(2), vRegion(4); ...
    vRegion(1), vRegion(4); ...
];
vPos_Source_Data = [...
    vRegion(1), ... % 
    vRegion(3), ... % 
    vRegion(2) - vRegion(1), ... % 
    vRegion(4) - vRegion(3) ... %
];
vPos_Source_Norm = in_normalizeDataPosition(vPos_Source_Data, haTarget);
% Draw the source rectangle (just now otherwise above 'copyobj' will copy this,
% too)
% vFaces = [1, 2, 3, 4];
% Draw the box as a patch so it can have a face color if desired
% hpSource = patch( ...
%     'Faces', vFaces ...
%     , 'Vertices', vCor_ZoomSource_Data ...
%     , 'FaceColor', 'none' ...
%     , 'EdgeColor', [64, 64, 64]./255 ...
%     , 'LineStyle', '--'  ...
%     , 'Tag', 'SourceMarker' ...
% );
haSource = annotation('rectangle'...
    , vPos_Source_Norm ...
    , 'LineStyle', '--' ...
    , 'EdgeColor', [64, 64, 64]./255 ...
    , 'FaceColor', 'none' ...
);
% Set custom box specs?
if ~isempty(ceSourceBoxSpec)
    set(haSource, ceSourceBoxSpec{:});
end


%%% Some helper values
% Length of axes in data points
vXLim_Data = get(haTarget, 'XLim');
dAxesWidth_Data = vXLim_Data(2) - vXLim_Data(1);
% Width of axes in data points
vYLim_Data = get(haTarget, 'YLim');
dAxesHeight_Data = vYLim_Data(2) - vYLim_Data(1);

%%% Source rectangle


%%% Place the target axes
% Determine the actual width of the target zoom rectangle
dZoomWidth_Data = dZoom*vPos_Source_Data(3);
dZoomHeight_Data = dZoomWidth_Data.*dAxesHeight_Data./dAxesWidth_Data;
% dZoomHeight_Data = dZoom*vPos_ZoomSource_Data(4);
% Detremine the position of the target zoom block's corners in data points
vCor_Target_Data = [...
    vZoomPosition(1) - dZoomWidth_Data./2, vZoomPosition(2) - dZoomHeight_Data./2; ...
    vZoomPosition(1) + dZoomWidth_Data./2, vZoomPosition(2) - dZoomHeight_Data./2; ...
    vZoomPosition(1) + dZoomWidth_Data./2, vZoomPosition(2) + dZoomHeight_Data./2; ...
    vZoomPosition(1) - dZoomWidth_Data./2, vZoomPosition(2) + dZoomHeight_Data./2; ...
];
% Position vector of the target zoom block in data points
vPos_Target_Data = [...
    vCor_Target_Data(1,1), ...
    vCor_Target_Data(1,2), ...
    dZoomWidth_Data, ...
    dZoomHeight_Data, ...
];

% Normalize the position of the target zoom area from data units to normalized
% units
vPos_Target_Norm = in_normalizeDataPosition(vPos_Target_Data, haTarget);

% Create a new axes handle at the specified position
haZoom = axes('Position', vPos_Target_Norm, 'Tag', 'ZoomBox');
% Set options on the zoomed axes?
if ~isempty(ceZoomAxesSpec)
    set(haZoom, ceZoomAxesSpec{:});
end
% Copy all child objects of the big axes to the small axes
hpChildren = copyobj(allchild(haTarget), haZoom);

% Set x- and y-axis limits
xlim(haZoom, [vRegion(1), vRegion(2)]);
ylim(haZoom, [vRegion(3), vRegion(4)]);

% Draw a box around the axes
box(haZoom, 'on');

% Cleanup the child objects to remove superfluous data
for iChild = 1:numel(hpChildren)
    % Get information on the current plot
    stPlotInfo = get(hpChildren(iChild));
    
    % Determine which data values to keep
    alKeepFlags = stPlotInfo.XData >= vCor_Source_Data(1,1) & stPlotInfo.XData <= vCor_Source_Data(2,1);
    % Check we we have Y-Data that is within the range of the source box
    if all(stPlotInfo.YData(alKeepFlags) <= max(vCor_Source_Data(:,2))) && all(stPlotInfo.YData(alKeepFlags) >= min(vCor_Source_Data(:,2)))
        % Just to make sure we're not losing any data, we will also keep one
        % plot data to the left and right of the zoom region
        nFirstKeep = find(alKeepFlags, 1, 'first');
        nLastKeep = find(alKeepFlags, 1, 'last');
        % Keep one plot value to the left, too
        if nFirstKeep > 1
            alKeepFlags(nFirstKeep-1) = 1;
        end
        % Keep one plot value to the right, too
        if nLastKeep < ( numel(stPlotInfo.XData) - 1 )
            alKeepFlags(nLastKeep+1) = 1;
        end
        % Update plot with data within x-range
        set(hpChildren(iChild)...
            , 'XData', stPlotInfo.XData(alKeepFlags) ...
            , 'YData', stPlotInfo.YData(alKeepFlags) ...
        );
    % All y-values fall outside the zoom region, so there's no need to keep this
    % object any longer since it's just taking up storage space but not
    % contributing to the image
    else
        delete(hpChildren(iChild));
    end
end

% Restore the old axes handle
axes(haTarget);

% Holds the two created annotation lines
haLines = gobjects(2);

% % Need draw zoom lines?
if strcmp(chZoomLines, 'on')
    % Get the center of the source data and the target data
    vPos_Center_Source_Data = [mean(vPos_Source_Data(:,1)), mean(vPos_Source_Data(:,2))];
    vPos_Center_Target_Data = [mean(vPos_Target_Data(:,1)), mean(vPos_Target_Data(:,2))];
    
    % Logical comparison of the positions of target and source: check if target
    % is to the right and top of source
    vRelPos = vPos_Center_Source_Data < vPos_Center_Target_Data;
    
    % Target is to the right and top of source || target is to the left and
    % bottom of source
    if all(vRelPos) || all(~vRelPos)
        vCorners = [2, 4];
    % Any other case
    else
        vCorners = [1, 3];
    end

    % Normalize the data for the start and end point of annotation line 1
    vPlotL1_S_Norm = in_normalizeDataPosition([vCor_Source_Data(vCorners(1),1), vCor_Source_Data(vCorners(1),2)], haTarget);
    vPlotL1_E_Norm = in_normalizeDataPosition([vCor_Target_Data(vCorners(1),1), vCor_Target_Data(vCorners(1),2)], haTarget);
    % Normalize the data for the start and end point of annotation line 2
    vPlotL2_S_Norm = in_normalizeDataPosition([vCor_Source_Data(vCorners(2),1), vCor_Source_Data(vCorners(2),2)], haTarget);
    vPlotL2_E_Norm = in_normalizeDataPosition([vCor_Target_Data(vCorners(2),1), vCor_Target_Data(vCorners(2),2)], haTarget);
    
    % Annotate the two lines from start to end
    haLines(1) = annotation('line', [vPlotL1_S_Norm(1), vPlotL1_E_Norm(1)], [vPlotL1_S_Norm(2), vPlotL1_E_Norm(2)]);
    haLines(2) = annotation('line', [vPlotL2_S_Norm(1), vPlotL2_E_Norm(1)], [vPlotL2_S_Norm(2), vPlotL2_E_Norm(2)]);

    % Set line specific styles?
    if ~isempty(ceZoomLinesSpec)
        set(haLines(1), ceZoomLinesSpec{1}{:});
        set(haLines(2), ceZoomLinesSpec{2}{:});
    end
end

% Stack the source axes (the big one) below the target axes (the small one)
uistack(haTarget, 'bottom');

% Finally, make sure the figure is drawn
drawnow

% Reset the old hold state if it wasn't set
if ~lOldHold
    hold(haTarget, 'off');
end



%% Assign output quantities
% First optional output
if nargout > 0
    % Handle to the zoomed axes
    varargout{1} = haZoom;
end

% Second optional output
if nargout > 1
    % Handle to the source rectangle annotation
    varargout{2} = haSource;
end

% Third optional output
if nargout > 2 && strcmp(chZoomLines, 'on')
    % Handle to the zoom lines
    varargout{3} = haLines;
end


end



function out = in_charToValidArgument(in)

switch lower(in)
    case {'on', 'yes', 'please'}
        out = 'on';
    case {'off', 'no', 'never'}
        out = 'off';
    otherwise
        out = 'off';
end

end


function vPos_Norm = in_normalizeDataPosition(vPos_Data, haReference)

% Length of axes in data points
vXLim_Data = get(haReference, 'XLim');
dAxesWidth_Data = vXLim_Data(2) - vXLim_Data(1);
% Width of axes in data points
vYLim_Data = get(haReference, 'YLim');
dAxesHeight_Data = vYLim_Data(2) - vYLim_Data(1);
% Position of axes in normalized units
vPos_Axes_Norm = get(haReference, 'Position');

% Calculate the ratio between data unit to normalized unit in x and y
% independently
dRatio_Norm2Data_X = dAxesWidth_Data / vPos_Axes_Norm(3); 
dRatio_Norm2Data_Y = dAxesHeight_Data / vPos_Axes_Norm(4);

% Calculate normalized data
vPos_Norm(1) = (vPos_Data(1) - vXLim_Data(1)) / dRatio_Norm2Data_X + vPos_Axes_Norm(1);
vPos_Norm(2) = (vPos_Data(2) - vYLim_Data(1)) / dRatio_Norm2Data_Y + vPos_Axes_Norm(2);
% If there's a width and heigh given, normalize them, too
if numel(vPos_Data) > 2
    vPos_Norm(3) = (vPos_Data(3)) / dRatio_Norm2Data_X;
    vPos_Norm(4) = (vPos_Data(4)) / dRatio_Norm2Data_Y;
end

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
