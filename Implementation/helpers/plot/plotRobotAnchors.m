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
%   BoundBox        Plots a bounding box around the values of ANCHORS that
%                   contains all points of ANCHORS.
%
%   BoundBoxSpec    Cell array of specifications applied to bounding box (which
%                   is a patch figure object).
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
%   Camera          Set the projection type of the plot. Possible options are
%       'ortographic' and 'perspective'.
%
%   PlotStyle       Defines the plot style which will be used independent of the
%                   axes that the plot will be placed in. Supported values are
%                   2D      plot [Y] against [X] (plots second row of ANCHORS
%                           against first row)
%                   3D      plot [Z] against [Y] against [X] (plots third row of
%                           ANCHORS against second row of ANCHORS aganst first
%                           row)



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-13
% Changelog:
%   2016-09-13
%       * Remove all plot styles but 2D and 3D
%       * Update script to determine plot style automatically if not provided
%       but an axes is given with hold on
%   2016-09-12
%       * Add parameter 'Camera' to change camera perspective of 3D plots
%   2016-09-07
%       * Fix bug with cycliccell not being created correctly
%       * Add support for usage of parseswitcharg()
%   2016-08-23
%       * Fix wrong access to gobjects of label and anchor graphic objects
%   2016-08-12
%       * Remove no longer needed inline function in_getCyclicValue in favor of
%       cycliccell
%   2016-08-02
%       * Change to using gobjects for holding returned graphic handles
%       * Change to using ```axescheck``` and ```newplot```
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%       * Wedge out param-value pairs to only the needed ones
%       * Introduce option 'LabelSpec'
%   2016-06-23
%       * Initial release (from plotRobotFrame and plotRobotPlatform)



%% Define the input parser
ip = inputParser;

% Anchors. Numeric. 2D array. 3 Rows
valFcn_Anchors = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3}, mfilename, 'Anchors');
addRequired(ip, 'Anchors', valFcn_Anchors);

% AnchorSpec. Cell or numeric. Non-empty.
valFcn_AnchorSpec = @(x) validateattributes(x, {'cell', 'numeric'}, {'nonempty'}, mfilename, 'AnchorSpec');
addParameter(ip, 'AnchorSpec', {}, valFcn_AnchorSpec);

% BoundingBox: Char. Matches {'on', 'off'}
valFcn_BoundBox = @(x) any(validatestring(lower(x), {'on', 'off'}, mfilename, 'BoundingBox'));
addParameter(ip, 'BoundingBox', 'off', valFcn_BoundBox);

% BoundingBoxSpec: Cell. Non-empty.
valFcn_BoudBoxSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'BoundBoxSpec');
addParameter(ip, 'BoundingBoxSpec', {}, valFcn_BoudBoxSpec);

% WinchLabels: Cell. Non-empty.
valFcn_WinchLabels = @(x) validateattributes(x, {'numeric', 'cell'}, {'nonempty', 'row', 'numel', size(Anchors, 2)}, mfilename, 'WinchLabels');
addParameter(ip, 'Labels', {}, valFcn_WinchLabels);

% LabelSpec. Cell array. Non-empty.
valFcn_LabelSpec = @(x) validateattributes(x, {'cell', 'numeric'}, {'nonempty'}, mfilename, 'LabelSpec');
addParameter(ip, 'LabelSpec', {}, valFcn_LabelSpec);

% PlotStyle: Char. Matches {'2D', '3D'}.
valFcn_PlotStyle = @(x) any(validatestring(upper(x), {'2D', '3D'}, mfilename, 'PlotStyle'));
addParameter(ip, 'PlotStyle', '', valFcn_PlotStyle);

% Parameter: Camera. Char. Matches {'orthographic', 'perspective'}
valFcn_Camera = @(x) any(validatestring(lower(x), {'orthographic', 'perspective'}, mfilename, 'Camera'));
addParameter(ip, 'Camera', '', valFcn_Camera);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    varargin = [{Anchors}, varargin];
    [haTarget, args, ~] = axescheck(varargin{:});
    
    parse(ip, args{:});
