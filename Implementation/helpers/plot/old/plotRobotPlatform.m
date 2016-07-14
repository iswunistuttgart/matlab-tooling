function [varargout] = plotRobotPlatform(CableAttachments, varargin)
% PLOTROBOTFRAME Plot the robot platform as given by the cable attachment points
% 
%   PLOTROBOTFRAME(CABLEATTACHMENTS) plots the mobile platform in a new 3D plot
%   
%   HAXES = PLOTROBOTFRAME(CABLEATTACHMENTS) returns handle to the axes that has
%   been plotted into
%
%   [HAXES, HATTACHMENTS] = PLOTROBOTFRAME(CABLEATTACHMENTS) returns also the
%   handle of the cable attachments plot
%   
%   PLOTROBOTFRAME(AX, CABLEATTACHMENTS, ...) plots the cable attachments into
%   the specified axes
%
%   PLOTROBOTFRAME(CABLEATTACHMENTS, 'ParameterName', 'ParameterValue', ...)
%   allows to specify optional parameter name/value pairs
%   
%   CABLEATTACHMENTS: Matrix of cable attachments of size 3xM where each column
%   represents one winch with its rows defined as [x; y; z]. Any number of
%   winches may be given in any order.
%
%   Optional Inputs -- specified as parameter value pairs
%   PlotSpec            - allows to adjust the plot spec for the cable
%                       attachment markers. By default, the 'o' markers are
%                       plotted as markers for the winches in the first default
%                       axis color
%
%   BoundingBox         - will also print the bounding box of the cable
%                       attachments.
%
%   BoundingBoxSpec     - will print the bounding box with 'r' lines instead of
%                       the default 'k' lines. See documentation of Patch Spec
%                       for available options.
%   
%   Viewport            - adjusts the viewport of the 3d plot to the set values.
%                       Allowed values are [az, el], [x, y, z], 2, 3. See
%                       documentation of view for more info.
%   
%   AnchorLabels        - to set specific labels for the corresponding winch. In
%                       case of a cell array, it must be a row cell array and
%                       have as many entries as CABLEATTACHMENTS has columns.
%   
%   AnchorLabelSpec     - to set further spec on the winch labels. Check the
%                       documentation for TextProperties on more info.
%   
%   CogPosition        - will plot the home position as the specified position
%                       given as a [x; y; z] column vector. Home position will
%                       be a diamond 'd' marker colored in 'k'.
%   
%   CogPositionSpec    - to set the spec of the home position as e.g., color,
%                       marker, marker size, etc.. See Chart Line Properties for
%                       available options.
%   
%   Grid                - to define the grid style. Any of the following options
%                       are allowed
%       'on'        turns major grid on
%       'off'       turns all grids off
%       'minor'     turns minor and major grid on
%   
%   Title               - puts a title on the figure.
%   
%   XLabel              - sets the x-axis label to the specified char.
%
%   YLabel              - sets the y-axis label to the specified char.
%   
%   ZLabel              - sets the z-axis label to the specified char.
%
%   See also: VIEW, PLOT3, TEXT, PATCH, GRID, TITLE, XLABEL, YLABEL, ZLABEL



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-07-14
% TODO:
%   Add ability to plot platform at a random point/pose e.g, 'PlaceAt', [0,0,0,
%   0,0,0] where this is [x,y,z, a,b,c]. Then all other plots respective the
%   platform are relative to that position
% Changelog:
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%   2016-05-24
%       * Remove standalone mode. Now everything is "global"
%       * Update help doc to properly include info on name/value pairs
%   2016-03-30
%       * Code cleanup
%   2015-04-26
%       * Introduce options 'XLabel', 'YLabel', 'ZLabel', 'Title'. Also fix the
%       logic behind {'AnchorLabels', true} so we won't have duplicate code for
%       doing basically the same thing in a different way.
%       * Change all inputs to have column major i.e., one column is a logical
%       unit whereas between columns, the "thing" might change. That means,
%       given the winches, if we look at one column, we see the data of one
%       winch, whereas if we looked at the first row, we can read info on the
%       x-values of all winches
%   2015-04-24
%       * Initial release



%% Preprocess inputs (allows to have the axis defined as first argument)
% By default we don't have any axes handle
haAxes = false;
% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && isallaxes(CableAttachments)
    haAxes = CableAttachments;
    CableAttachments = varargin{1};
    varargin = varargin(2:end);
end



%% Define the input parser
ip = inputParser;

