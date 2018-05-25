function varargout = uslinestyles(varargin)
% USLINESTYLES creates a list of N unique lineseries plot styles
%
%   S = USLINESTYLES() creates a cell array of N elements of styles for the
%   current axes where N is the number of plots of type 'line'. A unique
%   lineplot style is defined by the lineseries properties 'Color', 'LineStyle',
%   and 'Marker'. Note that you want to be careful setting the marker on a
%   regular plot object as this will place a marker at every sample of the
%   independent variable e.g., 'X'.
%
%   S = USLINESTYLES(N) creates a cell array of N unique elements of styles.
%
%   S = USLINESTYLES(AX, ...) creates the cell array of unique style elements
%   for the given axes.
%
%   Usage
%   % Set line styles on an active axes object
%   t = 0:0.1:10;
%   plot(t, sin(t), t, cos(t), t, sin(t).^2)
%   uslinestyles();
%
%   % Get line styles prior to plotting and assign manually
%   t = 0:0.1:10;
%   stls = uslinestyles(3);
%   plot(t, sin(t), stls{1}{:})
%   hold('on')
%   plot(t, cos(t), stls{2}{:})
%   plot(t, sin(t).^2, stls{3}{:})
%   hold('off')
%
%   Inputs:
%
%   N                   Number of lines to create unique styles for. Defaults to
%                       the number of plots of type 'line' in the current axes.
%
%   Outputs:
%
%   S                   Nx1 cell array of styles per line plot.
%
%   See also:
%   USLAYOUT



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-05-25
% Changelog:
%   2018-05-25
%       * Initial release



%% Validate arguments
try
    % USLINESTYLES()
    % USLINESTYLES(N)
    % USLINESTYLES(AX, N)
    narginchk(0, 2);
    
    % USLINESTYLES(...)
    % S = USLINESTYLES(...)
    nargoutchk(0, 1);
    
    % Get an axes object
    [ax, args, nargs] = axescheck(varargin{:});
    
    % Validate if some arguments other than an axes object 
    if nargs
        % Number of styles
        n = args{1};
        
        % Validate number of styles
        validateattributes(n, {'numeric'}, {'scalar', 'positive', 'finite', 'nonnan', 'nonsparse'}, mfilename, 'N');
    else
        % Default to NaN so that we auto infer the line styles
        n = NaN;
    end
catch me
    throwAsCaller(me);
end



%% Parse arguments
% Target axes
haTarget = ax;
% Number of unique styles
nStyles = n;

% If no axes was given, see if there is an active axes object
if isempty(haTarget) && isnan(nStyles)
    haTarget = get(gcf,'CurrentAxes');
end

% Check if there is an axes object given
if ~isempty(haTarget)
    % Get the children of type 'line' from the current axes object
    vLines = findobj(allchild(haTarget), 'Type', 'line');
    % Count the number of line objects to determine the number of unique styles
    nStyles = numel(vLines);
else
    % No line objects here
    vLines = [];
end

% Default value in case we haven't found any axes of line object yet
if isnan(nStyles)
    nStyles = 5;
end



%% Create unique styles

% Default color order
ceColors = { ...
   [  0, 190, 255]./255 , ...
   [  0,  81, 158]./255 , ...
   [159, 153, 154]./255 , ...
   [ 62,  68,  76]./255 , ...
   [255, 213,   0]./255 , ...
   [231,  81,  18]./255 , ...
};
ceColors = ceColors([1, 4, 5, 2, 3, 6]);
% Get the configure default line style order
ceLinestyles = get(groot, 'DefaultAxesLineStyleOrder');
% No user-defined line style order, so we'll create our own
if ~isempty(ceLinestyles)
    ceLinestyles = cellstr(ceLinestyles).';
else
    ceLinestyles = {'-', '--', ':', '-.'};
end
% Define our own marker style
ceMarkers = {'none', 'o', '+', '*', '.', 'x'};

% Make the combination
ceCombs = allcomb(ceMarkers, ceLinestyles, ceColors);
% Build a proper argument array of the combined cell array
ceStyles = arrayfun(@(ii) {'Color', ceCombs{ii,3}, 'LineStyle', ceCombs{ii,2}, 'Marker', ceCombs{ii,1}}, 1:size(ceCombs, 1), 'UniformOutput', false).';
% And get only as many styles as needed
ceStyles = ceStyles(1:nStyles);
% Append other default values
ceStyles = cellfun(@(c) [c, {'LineWidth', 1.5}], ceStyles, 'UniformOutput', false);



%% Assign output quantities or apply styles
% Assign output quantities?
if nargout
    % First argument are the styles
    if nargout > 0
        varargout{1} = ceStyles;
    end
% Apply styles to plot
elseif ~isempty(vLines)
    % Get current axes HOLD value
    loOldHold = ishold(haTarget);
    
    % Add to plot
    hold(haTarget, 'on');
    
    % Loop over each line
    for iLine = 1:numel(vLines)
        % Set the styles for the current axes
        set(vLines(iLine), ceStyles{iLine}(1:2:end), ceStyles{iLine}(2:2:end));
    end
    
    % Release axes if we were holding them
    if ~loOldHold
        hold(haTarget, 'off');
    end
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
