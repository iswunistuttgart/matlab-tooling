function ce = unmatchedcell(st)
% UNMATCHEDCELL turns the given structure of unmatched IP parameters to a cell
%
%   Inputs:
%
%   ST                  Structure from ip.Unmatched where ip is an InputParser
%                       instance with N Name-Value pairs.
%
%   Outputs:
%
%   CE                  1x2N cell array of unmatched IP parameters



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-02-20
% Changelog:
%   2018-02-20
%       * Initial release



%% Validate arguments
try
    % CE = UNMATCHEDCELL(ST);
    narginchk(1, 1);
    % UNMATCHEDCELL(ST);
    % CE = UNMATCHEDCELL(ST);
    nargoutchk(0, 1);
    
    validateattributes(st, {'struct'}, {}, mfilename, 'st');
catch me
    throwAsCaller(me);
end



%% Do your code magic here
% Get the field names of the structure
ceFields = fieldnames(st);
% Create the cell array
ceUnmatched = cell(2*numel(ceFIelds), 1);
% Add the fields on every second element starting at one
ceUnmatched(1:2:end) = ceFields;
% Add the fields' values starting at two
ceUnmatched(2:2:end) = struct2cell(st);



%% Assign output quantities
% CE = UNMATCHEDCELL(ST)
ce = ceUnmatched;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