catch me
    throwAsCaller(MException(me.identifier, me.message));
end



%% Parse variables of the input parser to local parser
if ~isempty(haTarget)
    if isplot3d(haTarget)
        chPlotStyle = '3D';
    else
        chPlotStyle = '2D';
    end
end
% Get a valid axes handle
haTarget = newplot(haTarget);
% Old hold state
lOldHold = ishold(haTarget);
if lOldHold
    if isplot3d(haTarget)
        chPlotStyle = '3D';
    else
        chPlotStyle = '2D';
    end
end
% Tell figure to add next plots
hold(haTarget, 'on');
% Anchors
aAnchors = ip.Results.Anchors;
% Number of anchors
nAnchors = size(aAnchors, 2);
% Anchor specs: cell array
ceAnchorSpecs = cycliccell(ip.Results.AnchorSpec, nAnchors);
% Labels: cell array
ceLabels = ip.Results.Labels;
% Label specs: cell array
ceLabelSpecs = cycliccell(ip.Results.LabelSpec, nAnchors);
% Plot style: char
if ~isempty(ip.Results.PlotStyle) && ~exist('chPlotStyle', 'var')
    chPlotStyle = ip.Results.PlotStyle;
end
% Box switch: 'on' or 'off'
chBBox = parseswitcharg(ip.Results.BoundingBox);
% Box specifiactions: cell array
ceBBoxSpec = ip.Results.BoundingBoxSpec;
% Perspetive
chCamera = ip.Results.Camera;



%% Asserting data
% Assert we have at least two rows for the anchors
assert(size(aAnchors, 1) >= 2, 'Number of anchor coordinates in Anchors must be greater or equal to 2');
% Assert for a 3D plot we have 3 rows for each anchor
assert(strcmpi(chPlotStyle, '2D') || size(aAnchors, 1) == 3, 'Insufficient number of rows for Anchors for selected plot style. Must be 3xN');



%% Processing
if isempty(haTarget.Children) && strcmpi(chPlotStyle, '3d')
    view([-37.5, 30]);
end

% Cell array to collect plot anchor handles
hpAnchors = gobjects(nAnchors, 1);
% Cell array to hold text labels
htLabels = gobjects(nAnchors, 1);
% Holds the bounding box patch handle
hpBoundingBox = gobjects(0);

% Plot the anchors
for iAnchor = 1:nAnchors
    % Plot the current anchor in 3D
    if strcmpi('3d', chPlotStyle)
        hpAnchors(iAnchor) = plot3(aAnchors(1,iAnchor), aAnchors(2,iAnchor), aAnchors(3,iAnchor), 'o');
    else
        hpAnchors(iAnchor) = plot(aAnchors(1,iAnchor), aAnchors(2,iAnchor), 'o');
    end

    % Set custom anchor drawing specs?
    if ~isempty(ceAnchorSpecs)
        set(hpAnchors{iAnchor}, ceAnchorSpecs{iAnchor}{:});
    end

    % If we shall plot a label, too
    if ~isempty(ceLabels)
        % Place a text anchor in 3D
        if strcmpi('3d', chPlotStyle)
            htLabels(iAnchor) = text(aAnchors(1,iAnchor), aAnchors(2,iAnchor), aAnchors(3,iAnchor), ...
                num2str(ceLabels{iAnchor}));
        % Place a text anchor in 2D
        else
            htLabels(iAnchor) = text(aAnchors(1,iAnchor), aAnchors(2,iAnchor), ...
                num2str(ceLabels{iAnchor}));
        end
        
        % Custom label drawing specifications
        if ~isempty(ceLabelSpecs)
            set(htLabels(iAnchor), ceLabelSpecs{iAnchor}{:});
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

% Set the camera perspective, but only on 3D plots (2D don't support that)
if strcmp('3d', chPlotStyle) && ~isempty(chCamera)
    camproj(chCamera);
end

% Finally, make sure the figure is drawn
drawnow

% Reset the old hold state if it wasn't set
if ~lOldHold
    hold(haTarget, 'off');
end



%% Assign output quantities

% None so far


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
