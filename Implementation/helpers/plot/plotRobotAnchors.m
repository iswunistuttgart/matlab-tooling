function plotRobotAnchors(Anchors, varargin)
% PLOTROBOTANCHORS plots anchors for the robot
%
%   PLOTROBOTANCHORS(ANCHORS) plots the anchors in 3D or 2D space
%
%   Optional Inputs -- specified as parameter value pairs
%   AnchorSpec      Cell array of anchor specs that will be applied to each
%                   anchor. If a two-dimensional cell array is determined, the
%                   specifications will be applied to each anchor cyclically. A
%                   two-dimensional cell array will be determined by checking
%                   whether the first value of 'AnchorSpec' is a cell array in
%                   itself.
%   
%   Labels          Cell array of labels that shall be placed nex to the anchors
%                   in consecutive order. Labels will be repeated cyclically.
%
%   LabelSpec       Cell array of anchor specs that will be applied to each
%                   anchor. If a two-dimensional cell array is determined, the
%                   specifications will be applied to each anchor cyclically. A
%                   two-dimensional cell array will be determined by checking
%                   whether the first value of 'AnchorSpec' is a cell array in
%                   itself.
%
%   PlotStyle       Defines the plot style which will be used independent of the
%                   axes that the plot will be placed in. Supported values are
%                   2D      plot [Y] against [X] (plots second row of ANCHORS
%                           against first row)
%                   3D      plot [Z] against [Y] against [X] (plots third row of
%                           ANCHORS against second row of ANCHORS aganst first
%                           row)
%
%   BoundBox        Plots a bounding box around the values of ANCHORS that
%                   contains all points of ANCHORS.
%
%   BoundBoxSpec    Cell array of specifications applied to bounding box (which
%                   is a patch figure object).



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-07-14
% Changelog:
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%       * Wedge out param-value pairs to only the needed ones
%       * Introduce option 'LabelSpec'
%   2016-06-23
%       * Initial release (from plotRobotFrame and plotRobotPlatform)



%% Preprocess inputs (allows to have the axis defined as first argument)
% By default we don't have any axes handle
haTarget = false;
% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && isallaxes(Anchors)
    haTarget = Anchors;
    Anchors = varargin{1};
    varargin = varargin(2:end);
end



%% Define the input parser
ip = inputParser;

% Require: Anchors. Must be a 3xN array
valFcn_Anchors = @(x) validateattributes(x, {'numeric'}, {'2d'}, mfilename, 'Anchors');
addRequired(ip, 'Anchors', valFcn_Anchors);

% Optional 1: AnchorSpec. One-dimensional or two-dimensional cell-array
valFcn_AnchorSpec = @(x) validateattributes(x, {'cell'}, {'nonempty', 'row'}, mfilename, 'AnchorSpec');
addParameter(ip, 'AnchorSpec', {}, valFcn_AnchorSpec);

% Maybe also display the winch labels? Or custom labels?
valFcn_WinchLabels = @(x) validateattributes(x, {'numeric', 'cell'}, {'nonempty', 'row', 'numel', size(Anchors, 2)}, mfilename, 'WinchLabels');
addParameter(ip, 'Labels', {}, valFcn_WinchLabels);

% Parameter 2: LabelSpec. One-dimensional or two-dimensional cell-array
valFcn_LabelSpec = @(x) validateattributes(x, {'cell'}, {'nonempty', 'row'}, mfilename, 'LabelSpec');
addParameter(ip, 'LabelSpec', {}, valFcn_LabelSpec);

% Let user decide on the plot style
% Plot style can be chosen anything from the list below
valFcn_PlotStyle = @(x) any(validatestring(x, {'2D', '2DXY', '2DYX', '2DYZ', '2DZY', '2DXZ', '2DZX', '3D'}, mfilename, 'PlotStyle'));
addParameter(ip, 'PlotStyle', '2D', valFcn_PlotStyle);

% Bounding box about the winch positions? May be any numeric or logical value
valFcn_BoundBox = @(x) any(validatestring(lower(x), {'on', 'off', 'minor'}, mfilename, 'BoundBox'));
addParameter(ip, 'BoundingBox', 'off', valFcn_BoundBox);

% Maybe the bounding box must have other spec as the ones we use here?
valFcn_BoudBoxSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'BoundBoxSpec');
addParameter(ip, 'BoundingBoxSpec', {}, valFcn_BoudBoxSpec);

% The 3d view may be defined, too. Viewport may be 2, 3, [az, el], or [x, y, z]
% valFcn_Viewport = @(x) validateattributes(x, {'logical', 'numeric'}, {'2d'}, mfilename, 'Viewport');
% addParameter(ip, 'Viewport', [-19, 18], valFcn_Viewport);

% Allow user to choose grid style (either 'on', 'off', or 'minor')
% valFcn_Grid = @(x) any(validatestring(x, {'on', 'off', 'minor'}, mfilename, 'Grid'));
% addParameter(ip, 'Grid', 'off', valFcn_Grid);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    parse(ip, Anchors, varargin{:});
catch me
    throwAsCaller(MException(me.identifier, me.message));
