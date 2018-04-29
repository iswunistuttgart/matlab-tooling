function emi = em(action)
% EM wrapper for exps.manager.instance()
%
%   EM() returns the current exps.manager instance or creates a new one if it
%   hasn't existed until called.
%
%   EM('reset') removes the old exps.manager instance and creates a new one
%   ultimately reading the project files anew.
%
%   Outputs:
%
%   M                   EXPS.MANAGER object
%
%   See also:
%       EXPS.MANAGER



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-04-29
% Changelog:
%   2018-04-29
%       * Initial release



%% Validate arguments

try
    % EM()
    % EM(ACTION)
    narginchk(0, 1);
    
    % EM(...)
    % EMI = EM(...)
    nargoutchk(0, 1);
    
    if nargin < 1 || 1 ~= exist('action', 'var') || isempty(action)
        action = 'instance';
    end
    
    validatestring(lower(action), {'', 'reset', 'instance'}, mfilename, 'action');
    
catch me
    throwAsCaller(me);
end



%% Do your code magic here

% Persistent object
persistent em_

% No object yet or create new?
if isempty(em_) || strcmpi(action, 'reset')
    em_ = exps.manager();
end



%% Assign output quantities

% EMI = EM(...);
emi = em_;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
