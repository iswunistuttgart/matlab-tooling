function [varargout] = plotRobotCableShapes(PulleyPositions, PulleyAngles, CableShapes, varargin)
% PLOTROBOTCABLESHAPES Plot the shapes of the given cables
% 
%   PLOTROBOTCABLESHAPES(PULLEYPOSITIONS, PULLEYANGLES, CABLESHAPES) plots the
%   cable shape for each cable starting at is respective pulley position
% 
%   PLOTROBOTFRAME(CABLEATTACHMENTS, 'PlotSpec', PlotSpec, ...) allows to adjust
%   the plot spec for the cable attachment markers. By default, the 'o' markers
%   are plotted as markers for the winches in the first default axis color.
%   
%   PLOTROBOTFRAME(CABLEATTACHMENTS, 'BoundingBox', true, ...) will also
%   print the bounding box of the cable attachments.
%   
%   PLOTROBOTFRAME(CABLEATTACHMENTS, 'BoundingBoxSpec', BoundingBoxSpec, ...)
%   will print the bounding box with 'r' lines instead of the default 'k' lines.
%   See documentation of Patch Spec for available options.
%   
%   PLOTROBOTFRAME(CABLEATTACHMENTS, 'Viewport', viewport, ...) adjusts the
%   viewport of the 3d plot to the set values. Allowed values are [az, el],
%   [x, y, z], 2, 3. See documentation of view for more info. Only works in
%   standalone mode.
%
%   PLOTROBOTFRAME(CABLEATTACHMENTS, 'PulleyLabels', PulleyLabels, ...) to set
%   specific labels for the corresponding winch. In case of a cell array, it
%   must be a row cell array and have as many entries as CABLEATTACHMENTS has
%   columns.
%
%   PLOTROBOTFRAME(CABLEATTACHMENTS, 'PulleyLabelSpec', PulleyLabelSpec, ...) to
%   set further spec on the winch labels. Check the documentation for Text
%   Properties on more info.
%
%   PLOTROBOTFRAME(CABLEATTACHMENTS, 'Grid', Grid, ...) to define the grid style.
%   Any of the following options are allowed
%   
%       'on'        turns major grid on
%       'off'       turns all grids off
%       'minor'     turns minor and major grid on
%   
%   Only works in standalone mode.
%
%   PLOTROBOTFRAME(CABLEATTACHMENTS, 'Title', Title) puts a title on the figure.
%   Only works in standalone mode.
%
%   PLOTROBOTFRAME(CABLEATTACHMENTS, 'XLabel', XLabel) sets the x-axis label to
%   the specified char. Only works in standalone mode.
%
%   PLOTROBOTFRAME(CABLEATTACHMENTS, 'YLabel', YLabel) sets the y-axis label to
%   the specified char. Only works in standalone mode.
%
%   PLOTROBOTFRAME(CABLEATTACHMENTS, 'ZLabel', ZLabel) sets the z-axis label to
%   the specified char. Only works in standalone mode.
%
%   PLOTROBOTFRAME(AX, CABLEATTACHMENTS, ...) plots the cable attachments into the
%   specified axes
%   
%   Inputs:
%   
%   CABLEATTACHMENTS: Matrix of cable attachments of size 3xM where each column
%   represents one winch with its rows defined as [x; y; z]. Any number of
%   winches may be given in any order.
%
%   See also: VIEW, PLOT3, TEXT, PATCH, GRID, TITLE, XLABEL, YLABEL, ZLABEL
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-03-30
% Changelog:
%   2016-03-30
%       * Code cleanup
%   2015-08-31:
%       * Rename options 'AnchorLabel' and 'AnchorLabelSpec' to 'PulleyLabel'
%       and 'PulleyLabelSpec', respectively
%       * Update function to no longer do fancy things with transforming the
%       cable shape in any magic way but not uses the output of algoCableShape_*
%       as a direct argument to the plot command only shifting the shape to
%       start at the cable's respective winch
%   2015-08-24:
%       * Initial release



