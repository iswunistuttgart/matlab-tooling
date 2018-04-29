function h = progressbar(X, varargin)
% PROGRESSBAR creates a nicer progress bar window for progress information
%
%   PROGRESSBAR is just a wrapper for WAITBAR which reverses the order of
%   the handle argument to a more convenient position: similar to all plot
%   functions, the waitbar handle must be at the first position for
%   updating the waitbar using subsequent function calls.
%
%   PROGRESSBAR(X) initializes a progress bar handle at X% progress.
%
%   PROGRESSBAR(X, MESSAGE) sets the given message on the waitbar
%
%   H = PROGRESSBAR(X) returns the progress bar handle.
%
%   PROGRESSBAR(H, X, MESSAGE, ...) updates the progress bar handle H to value X.
%
%   PROGRESSBAR(..., 'Name', 'Value', ...) allows setting optional
%   inputs using name/value pairs.
%
%   Inputs:
%
%   X                   The value to set the progress bar to. Must be
%                       between 0 and 1.
%
%   Optional Inputs -- specified as parameter value pairs
%
%   Title               Title of the progress bar. May be a function handle
%       or a character array.
%
%   Outputs:
%
%   H                   Progress bar handle
%
%   See also:
%       WAITBAR



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-01-25
% Changelog:
%   2018-01-25
%       * Initial release



%% Define the input parser
ip = inputParser;

% Required: Progress; cell; non-empty
valFcn_Progress = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'finite', 'nonnegative', '<=', 1, 'nonsparse', 'nonnan'}, mfilename, 'X');
addRequired(ip, 'X', valFcn_Progress);

% Optional: message; char; non-empty
valFcn_Message = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Message');
addParameter(ip, 'Message', '', valFcn_Message);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    % PROGRESSBAR(X)
    % PROGRESSBAR(H, X)
    % PROGRESSBAR(..., 'Name', 'Value', ...)
    narginchk(1, Inf);
    % PROGRESSBAR(...)
    % H = PROGRESSBAR(...)
    nargoutchk(0, 1);    
    
    args = [{X}, varargin];
    
    [hwProgress, args, ~] = handlecheck(args{:});
    
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results
% Progress value
dProgress = ip.Results.X;
% Message
chMessage = ip.Results.Message;
% Get unmatched parameters to be passed to waitbar
stUnmatched = ip.Unmatched;
ceWaitbarArgs = cell(2*numel(fieldnames(stUnmatched)), 1);
ceWaitbarArgs(1:2:end) = fieldnames(stUnmatched);
ceWaitbarArgs(2:2:end) = struct2cell(stUnmatched);



%% Do your code magic here
% Got a progressbar handle from a previous function call?
if ~isempty(hwProgress)
    % Update the waitbar
    if ~isempty(chMessage)
        waitbar(dProgress, hwProgress, chMessage);
    else
        waitbar(dProgress, hwProgress);
    end
    % And update the additional arguments
    for iUnmatch = 1:2:numel(ceWaitbarArgs)
        % Set these properties on the target waitbar
        hwProgress.(ceWaitbarArgs{iUnmatch}) = ceWaitbarArgs{iUnmatch + 1};
    end
else
    % Default message fallback
    if isempty(chMessage)
        chMessage = 'Initializing...';
    end
    % Create a waitbar object
    hwProgress = waitbar(0, chMessage, ceWaitbarArgs{:});
end



%% Assign output quantities
h = hwProgress;


end


function [ax, args, nargs] = handlecheck(varargin)
%% HANDLECHECK checks the list of arguments for a valid progressbar handle

args = varargin;
nargs = nargin;
ax = [];

% Check for either a scalar Axes handle, or any size array of Axes.
% 'isgraphics' will catch numeric graphics handles, but will not catch
% deleted graphics handles, so we need to check for both separately.
if nargs > 0 && ...
        ( isscalar(args{1}) && isgraphics(args{1}, 'figure') ...
            || isa(args{1}, 'matlab.ui.Figure') )
  ax = handle(args{1});
  args = args(2:end);
  nargs = nargs - 1;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
