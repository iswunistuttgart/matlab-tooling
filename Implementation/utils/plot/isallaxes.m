function result = isallaxes(h)
% ISALLAXES Checks whether the given handle is purely axes
% 
%   ISALLAXES(h) will check everything inside h to be a valid handle or not
%   
%   Inputs:
%   
%   H: Array of something, most likely should be handles
%
%   Outputs:
%
%   RES: Is true if h contains only handles, false otherwise
%
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-03-25
% Changelog:
%   2016-03-25: Initial release



%% ------------- BEGIN OF CODE --------------

result = all(all(ishghandle(h))) && ...
         length(findobj(h,'type','axes','-depth',0)) == length(h);

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header