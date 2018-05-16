function varargout = uslayout(layout, varargin)
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
%                       'Titel und Inhalt'
%                       'Zwei Inhalte'
%                       'Zwei Inhalte Drittel Gross'
%                       'Zwei Inhalte Drittel Klein'
%                       'Drei Inhalte'
%                       'Vergleich Zweier'
%                       'Vergleich Zweier Drittel Gross'
%                       'Vergleich Zweier Drittel Klein'
%                       'Vergleich Dreier'
%                       'Text + Bilder quer'
%                       'Text + Bilder hoch'
%                       'Text + Runde Bilder'
%                       'Text + 4 Bilder rund'
%                       'Text + 4 Bilder eckig'
%                       '2 Text quer + 2 Bilder quer'
%                       'Text + Eckige Bilder'
%                       'Leer'



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-05-15
% Changelog:
%   2018-05-15
%       * Add all necessary layouts to this function
%       * Add support for passing additional adjustment to the style through to
%       `hgexport`
%   2018-05-14
%       * Initial release



%% Parse arguments

% List of valid layouts
ceValidLayouts = { ...
    'Titel und Inhalt' ...
    'Zwei Inhalte' ...
    'Zwei Inhalte Drittel Gross' ...
    'Zwei Inhalte Drittel Klein' ...
    'Drei Inhalte' ...
    'Vergleich Zweier' ...
    'Vergleich Zweier Drittel Gross' ...
    'Vergleich Zweier Drittel Klein' ...
    'Vergleich Dreier' ...
    'Text + Bilder quer' ...
    'Text + Bilder hoch' ...
    'Text + Runde Bilder' ...
    'Text + 4 Bilder rund' ...
    'Text + 4 Bilder eckig' ...
    '2 Text quer + 2 Bilder quer' ...
    'Text + Eckige Bilder' ...
    'Leer' ...
};

try
    % USLAYOUT(LAYOUT)
    % USLAYOUT(LAYOUT, 'Name', 'Value', ...)
    % USLAYOUT(HAX, LAYOUT, ...)
    narginchk(1, Inf);
    
    % USLAYOUT(...)
    nargoutchk(0, 1);
    
    % Define an argument input parser
    ip = inputParser;

    % Layout: matches cell defined above
    valFcn_Layout = @(x) any(validatestring(lower(x), [{'list'}, cellfun(@lower, ceValidLayouts, 'UniformOutput', false)], mfilename, 'Layout'));
    addRequired(ip, 'Layout', valFcn_Layout);

    % Configuration of input parser
    ip.KeepUnmatched = true;
    ip.FunctionName = mfilename;
    
    % Split arguments into axes and non-axes
    [haTarget, args, ~] = axescheck(layout, varargin{:});
    
    % Parse all arguments
    ip.parse(args{:});
    
%     % Name of slide layout
%     validatestring(lower(chLayout), cellfun(@lower, ceValidLayouts, 'UniformOutput', false), mfilename, 'layout');
catch me
    throwAsCaller(me);
end



%% Do your code magic here
% Get layout
chLayout = ip.Results.Layout;
% Unmatched arguments will be passsed down to `hgexport`
ceUnmatched = cell(1, 2*numel(fieldnames(ip.Unmatched)));
ceUnmatched(1:2:end) = fieldnames(ip.Unmatched);
ceUnmatched(2:2:end) = struct2cell(ip.Unmatched);


% Check if user requested to list all layouts
if strcmp(chLayout, 'list')
    varargout{1} = ceValidLayouts;
else
    % Get a valid axes handle
    haTarget = newplot(haTarget);
    % Old hold state
    lOldHold = ishold(haTarget);
    % Hold axes
    hold(haTarget, 'on');

    % Get the style info
    stStyle = hgexport('readstyle', sprintf('ISW US %s', chLayout));

    % Apply style to the figure
    hgexport(gpf(haTarget), 'temp_dummy', stStyle, 'ApplyStyle', true, ceUnmatched{:});

    % Release axes if we held them
    if ~lOldHold
        hold(haTarget, 'off');
    end

    % Update figure
    drawnow
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
