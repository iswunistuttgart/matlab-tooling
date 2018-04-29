function plot_cyclelinestyles(varargin)
% PLOT_CYCLELINESTYLES adds different line styles to each plot in an axis
%
%   Inputs:
%
%   STYLES              Char array of styles to apply to each line plot.
%                       Defaults to '-|--|-.|:'



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-01-13
% Changelog:
%   2018-01-13
%       * Initial release



%% Define the input parser
ip = inputParser;

% Let user decide on the plot style
% Plot style can be chosen anything from the list below
valFcn_Styles = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Styles');
addOptional(ip, 'Styles', '-|--|-.|:', valFcn_Styles);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    narginchk(0, Inf);
    
    nargoutchk(0, 2);
    
    [haTarget, args, ~] = axescheck(varargin{:});
    
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Process arguments
% Get a valid new plot handle
haTarget = newplot(haTarget);
% Get old hold state
lOldHold = ishold(haTarget);
% Set axes to hold
hold(haTarget, 'on');
% Get the styles the user wants
chStyles = ip.Results.Styles;
% Assert the given line style order
assert(length(chStyles) == 1 | any(strfind(chStyles, '|')), 'PHILIPPTEMPEL:MATLAB_TOOLING:PLOT_CYCLELINESTYLES:InvalidStyleSeparator', 'Invalid format for line style order given. Multiple stylesmust be separated by a |');
assert(all(ismember(strsplit(chStyles, '|'), {'-', '--', '-.', ':', 'none'})), 'PHILIPPTEMPEL:MATLAB_TOOLING:PLOT_CYCLELINESTYLES:InvalidOrderType', 'Invalid line style type given.');
% Get style order as cell array
ceStyles = strsplit(chStyles, '|');

% Currently, we only allow adjusting line styles on the following plot types
ceSupportedPlotTypesSelector = {'Type', 'line'};


% Get all children of the axes
ceChildren = get(haTarget, 'Children');
% Grab only the valid children from the current axes' children
ceValidChildren = findobj(ceChildren, ceSupportedPlotTypesSelector{:});
nValidChildren = numel(ceValidChildren);

% Repeat the line styles until we have enough for every child
if numel(ceStyles) < nValidChildren
    ceStyles = repmat(ceStyles, 1, ceil(nValidChildren/numel(ceStyles)));
end



%% Here is where all the adjustment happens
% For every child...
for iChild = nValidChildren:-1:1
    % Set the line style
    set(ceChildren(iChild), 'LineStyle', ceStyles{iChild});
end


% Restore old hold value
if ~lOldHold
    hold(haTarget, 'off');
end

% Update the figure
drawnow


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
