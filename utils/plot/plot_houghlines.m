function varargout = plot_houghlines(lns, varargin)
% PLOT_HOUGHLINES plot lines from houghlines
%
%   PLOT_HOUGHLINES(LINES) plots the lines given in the structure array.
%
%   PLOT_HOUGHLINES(LINES, 'Name', 'Value', ...) takes the given optional
%   arguments and applies them to the line series plot.
%
%   PLOT_HOUGHLINES(AX, ...) plots the hough identified lines into the given
%   axes handle.
%
%   H = PLOT_HOUGHLINES(LINES) returns the graphics array of the plotted line
%   series objects.
%
%   Inputs:
%
%   LNS                 Structure of array with lines from houghlines. Must
%                       contain the following fields
%                       .point1     1x2 array of XY-coordinates of first point
%                       .point2     1x2 array of XY-coordinates of second point
%                       .theta      Angle of the line with respect to the
%                                   horizontal X-axis
%                       .rho        Distance of the line from the image's top
%                                   left corner
%
%   Outputs:
%
%   H                   Handle array of all the plotted lines
%
%   See also:
%       PLOT



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-01-21
% Changelog:
%   2018-01-21
%       * Initial release



%% Define the input parser
ip = inputParser;

% Lines: structure; non-empty
valFcn_Lines = @(x) validateattributes(x, {'struct'}, {'nonempty'}, mfilename, 'Lines');
addRequired(ip, 'Lines', valFcn_Lines);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    % PLOT_HOUGHLINES(LINES)
    % PLOT_HOUGHLINES(LINES, Name, Value, ...)
    narginchk(1, Inf);
    % PLOT_HOUGHLINES(...)
    % H = PLOT_HOUGHLINES(...)
    nargoutchk(0, 1);
    
    args = [{lns}, varargin];
    
    [haTarget, args, ~] = axescheck(args{:});
    
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results
% Get a valid axes handle
haTarget = newplot(haTarget);
% Old hold state
lOldHold = ishold(haTarget);
% Tell figure to add next plots
hold(haTarget, 'on');
% Get lines
stLines = ip.Results.Lines;
% Count lines
nLines = numel(stLines);
% Line properties are unmatched parameters, so make them a cell array
stUnmatched = ip.Unmatched;
cePlotStyles = cell(2*numel(fieldnames(stUnmatched)), 1);
cePlotStyles(1:2:end) = fieldnames(stUnmatched);
cePlotStyles(2:2:end) = struct2cell(stUnmatched);



%% Plot the lines
% Hold graphics objects in here
hpLines = gobjects(nLines, 1);

% Loop over each line
for iLine = 1:nLines
    % Get the XY-coordinates of the line's start and end point
    aXY_Line = [stLines(iLine).point1; stLines(iLine).point2];
    % Plot the line
    hpLines(iLine) = plot(haTarget ...
        , aXY_Line(:,1), aXY_Line(:,2) ...
        , cePlotStyles{:} ...
    );
end

% Finally, make sure the figure is drawn
drawnow

% Reset the old hold state if it wasn't set
if ~lOldHold
    hold(haTarget, 'off');
end



%% Assign output quantities
if nargout > 0
    varargout{1} = hpLines;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
