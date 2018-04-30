function l = last(mixed)
% LAST gets the last element of the given argument
%
%   Inputs:
%
%   MIXED               Can be a MATLAB variable of any content. This function
%                       tries its best to handle getting the "last" item
%                       correctly. Depending on the class of the argument, the
%                       last item is differently defined:
%                       couble: last(mixed) => mixed(end)
%                       cell:   last(cell) => cell{end}
%
%   Outputs:
%
%   L                   The last item in the given arguument



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-09-19
% Changelog:
%   2017-09-19
%       * Initial release



%% Do your code magic here
switch class(mixed)
    case 'double'
        l = mixed(end);
    case 'cell'
        l = mixed{end};
    otherwise
        throwAsCaller(MException('PHILIPPTEMPEL:MATLABTOOLING:DATA:LAST:UnsupportedType', 'Unsupported type %s given to function', class(mixed)));
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
