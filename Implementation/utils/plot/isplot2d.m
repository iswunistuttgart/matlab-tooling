function res = isplot2d(varargin)
% ISPLOT2D Check the given axes against being a 2D plot i.e., created by plot()
% 
%   ISPLOT2D() checks the current axes against being a 2D plot
% 
%   ISPLOT2D(AXES) checks the given axes against being a 2D plot
%
%   Basically, what this function does is exam all current axes childrens
%   whether they have valid ZData. If any of them has it will return false
%   
%   Inputs:
%   
%   AXES: Use axes AXES instead of current axes to check
%
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-03-25
% Changelog:
%   2016-03-25: Initial release

res = ~isplot3d(varargin{:});


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