%% Preprocess inputs (allows to have the axis defined as first argument)
% By default we don't have any axes handle
hAxes = false;
% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && isallaxes(PulleyPositions)
    hAxes = PulleyPositions;
    PulleyPositions = PulleyAngles;
    PulleyAngles = CableShapes;
    CableShapes = varargin{1};
    varargin = varargin(2:end);
end



%% Define the input parser
ip = inputParser;

% Require: Pulley Positions. Must be a matrix of size 3xM
valFcn_PulleyPositions = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3}, mfilename, 'PulleyPositions');
addRequired(ip, 'PulleyPositions', valFcn_PulleyPositions);

% Allow the plot to have user-defined spec
valFcn_PulleyAngles = @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', size(PulleyPositions, 2)}, mfilename, 'PulleyAngles');
addRequired(ip, 'PulleyAngles', valFcn_PulleyAngles);

% Allow the plot to have user-defined spec
valFcn_CableShapes = @(x) validateattributes(x, {'numeric'}, {'3d', 'size', [3, NaN, size(PulleyPositions, 2)]}, mfilename, 'CableShapes');
addRequired(ip, 'CableShapes', valFcn_CableShapes);

% Allow the plot to have user-defined spec
valFcn_PulleyOrientation = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3, 'ncols', size(PulleyPositions, 2)}, mfilename, 'PulleyOrientation');
addOptional(ip, 'PulleyOrientation', zeros(3, size(PulleyPositions, 2)), valFcn_PulleyOrientation);

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
addOptional(ip, 'Viewport', [-13, 10], valFcn_Viewport);

% Maybe also display the winch labels? Or custom labels?
valFcn_PulleyLabels = @(x) validateattributes(x, {'numeric', 'cell'}, {'2d', 'ncols', size(PulleyPositions, 2)}, mfilename, 'PulleyLabels');
addOptional(ip, 'PulleyLabels', {}, valFcn_PulleyLabels);

% Some style spec to set on the winch labels?
valFcn_PulleyLabelSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'PulleyLabelSpec');
addOptional(ip, 'PulleyLabelSpec', {}, valFcn_PulleyLabelSpec);

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
parse(ip, PulleyPositions, PulleyAngles, CableShapes, varargin{:});



%% Parse variables of the input parser to local parser
% Ensure the handle for the axes is a valid handle. If none given, we will
% create our own figure with handle
if ~ishandle(hAxes)
    hFig = figure;
    hAxes = gca;
% Check we are looking at a 3D plot, if a plot is given
else
    [az, el] = view(hAxes);
    assert(~isequaln([az, el], [0, 90]), 'Cannot plot a 3D plot into an existing 2D plot.');
end

% Parse pulley positions
aPulleyPositions = ip.Results.PulleyPositions;
% Parse pulley rotations
% aPulleyAngles = ip.Results.PulleyAngles;
% Parse cable shape
aCableShapes = ip.Results.CableShapes;
% Parse the pulley orientations
% aPulleyOrientation = ip.Results.PulleyOrientation;
% Parse pulley labels
cePulleyLabels = ip.Results.PulleyLabels;
bPulleyLabels = ~isempty(cePulleyLabels);
% If just set to anything like true, we will magically create the labels by the
% number of pulley we have
% Spec for the winch labels can be set, too
cPulleyLabelSpec = ip.Results.PulleyLabelSpec;
% Plot spec
cPlotSpec = ip.Results.PlotSpec;
% Bounding box?
chBoundingBox = inCharToValidArgument(ip.Results.BoundingBox);
% Spec on the bounding box
cBoundingBoxSpec = ip.Results.BoundingBoxSpec;
% Viewport settings
mxdViewport = ip.Results.Viewport;
% Parse the option for the grid
chGrid = ip.Results.Grid;
% bGrid = ~isequal(chGrid, 0);
% Get the desired figure title (works only in standalone mode)
chTitle = ip.Results.Title;
% Get provided axes labels
chXLabel = ip.Results.XLabel;
chYLabel = ip.Results.YLabel;
chZLabel = ip.Results.ZLabel;


% If this is a single plot i.e., the given axes does not have any children, then
% we are completely free at plotting stuff like labels, etc., Otherwise, we will
% really just plot the robot frame
bOwnPlot = isempty(get(hAxes, 'Children'));