% Require: Winch Positions. Must be a matrix of size 3xM
% valFcn_CableAttachments = @(x) ismatrix(x) && isequal(size(x, 1), 3);
valFcn_CableAttachments = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3}, mfilename, 'CableAttachments');
addRequired(ip, 'CableAttachments', valFcn_CableAttachments);

% We need the axes handle which is allowed to be the first optional
% argument which must not be used with a parameter name
% valFcn_Axes = @(x) validateattributes(x, {'handle', 'matlab.graphics.axis.Axes'}, {}, mfilename, 'Axes');
% addOptional(ip, 'Axes', false, valFcn_Axes);

% Allow the plot to have user-defined spec
valFcn_PlotSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'PlotSpec');
addOptional(ip, 'PlotSpec', {}, valFcn_PlotSpec);

% Bounding box about the cable attachments? May be any numeric or logical value
valFcn_BoundingBox = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'BoundingBox'));
addOptional(ip, 'BoundingBox', 'off', valFcn_BoundingBox);

% Maybe the bounding box must have other spec as the ones we use here?
valFcn_BoundingBoxSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'BoundingBoxSpec');
addOptional(ip, 'BoundingBoxSpec', {}, valFcn_BoundingBoxSpec);

% The 3d view may be defined, too. Viewport may be 2, 3, [az, el], or [x, y, z]
valFcn_Viewport = @(x) validateattributes(x, {'logical', 'numeric'}, {'2d'}, mfilename, 'Viewport');
addOptional(ip, 'Viewport', [-19, 18], valFcn_Viewport);

% Maybe also display the winch labels? Or custom labels?
valFcn_AnchorLabels = @(x) validateattributes(x, {'numeric', 'cell'}, {'2d', 'ncols', size(CableAttachments, 2)}, mfilename, 'AnchorLabels');
addOptional(ip, 'AnchorLabels', {}, valFcn_AnchorLabels);

% Some style spec to set on the winch labels?
valFcn_AnchorLabelSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'AnchorLabelSpec');
addOptional(ip, 'AnchorLabelSpec', {}, valFcn_AnchorLabelSpec);

% Also print the home position? Can be either a logical 'true' to print at
% [0, 0, 0], or the explicit home position as a 1x3 column vector
valFcn_CogPosition = @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}, mfilename, 'CogPosition');
addOptional(ip, 'CogPosition', false, valFcn_CogPosition);

% Some style spec for the home position to plot?
valFcn_CogPositionSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'CogPositionSpec');
addOptional(ip, 'CogPositionSpec', {}, valFcn_CogPositionSpec);

% Allow user to choose grid style (either 'on', 'off', or 'minor')
valFcn_Grid = @(x) any(validatestring(x, {'on', 'off', 'minor'}, mfilename, 'Grid'));
addOptional(ip, 'Grid', 'off', valFcn_Grid);

% Allow user to set the xlabel ...
valFcn_XLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'XLabel');
addOptional(ip, 'XLabel', '', valFcn_XLabel);

% Allow user to set the ylabel ...
valFcn_YLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'YLabel');
addOptional(ip, 'YLabel', '', valFcn_YLabel);

% And allow user to set the zlabel
valFcn_ZLabel = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'ZLabel');
addOptional(ip, 'ZLabel', '', valFcn_ZLabel);

% Maybe a title is provided and shall be plotted, too?
valFcn_Title = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Title');
addOptional(ip, 'Title', '', valFcn_Title);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    parse(ip, CableAttachments, varargin{:});
catch me
    throw(MException(me.identifier, me.message));
end



%% Parse variables of the input parser to local parser
% Ensure the handle for the axes is a valid handle. If none given, we will
% create our own figure with handle
if ~ishandle(haAxes)
    haAxes = gca;
% Check we are looking at a 3D plot, if a plot is given
else
    [az, el] = view(haAxes);
    assert(~isequaln([az, el], [0, 90]), 'Cannot plot a 3D plot into an existing 2D plot.');
end

mxdCableAttachments = ip.Results.CableAttachments;
% Parse winch labels
ceAnchorLabels = ip.Results.AnchorLabels;
bAnchorLabels = ~isempty(ceAnchorLabels);
% If just set to anything like true, we will magically create the labels by the
% number of winches we have
% Spec for the winch labels can be set, too
ceAnchorLabelSpec = ip.Results.AnchorLabelSpec;
% Plot spec
cePlotSpec = ip.Results.PlotSpec;
% Bounding box?
chBoundingBox = inCharToValidArgument(ip.Results.BoundingBox);
% Spec on the bounding box
ceBoundingBoxSpec = ip.Results.BoundingBoxSpec;
% Viewport settings
mxdViewport = ip.Results.Viewport;
% Home position to plot
vCogPosition = ip.Results.CogPosition;
bCogPosition = ~isequal(vCogPosition, 0);
% Spec on the home position
ceCogPositionSpec = ip.Results.CogPositionSpec;
% Parse the option for the grid
chGrid = ip.Results.Grid;
% bGrid = ~isequal(chGrid, 0);
% Get the desired figure title (works only in standalone mode)
chTitle = ip.Results.Title;
% Get provided axes labels
chXLabel = ip.Results.XLabel;
chYLabel = ip.Results.YLabel;
chZLabel = ip.Results.ZLabel;



