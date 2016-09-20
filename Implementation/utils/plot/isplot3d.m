function res = isplot3d(varargin)
% ISPLOT3D Check the given axes against being a 3D plot i.e., created by plot3()
% 
%   ISPLOT3D() checks the current axes against being a 3D plot.
% 
%   ISPLOT3D(AXES) checks the given axes against being a 3D plot.
%
%   Basically, what this function does is exam the given axes to be not 2d
%   plots.
%   
%   Inputs:
%   
%   AXES:       Mx1 array of axes to check for being 3D.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-20
% Changelog:
%   2016-09-20
%       * Add support for checking multiple axes at once
%   2016-09-13
%       * Update to new file information header
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%   2016-04-01
%       * Update checking for proper plot types. This should be a more fail-safe
%       code now
%   2016-03-25
%       * Initial release



%% Magic
% Just pass handling along to isplot2d because it will be a 3D plot if it is not
% a 2D plot, right?
res = ~isplot2d(varargin{:});


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