%% Plot the damn thing now!
% Select the given axes as target
axes(hAxes);

% Ensure we have the axes on hold so we don't accidentaly overwrite its
% content
hold(hAxes, 'on');

hPlotShapes = zeros(size(aPulleyPositions, 2), 1);

% First, plot all the cable shapes
for iCable = 1:size(aPulleyPositions, 2)
    % Get the cable shape for the winch and squeeze it down to a 2d matrix since
    % it is part of a 3d matrix
    aCableShapeFromWinch = squeeze(aCableShapes(:,:,iCable));
    
    % Affine translation matrix
    aTranslationMatrix = [eye(3), aPulleyPositions(:,iCable); ...
                        zeros(1,3), 1];
    
    % Translate the cable shape from [0,0,0] to the winch position
    aCableShapeGlobal = aTranslationMatrix*[aCableShapeFromWinch; ...
                                            ones(1, size(aCableShapeFromWinch, 2))];
    
    % And plot it.
    hPlotShapes(iCable) = plot3(aCableShapeGlobal(1,:), aCableShapeGlobal(2,:), aCableShapeGlobal(3,:));
end
% If the plot spec were given, we need to set them on the plot
if ~isempty(cPlotSpec)
    set(hPlotShapes, cPlotSpec{:});
end

% Label the winches (either as given by the user or as pre-defined values)
if bPulleyLabels
    for iCable = 1:size(cePulleyLabels, 2)
        hText = text(aPulleyPositions(1, iCable), aPulleyPositions(2, iCable), aPulleyPositions(3, iCable), ...
            num2str(cePulleyLabels{iCable}), 'VerticalAlignment', 'bottom', 'FontSize', 10);
        if ~isempty(cPulleyLabelSpec)
            set(hText, cPulleyLabelSpec{:});
        end
    end
end


% Plot the bounding box?
if strcmp(chBoundingBox, 'on')
    % Get the bounding box for the cable attachments
    [mCableAttachmentsBoundingBox, mCableAttachmentsBoundingBoxFaces] = boundingbox3(aPulleyPositions(1, :), aPulleyPositions(2, :), aPulleyPositions(3, :));
    
    % And create a hollow patch from the bounding box
    hPatch = patch('Vertices', mCableAttachmentsBoundingBox, 'Faces', mCableAttachmentsBoundingBoxFaces, 'FaceColor', 'none');
    
    % Spec to set on the bounding box? No problemo!
    if ~isempty(cBoundingBoxSpec)
        set(hPatch, cBoundingBoxSpec{:});
    end
end

% This is stuff we are only going to do if we're in our own plot
if bOwnPlot
    % Set x-axis label, if provided
    if ~isempty(strtrim(chXLabel))
        xlabel(hAxes, chXLabel);
    end
    % Set y-axis label, if provided
    if ~isempty(strtrim(chYLabel))
        ylabel(hAxes, chYLabel);
    end
    % Set z-axis label, if provided
    if ~isempty(strtrim(chZLabel))
        zlabel(hAxes, chZLabel);
    end
    
    % Set a figure title?
    if ~isempty(strtrim(chTitle))
        title(hAxes, chTitle);
    end
    
    % Set the viewport
    view(hAxes, mxdViewport);
    
    % Set a grid?
    if any(strcmp(chGrid, {'on', 'minor'}))
        % Set grid on
        grid(hAxes, chGrid);
        % For minor grids we will also enable the "major" grid
        if strcmpi(chGrid, 'minor')
            grid(hAxes, 'on');
        end
    end

    % And adjust the axes limits so we don't waste too much space but won't be
    % too narrow on the frame/bounding box, either
%     xlim(hAxes, xlim().*1.05);
%     ylim(hAxes, ylim().*1.05);
%     zlim(hAxes, zlim().*1.05);
end

% Make sure the figure is being drawn before anything else is done
drawnow

% Finally, set the active axes handle to be the first most axes handle we
% have created or were given a parameter to this function
axes(hAxes);

% Enforce drawing of the image before returning anything
drawnow

% Clear the hold off the current axes
hold(hAxes, 'off');



%% Assign output quantities
if nargout >= 1
    varargout{1} = hPlotShapes;
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
