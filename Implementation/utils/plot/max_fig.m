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
% Date: 2016-09-22
% Changelog:
%   2016-09-22
%       * Rename to `max_fig`
%   2016-06-15
%       * Add help doc
%       * Add `File Information` section
%   YYYY-MM-DD
%       * Initial release (date unknown)



%% Argument defaults
if nargin < 1
    Fig = gcf;
end



%% Assert arguments
assert(all(ishandle(Fig)), 'Argument [Fig] provided must be a valid handle');
assert(isfig(Fig, true), 'Argument [Fig] must be a valid figure handle (or array of valid figure handles)');



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
    figure(hfTarget(iFigure))

    % Make figure visible;
    hfTarget(iFigure).Visible = 'on';

    % Make sure it's drawn otherwise we will get java.lang.NullPointerException
    drawnow

    % Get the figure's java fram
    jFrame = get(handle(hfTarget(iFigure)), 'JavaFrame');
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