end



%% Parse variables of the input parser to local parser
% Anchors
aAnchors = ip.Results.Anchors;
% Number of anchors
nAnchors = size(aAnchors, 2);
% Anchor specs: cell array
ceAnchorSpecs = ip.Results.AnchorSpec;
% Labels: cell array
ceLabels = ip.Results.Labels;
% Label specs: cell array
ceLabelSpecs = ip.Results.LabelSpec;
% Plot style: char
chPlotStyle = ip.Results.PlotStyle;
% Box switch: 'on' or 'off'
chBBox = in_charToValidArgument(ip.Results.BoundingBox);
% Box specifiactions: cell array
ceBBoxSpec = ip.Results.BoundingBoxSpec;



%% Asserting data
% Assert we have at least two rows for the anchors
assert(size(aAnchors, 1) >= 2, 'Number of anchor coordinates in Anchors must be greater or equal to 2');
% Assert for a 3D plot we have 3 rows for each anchor
assert(strcmpi(chPlotStyle, '2D') || size(aAnchors, 1) == 3, 'Insufficient number of rows for Anchors for selected plot style. Must be 3xN');



%% Processing
% If no valid axis handle exists ...
if ~ishandle(haTarget)
    % ... get the current axis
    haTarget = gca;
    % If the current axis is a new i.e., blank axis i.e., has no children, we
    % will rotate it into the default 3D viewport (if plot style is 3D)
    if isempty(haTarget.Children) && strcmpi(chPlotStyle, '3d')
        view([-37.5, 30]);
    end
end
% Hold the current axes so we do not overwrite anything
hold(haTarget, 'on');

% Cell array to collect plot anchor handles
hpAnchorers = cell(nAnchors, 1);
% Cell array to hold text labels
htLabels = cell(nAnchors, 1);
% Holds the bounding box patch handle
hpBoundingBox = [];

% Plot the anchors
for iAnchor = 1:nAnchors
    % Plot the current anchor in 3D
    if strcmpi('3d', chPlotStyle)
        hpAnchorers{iAnchor} = plot3(aAnchors(1,iAnchor), aAnchors(2,iAnchor), aAnchors(3,iAnchor), 'o');
    else
        hpAnchorers{iAnchor} = plot(aAnchors(1,iAnchor), aAnchors(2,iAnchor), 'o');
    end

    % Get the current anchors plot specifications
    ceAnchorSpec = in_getCyclicValue(ceAnchorSpecs, iAnchor);
    % If they're not empty...
    if ~isempty(ceAnchorSpec)
        % ... set them
        set(hpAnchorers{iAnchor}, ceAnchorSpec{:});
    end

    % If we shall plot a label, too
    if ~isempty(ceLabels)
        % Place a text anchor in 3D
        if strcmpi('3d', chPlotStyle)
            htLabels{iAnchor} = text(aAnchors(1,iAnchor), aAnchors(2,iAnchor), aAnchors(3,iAnchor), ...
                num2str(ceLabels{iAnchor}));
        % Place a text anchor in 2D
        else
            htLabels{iAnchor} = text(aAnchors(1,iAnchor), aAnchors(2,iAnchor), ...
                num2str(ceLabels{iAnchor}));
        end
        % Get the current label specifications
        ceLabelSpec = in_getCyclicValue(ceLabelSpecs, iAnchor);

        % If they're not empty...
        if ~isempty(ceLabelSpec)
            % ... set them
            set(htLabels{iAnchor}, ceLabelSpec{:});
        end
    end
end

% Bounding box?
if strcmp(chBBox, 'on')
    % Determine the 3D bounding box
    if strcmpi('3d', chPlotStyle)
        [aBox, aTraversal] = bbox3(aAnchors(1,:), aAnchors(2,:), aAnchors(3,:));
    % Determine the 2D bounding box
    else
        [aBox, aTraversal] = bbox(aAnchors(1,:), aAnchors(2,:));
    end
    % Plot the bounding box as a patch
    hpBoundingBox = patch('Vertices', aBox, 'Faces', aTraversal, 'FaceColor', 'none');

    % And set some custom specs?
    if ~isempty(ceBBoxSpec)
        set(hpBoundingBox, ceBBoxSpec{:});
    end
end

% Finally, make sure the figure is drawn
drawnow


%% Assign output quantities

% None so far


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



function ceValue = in_getCyclicValue(ceSource, iAnchor)

% If the source is not emtpy
if ~isempty(ceSource)
    % Check its not a multi-dim cell aray
    if ~iscell(ceSource{1})
        % Then we will just return the given anchor specs
        ceValue = ceSource;
    % Multi-dim cell array
    else
        % Number of available anchor specs
        nBases = numel(ceSource);
        % Index of the anchor spec we will be using is just the remainder of the
        % division of what anchor number we are processing and how many anchors are
        % available
        iAnchorSelect = mod(iAnchor - 1, nBases) + 1;
        % Assign this as reutrn value
        ceValue = ceSource{iAnchorSelect};
    end
% Source is empty: extracted value is empty
else
    ceValue = {};
end

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
