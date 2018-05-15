function varargout = plot_colbox(colors, varargin)
% PLOT_COLBOX plots a colored box (patch) for the given color
%
%   PLOT_COLBOX(COLORS) plots the colors as boxes in an evenly distributed grid.
%
%   PLOT_COLBOX(COLORS, 'Name', 'Value', ...) allows setting optional inputs
%   using name/value pairs.
%
%   Inputs:
%
%   COLORS              Mx3 array of colors to plot. Each color will be plotted
%                       into its own rectangle of a specified width and with a
%                       given padding.
%
%   Optional Inputs -- specified as parameter value pairs
%
%   Edge                Edge length of each colored box. Defaults to 10 (units).
%
%   Padding             Padding around each box. Defaults to 2 (units).
%
%   Rows                Number of rows to plot boxes in to. By default, the
%                       boxes are plotted columnwise such that the number of
%                       rows is evenly distributed.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-01-23
% Changelog:
%   2018-01-23
%       * Update procedure to support custom rows count
%   2017-02-24
%       * Initial release



%% Define the input parser
ip = inputParser;

% Required: Colors; numeric; 2d, non-empty, non-sparse, finite, non-negative, <=
% 1, ncols == 3
valFcn_Colors = @(x) validateattributes(x, {'numeric'}, {'2d', 'nonempty', 'ncols', 3, 'nonsparse', 'finite', 'nonnegative', '<=', 1}, mfilename, 'colors');
addRequired(ip, 'Colors', valFcn_Colors);

% Parameter: Edge; numeric; scalar, non-empty, non-sparse, finite, non-negative
valFcn_Edge = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'nonsparse', 'finite', 'nonnegative'}, mfilename, 'edge');
addParameter(ip, 'Edge', 10, valFcn_Edge);

% Parameter: Padding; numeric; scalar, non-empty, non-sparse, finite, non-negative
valFcn_Padding = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'nonsparse', 'finite', 'nonnegative'}, mfilename, 'padding');
addParameter(ip, 'Padding', 2, valFcn_Padding);

% Parameter: Rows; numeric; scalar, non-empty, non-sparse, finite, non-negative
valFcn_Rows = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'nonsparse', 'finite', 'nonnegative'}, mfilename, 'rows');
addParameter(ip, 'Rows', 0, valFcn_Rows);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    varargin = [{colors}, varargin];
    [haTarget, args, ~] = axescheck(varargin{:});
    
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results
% Colors to plot
aColors = ip.Results.Colors;
% Edge length
dRectangle_EdgeLength = ip.Results.Edge;
% Padding around rectangles
dRectangle_Padding = ip.Results.Padding;
% Number of columns to plot
nRows = ip.Results.Rows;



%% Do your code magic here
% Number of colors to plot
nColors = size(aColors, 1);
% Default to square distribution of colored boxes to plot
if nRows == 0
    % How many rows and cols of rectangles?
    nRows = ceil(sqrt(nColors));
end
nCols = ceil(nColors/nRows);

% Get a valid axes handle
haTarget = newplot(haTarget);

% Old hold state
lOldHold = ishold(haTarget);

% Hold axes
hold(haTarget, 'on');

% Stores the plotted patches
hPatches = gobjects(nRows, nCols);

% Init image
aImg = 255*ones((nRows + 1)*dRectangle_Padding + nRows*dRectangle_EdgeLength , (nCols + 1)*dRectangle_Padding + nCols*dRectangle_EdgeLength, 3, 'uint8');

% Loop over each color
for iColor = 1:nColors
    % Get column and row index for the linearly indexed color
    [iCur_Col, iCur_Row] = ind2sub([nRows, nCols], iColor);
    
    vRectangle_X = (iCur_Col - 1).*(dRectangle_EdgeLength + dRectangle_Padding) + dRectangle_Padding + ([1, dRectangle_EdgeLength]);
    vRectangle_Y = (iCur_Row - 1).*(dRectangle_EdgeLength + dRectangle_Padding) + dRectangle_Padding + ([1, dRectangle_EdgeLength]);
    
    aImg(vRectangle_X(1):vRectangle_X(end),vRectangle_Y(1):vRectangle_Y(end),1) = aColors(iColor,1).*255;
    aImg(vRectangle_X(1):vRectangle_X(end),vRectangle_Y(1):vRectangle_Y(end),2) = aColors(iColor,2).*255;
    aImg(vRectangle_X(1):vRectangle_X(end),vRectangle_Y(1):vRectangle_Y(end),3) = aColors(iColor,3).*255;
    
%     hPatches(iCur_Row, iCur_Col) = patch(vRectangle_X([1, 2, 2, 1, 1]), vRectangle_Y([1, 1, 2, 2, 1]), aColors(iColor,:), 'EdgeColor', aColors(iColor,:));
end

% Show the image we created
imshow(aImg, 'Parent', haTarget, 'Border', 'tight');

% Set the limites
% xlim([0, nCols*(dRectangle_EdgeLength + 2*dRectangle_Padding)]);
% ylim([0, nRows*(dRectangle_EdgeLength + 2*dRectangle_Padding)]);

% Finally, make sure the figure is drawn
drawnow

% Reset the old hold state if it wasn't set
if ~lOldHold
    hold(haTarget, 'off');
end



%% Assign output quantities
if nargout > 0
    varargout{1} = hPatches;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