%% Plot the damn thing now!
% Select the given axes as target
axes(haAxes);

% Ensure we have the axes on hold so we don't accidentaly overwrite its
% content
hold(haAxes, 'on');

% First, plot the cable attachments as circles
hpCableAttachments = plot3(mxdCableAttachments(1, :), mxdCableAttachments(2, :), mxdCableAttachments(3, :), 'o');
% If the plot spec were given, we need to set them on the plot
if ~isempty(cePlotSpec)
    set(hpCableAttachments, cePlotSpec{:});
end

% Label the winches (either as given by the user or as pre-defined values)
if bAnchorLabels
    htAnchorLabels = zeros(size(ceAnchorLabels, 2));
    for iUnit = 1:size(ceAnchorLabels, 2)
        htAnchorLabels(iUnit) = text(mxdCableAttachments(1, iUnit), mxdCableAttachments(2, iUnit), mxdCableAttachments(3, iUnit), ...
            num2str(ceAnchorLabels{iUnit}), 'VerticalAlignment', 'bottom', 'FontSize', 10);
        if ~isempty(ceAnchorLabelSpec)
            set(htAnchorLabels, ceAnchorLabelSpec{:});
        end
    end
end

% Plot the home position?
if bCogPosition
    % Plot the home position as a black marker
    hpCogPosition = plot3(vCogPosition(1), vCogPosition(2), vCogPosition(3), 'Color', 'k', 'Marker', 'd');
    
    % Set spec on the home positon?
    if ~isempty(ceCogPositionSpec)
        set(hpCogPosition, ceCogPositionSpec{:});
    end
end


% Plot the bounding box?
if strcmp(chBoundingBox, 'on')
    % Get the bounding box for the cable attachments
    [mCableAttachmentsBoundingBox, mCableAttachmentsBoundingBoxFaces] = bbox3(mxdCableAttachments(1,:), mxdCableAttachments(2,:), mxdCableAttachments(3,:));
    
    % And create a hollow patch from the bounding box
    hpBoundingBox = patch('Vertices', mCableAttachmentsBoundingBox, 'Faces', mCableAttachmentsBoundingBoxFaces, 'FaceColor', 'none');
    
    % Spec to set on the bounding box? No problemo!
    if ~isempty(ceBoundingBoxSpec)
        set(hpBoundingBox, ceBoundingBoxSpec{:});
    end
end

% Set x-axis label, if provided
if ~isempty(strtrim(chXLabel))
    xlabel(haAxes, chXLabel);
end
% Set y-axis label, if provided
if ~isempty(strtrim(chYLabel))
    ylabel(haAxes, chYLabel);
end
% Set z-axis label, if provided
if ~isempty(strtrim(chZLabel))
    zlabel(haAxes, chZLabel);
end

% Set a figure title?
if ~isempty(strtrim(chTitle))
    title(haAxes, chTitle);
end

% Set the viewport
view(haAxes, mxdViewport);

% Set a grid?
if any(strcmp(chGrid, {'on', 'minor'}))
    % Set grid on
    grid(haAxes, chGrid);
    % For minor grids we will also enable the "major" grid
    if strcmpi(chGrid, 'minor')
        grid(haAxes, 'on');
    end
end

% Finally, set the active axes handle to be the first most axes handle we
% have created or were given a parameter to this function
axes(haAxes);

% Enforce drawing of the image before returning anything
drawnow

% Clear the hold off the current axes
hold(haAxes, 'off');



%% Assign output quantities
% First optional output argument is axes handle
if nargout > 0
    varargout{1} = haAxes;
end

% Second optional output argument is cable attachments
if nargout > 1
    varargout{2} = hpCableAttachments;
end


end


function out = inCharToValidArgument(in)

switch lower(in)
    case {'on', 'yes', 'please'}
        out = 'on';
    case {'off', 'no', 'never'}
        out = 'off';
    otherwise
        out = 'off';
end
% end ```switch lower(in)```

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
