function f = first(mixed)
% FIRST gets the first element of the given argument
%
%   Inputs:
%
%   MIXED               Can be a MATLAB variable of any content. This function
%                       tries its best to handle getting the "last" item
%                       correctly. Depending on the class of the argument, the
%                       last item is differently defined:
%                         double: last(mixed) => mixed(end)
%                         cell:   last(cell) => cell{end}
%
%   Outputs:
%
%   F                   The first item in the given arguument



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2019-03-18
% Changelog:
%   2019-03-18
%     * Initial release



%% Do your code magic here
switch class(mixed)
  case 'double'
    f = mixed(1);
  case 'cell'
    f = mixed{1};
  otherwise
    f = builtin('first', mixed);
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
