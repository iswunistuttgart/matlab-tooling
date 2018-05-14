function uslayout(layout, varargin)
% USLAYOUT applies the corresponding figure to University of Stuttgarts
%
%   USLAYOUT(LAYOUT) applies the given layout to the figure such that it can be
%   exported nicely
%
%   USLAYOUT(HAX, LAYOUT) applies the layout to the given axes.
%
%   Usage:
%       figure();
%       t = 0:0.1:10;
%       plot(t, sin(t));
%       hold('on');
%       uslayout(hax, 'Zwei Inhalte');
%       hold('off');
%
%   Inputs:
%
%   LAYOUT              Name of the layout to apply. Possible values are
%                       'Text'
%                       'Zwei Inhalte'
%                       'Drei Inhalte'
%                       'Vergleich Zweier'
%                       'Vergleich Dreier'
%                       '4x4 Viereck'
%                       '4x4 Kreis'
%                       'Horizontal'
%                       'Vertikal'



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-05-14
% Changelog:
%   2018-05-14
%       * Initial release



%% Parse arguments

try
    % USLAYOUT(LAYOUT)
    % USLAYOUT(HAX, LAYOUT)
    narginchk(1, 2);
    
    % USLAYOUT(...)
    nargoutchk(0, 0);
    
    % Split arguments into axes and non-axes
    [haTarget, args, ~] = axescheck(layout, varargin{:});
    % Get layout
    chLayout = args{1};
    
    % Name of slide layout
    chLayout = matlab.lang.makeValidName(validatestring(lower(chLayout), {'text', 'zwei inhalte', 'drei inhalte'}, mfilename, 'layout'));
catch me
    throwAsCaller(me);
end



%% Do your code magic here
% Get a valid axes handle
haTarget = newplot(haTarget);
% Old hold state
lOldHold = ishold(haTarget);
% Hold axes
hold(haTarget, 'on');

% Get the style info
stStyle = hgexport('readstyle', chLayout);

% Apply style to the figure
hgexport(gpf(haTarget), 'temp_dummy', stStyle, 'ApplyStyle', true);

% Release axes if we held them
if ~lOldHold
    hold(haTarget, 'off');
end

% Update figure
drawnow


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
