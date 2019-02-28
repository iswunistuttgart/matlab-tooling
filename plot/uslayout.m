function varargout = uslayout(layout, varargin)
% USLAYOUT applies the corresponding figure to University of Stuttgarts
%
%   USLAYOUT(LAYOUT) applies the given layout LAYOUT to the currently active
%   figure such that it can be exported nicely.
%
%   USLAYOUT('LIST') displays a list of all available layout styles.
%
%   L = USLAYOUT('LIST') returns the list of available layout styles into row
%   cell array L.
%
%   USLAYOUT(HF, LAYOUT) applies the layout to the given figure.
%
%   Usage:
%     figure();
%     t = 0:0.1:10;
%     plot(t, sin(t));
%     uslayout('Zwei Inhalte');
%
%   Inputs:
%
%   LAYOUT        Name of the layout to apply. Possible values are
%             'Titel und Inhalt'
%             'Zwei Inhalte'
%             'Zwei Inhalte Drittel Gross'
%             'Zwei Inhalte Drittel Klein'
%             'Drei Inhalte'
%             'Vergleich Zweier'
%             'Vergleich Zweier Drittel Gross'
%             'Vergleich Zweier Drittel Klein'
%             'Vergleich Dreier'
%             'Text + Bilder quer'
%             'Text + Bilder hoch'
%             'Text + Runde Bilder'
%             'Text + 4 Bilder rund'
%             'Text + 4 Bilder eckig'
%             '2 Text quer + 2 Bilder quer'
%             'Text + Eckige Bilder'
%             'Leer'
%
%   See also:
%   USLINESTYLES



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2019-02-28
% Changelog:
%   2019-02-28
%     * Update to handle figure objects, too, instead of axes objects passed as
%     initial argument. When passing an axes object, its parent Figure will be
%     retrieved
%     * Also remove necessity to `HOLD('on')` axes before calling this function.
%     In retrospect, this didn't make any sense
%     * Change handling of `'LIST'` argument: If no output arguments are given,
%     then the list is printed, elsewise the list is returned as a cell array
%   2018-05-25
%     * Reference USLINESTYLES in help block
%   2018-05-24
%     * Remove explicit creation of an axes handle in the usage example
%   2018-05-15
%     * Add all necessary layouts to this function
%     * Add support for passing additional adjustment to the style through to
%     `hgexport`
%   2018-05-14
%     * Initial release



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
  valFcn_Layout = @(x) assert(any(strcmpi(x, [{'list'}, ceValidLayouts])), 'Expected Layout to match one of these values:\n\n%s\n\nThe input, %s, matched more than one valid value.', strjoin([{'''list'''}, cellfun(@(c) sprintf('''%s''', c), ceValidLayouts, 'UniformOutput', false)], ', '), x);
%   valFcn_Layout = @(x) any(validatestring(lower(x), [{'list'}, cellfun(@lower, ceValidLayouts, 'UniformOutput', false)], mfilename, 'Layout'));
  addRequired(ip, 'Layout', valFcn_Layout);

  % Configuration of input parser
  ip.KeepUnmatched = true;
  ip.FunctionName = mfilename;
  
  % Split arguments into axes and non-axes
  [haTarget, args, ~] = figcheck(layout, varargin{:});
  % Split arguments into Figures and non-Figures
  [hfTarget, args, ~] = figcheck(args{:});
  
  % Get figure handle if its empty, but an axes handle was passed
  if isempty(hfTarget) && ~isempty(haTarget)
    hfTarget = gpf(haTarget);
  % No axes and no figure, passed, so we will get the current figure
  else
    hfTarget = gcf();
  end
  
  % Parse all arguments
  parse(ip, args{:});
  
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
  % No return argument, nicely print the layouts
  if nargout == 0
    % Nicely print all layouts
    fprintf('Available styles are:\n');
    for ivl = 1:numel(ceValidLayouts)
      fprintf('  * %s\n', ceValidLayouts{ivl});
    end
  % Return list of all possible layouts
  else
    varargout{1} = ceValidLayouts;
  end
else
  % Get the style info
  stStyle = hgexport('readstyle', sprintf('ISW US %s', chLayout));

  % Apply style to the figure
  hgexport(hfTarget, 'temp_dummy', stStyle, 'ApplyStyle', true, ceUnmatched{:});

  % Update figure
  drawnow
  
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
