function varargout = plotrange(RangeSelector, varargin)
% PLOTRANGE Determine the range of plotted data from min to max
% 
%   RANGE = PLOTRANGE() gets the 'min+max' range of plotted data for the current
%   axis.
% 
%   RANGE = PLOTRANGE(SELECTOR) gets the range minimum of the current axis.
%   
%   RANGE = PLOTRANGE(AXIS, ...) gets the desired range of the given axis.
%
%   [MIN, MAX] = PLOTRANGE(SELECTOR) returns the minimum and maximum plotranges
%   separately (only works for 'min+max' SELECTOR).
%   
%   Inputs:
%   
%   SELECTOR: A string which must be any of the following set {'min', 'max',
%   'min+max'}. If none is given, 'min+max' is assumed.
%
%   AXIS: A valid axis handle to get the range for.
%
%   Outputs:
%   
%   RANGE: Array of [minX, maxX; minY, maxY] plot ranges for 2D plots or an
%   array of [minX, maxX; minY, maxY; minZ, maxZ] plot ranges for 3D plots.
%   
%   MIN: Vector of [minX, minY] or [minX, minY, minZ] plot ranges for 2D plots
%   or 3D plots, respectively.
%   
%   MAX: Vector of [maxX, maxY] or [maxX, maxY, maxZ] plot ranges for 2D plots
%   or 3D plots, respectively.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-07-14
% Changelog:
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%       * Extend docs and update to new doc file layout
%   2016-03-25
%       * Add possibility to remove two return values [min, max] if requested
%   2016-03-23
%       * Initial release



%% Preprocess inputs (allows to have the axis defined as first argument)
% By default we don't have any axes handle
haAxes = false;
% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && isallaxes(RangeSelector)
    narginchk(2, Inf)
    haAxes = RangeSelector;
    RangeSelector = varargin{1};
    varargin = varargin(2:end);
end



%% Create an input parser
% Input parse to easily parse input arguments
ip = inputParser;

%%% This fills in the parameters for the function

% We allow the user to explicitley flag which algorithm to use
valFcn_RangeSelector = @(x) any(validatestring(lower(x), {'min', 'max', 'min+max'}, mfilename, 'RangeSelector'));
addOptional(ip, 'RangeSelector', 'min+max', valFcn_RangeSelector);

% Configuratio nfor the input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    parse(ip, RangeSelector, varargin{:});
catch me
    throw(MException(me.identifier, me.message));
end



%% Parse local variables
% Check we have an axes handle
if ~ishandle(haAxes)
    haAxes = gca;
end

% Range selector can be 'min', 'max', 'min+max'
dRangeSelector = ip.Results.RangeSelector;

% Make sure the right number of outputs is requested depending on the desired
% range selector
switch dRangeSelector
    % For 'min', it can only be [min] = plotrange('min')
    case 'min'
        nargoutchk(0, 1);
    % For 'max', it can only be [max] = plotrange('max')
    case 'max'
        nargoutchk(0, 1);
    % For 'min+max', it can be [range] = plotrange('min+max') or [min, max] =
    % plotrange('min+max')
    case 'min+max'
        nargoutchk(0, 2);
end

% Get XData, YData and ZData of the current axis
ceXData = get(findobj(haAxes, 'Type', 'Line'), 'XData');
ceYData = get(findobj(haAxes, 'Type', 'Line'), 'YData');
ceZData = get(findobj(haAxes, 'Type', 'Line'), 'ZData');

% Convert axes with only single lines to cell matrices because otherwise our
% algorithms won't function well in the end
% For x-data
if ~iscell(ceXData)
    ceXData = mat2cell(ceXData, 1);
end
% For the y-data
if ~iscell(ceYData)
    ceYData = mat2cell(ceYData, 1);
end
% And for the z-data
if ~iscell(ceZData)
    ceZData = mat2cell(ceZData, 1);
end

% Remove all empty or NaN cells from the Y and Z data
ceXData = ceXData(cellfun(@(x) ~all(isempty(x) | isnan(x)), ceXData));
ceYData = ceYData(cellfun(@(y) ~all(isempty(y) | isnan(y)), ceYData));
ceZData = ceZData(cellfun(@(z) ~all(isempty(z) | isnan(z)), ceZData));



%% Off with the magic
% Determine min and max of plot data for each axis
dMinX = min(cellfun(@(x) min(x), ceXData));
dMaxX = max(cellfun(@(x) max(x), ceXData));
dMinY = min(cellfun(@(y) min(y), ceYData));
dMaxY = max(cellfun(@(y) max(y), ceYData));
dMinZ = min(cellfun(@(z) min(z), ceZData));
dMaxZ = max(cellfun(@(z) max(z), ceZData));

% Collect all thes e ranges in an array for easier access later on
vValueRange = [dMinX, dMaxX; ...
            dMinY, dMaxY; ...
            dMinZ, dMaxZ];

% Depending on the value of the range selector we will ...
switch dRangeSelector
    % ... get only the minimum (first column)
    case 'min'
        mxdRange = vValueRange(:,1).';
    % ... get both the minimum and maximum
    case 'min+max'
        mxdRange = vValueRange;
    % ... get only the maximum (last column)
    case 'max'
        mxdRange = vValueRange(:,2).';
end


%% Process return values
switch nargout
    % Two return values requested: [min, max]
    case 2
        varargout{1} = vValueRange(:,1).';
        varargout{2} = vValueRange(:,2).';
    % Otherwise we will return the range in the first return value
    otherwise
        varargout{1} = mxdRange;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
