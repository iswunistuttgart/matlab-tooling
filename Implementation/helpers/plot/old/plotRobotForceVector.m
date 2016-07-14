function plotRobotForceVector(Pose, CableAttachment, ForceVector, varargin)
% PLOTROBOTFORCEVECTOR Plot the force vectors on the platform at the given pose
% 
%   PLOTROBOTFORCEVECTOR(POSE, CABLEATTACHMENT, FORCEVECTOR) plots the columns
%   of FORCEVECTOR as forces impinging on the columns of CABLEATTACHMENT at the
%   pose POSE
% 
%   PLOTROBOTFORCEVECTOR(POSE, CABLEATTACHMENT, FORCEVECTOR, 'LineSpec',
%   LineSpec) forces the given specs on the force vectors. Must be quiver3
%   compatible properties
%   
%   PLOTROBOTFORCEVECTOR(POSE, CABLEATTACHMENT, FORCEVECTOR, 'Viewport',
%   Viewport, ...) adjusts the viewport of the 3d plot to the set values.
%   Allowed values are 2, 3, [az, el], or [x, y, z]. See documentation of view
%   for more info. Only works in standalone mode.
%
%   PLOTROBOTFORCEVECTOR(POSE, CABLEATTACHMENT, FORCEVECTOR, 'Grid', Grid, ...)
%   to define the grid style. Any of the following options are allowed
%   
%       'on'        turns major grid on
%       'off'       turns all grids off
%       'minor'     turns minor and major grid on
%   
%   Only works in standalone mode.
%
%   PLOTROBOTFORCEVECTOR(POSE, CABLEATTACHMENT, FORCEVECTOR, 'Title', Title, ...)
%   puts a title on the figure. Only works in standalone mode.
%
%   PLOTROBOTFORCEVECTOR(POSE, CABLEATTACHMENT, FORCEVECTOR, 'TitleSpec',
%   TitleSpec, ...) allows for setting custom properties on the title by
%   providing a cell array compliant with text properties.
%
%   PLOTROBOTFORCEVECTOR(POSE, CABLEATTACHMENT, FORCEVECTOR, 'XLabel', XLabel,
%   ...) sets the x-axis label to the specified char. Only works in standalone
%   mode.
%
%   PLOTROBOTFORCEVECTOR(POSE, CABLEATTACHMENT, FORCEVECTOR, 'YLabel', YLabel,
%   ...) sets the y-axis label to the specified char. Only works in standalone
%   mode.
%
%   PLOTROBOTFORCEVECTOR(POSE, CABLEATTACHMENT, FORCEVECTOR, 'ZLabel', ZLabel,
%   ...) sets the z-axis label to the specified char. Only works in standalone
%   mode.
%
%   PLOTROBOTFORCEVECTOR(AX, POSE, CABLEATTACHMENT, FORCEVECTOR, ...) plots the
%   force vectors into the specified axes
%
%   Inputs:
%   
%   POSE: Matrix of poses of the platform center of gravity where each row is
%   the [x, y, z] tuple of platform center of gravity positon at the time
%   corresponding to that value
%
%   CABLEATTACHMENT: Matrix of 3xM cable attachment points given in mobile
%   platform coordinates
%
%   FORCEVECTOR: Matrix of 3xm force direction vectors relative to each cable
%   attachment point. Basically, these are the f_i
%
%   See also: VIEW, QUIVER3, LINESPEC, GRID, TITLE, XLABEL, YLABEL, ZLABEL
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-03-30
% Changelog:
%   2016-03-30
%       * Initial release




end


function out = inCharToValidArgument(in)

switch lower(in)
    case {'on', 'yes', 'please'}
        out = 'on';
    case {'off', 'no', 'never'}
        out = 'off';
    otherwise
        out = 'off';
end
% end ```switch lower(in)```

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
