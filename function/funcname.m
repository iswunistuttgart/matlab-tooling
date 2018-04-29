function fcname = funcname()
% FUNCNAME returns the current function's name



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-12-01
% Changelog:
%   2017-12-01
%       * Initial release



%% Do your code magic here
stStack = dbstack(1);

% If stack is not empty and has field 'name' ...
if ~isempty(stStack) && isfield(stStack, 'name')
    % That's our function mame
    chName = stStack(1).name;
% No stack, so called from within base
else
    chName = 'base';
end



%% Assign output quantities
fcname = chName;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
