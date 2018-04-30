function max_fig(Fig, varargin)
% MAX_FIG maximizes the current or given figure
%
%   MAX_FIG() maximizes the current figure identified by `gcf` while also making
%   it visible and placing it in the foreground.
%
%   MAX_FIG(FIG) maximizes the figure identified by handle FIG while also making
%   it visible and putting it in the foreground.
%
%   Inputs:
%
%   FIG         Handle to one or more figures to maximize.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-01-02
% Changelog:
%   2017-01-02
%       * Fix incorrect use of `isfig`
%       * Make MAX_FIG allow gobjects to be passed or an array of doubles
%       representing the handle ID's
%   2016-09-22
%       * Rename to `max_fig`
%   2016-06-15
%       * Add help doc
%       * Add `File Information` section
%   YYYY-MM-DD
%       * Initial release (date unknown)



%% Argument defaults
if nargin < 1 || isempty(Fig)
    Fig = gcf;
end



%% Assert arguments
assert(all(ishandle(Fig)), 'Argument [Fig] provided must be a valid handle');
assert(all(isfig(Fig)), 'Argument [Fig] must be a valid figure handle (or array of valid figure handles)');



%% Process arguments
hfTarget = Fig;



%% MATLAB, do your magic
% First, get the current state of warnings
stWarnings = warning('query');

% Set the warning for `JavaFrame` to off
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

% Loop over all given figures
for iFigure = 1:numel(hfTarget)
    % Select that figure
    hf = handle(figure(hfTarget(iFigure)));

    % Make figure visible;
    hf.Visible = 'on';

    % Make sure it's drawn otherwise we will get java.lang.NullPointerException
    drawnow

    % Get the figure's java fram
    jFrame = get(hf, 'JavaFrame');
    % Maximize it
    jFrame.setMaximized(true);

    % Draw it again to make it be drawn at maximized view
    drawnow
end

% Restore warning states as was before the call to this function
warning(stWarnings);



%% Done


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
