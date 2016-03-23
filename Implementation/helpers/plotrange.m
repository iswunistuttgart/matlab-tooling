function Range = plotrange(RangeSelector, varargin)

%% Preprocess inputs (allows to have the axis defined as first argument)
% By default we don't have any axes handle
haAxes = false;
% Check if the first argument is an axes handle, then we just have to shift all
% other arguments by one
if ~isempty(varargin) && allAxes(RangeSelector)
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
parse(ip, RangeSelector, varargin{:});



%% Parse local variables
% Range selector can be -1, 0, or 1
dRangeSelector = ip.Results.RangeSelector;

% Get YData and ZData of the current axis
ceYData = get(findobj(haAxes, 'Type', 'Line'), 'YData');
ceZData = get(findobj(haAxes, 'Type', 'Line'), 'ZData');

% Convert axes with multiple lines inside to matrices removing all empty plots
% or those with NaN inside
% For the y-data
if iscell(ceYData)
    ceYData = cell2mat(ceYData(cellfun(@(x) all(~isempty(x) & ~isnan(x)), ceYData)));
end

% And for the z-data
if iscell(ceZData)
    ceZData = cell2mat(ceZData(cellfun(@(x) all(~isempty(x) & ~isnan(x)), ceZData)));
%     ceZData = cell2mat(cellfun(@(x) ~isempty(x), ceZData));
end

% Check if we are dealing with a 3D-plot
bIsThreeDimPlot = ~isempty(ceZData);

% Return value
mxdRange = [];



%% Off with the magic
% If 3-D plot
if bIsThreeDimPlot
    vValueRange = [min(min(ceYData)), max(max(ceYData)); ...
        min(min(ceZData)), max(max(ceZData))];
% just a simple 2-D plot
else
    vValueRange = [min(min(ceYData)), max(max(ceYData))];
end


%% Off with the magic
% Depending on the value of the range selector we will
switch dRangeSelector
    % Get only the minimum
    case 'min'
        mxdRange = vValueRange(:,1).';
    % Get both the minimum and maximum
    case 'min+max'
        mxdRange = vValueRange;
    % Get only the maximum
    case 'max'
        mxdRange = vValueRange(:,2).';
end


%% Process return values
Range = mxdRange;


end

function result = allAxes(h)

result = all(all(ishghandle(h))) && ...
         length(findobj(h,'type','axes','-depth',0)) == length(h);

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
