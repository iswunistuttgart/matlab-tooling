function res = isplot3d(Axis)
% ISPLOT3D Check the given axes against being a 3D plot i.e., created by plot3()
% 
%   ISPLOT3D() checks the current axes against being a 3D plot
% 
%   ISPLOT3D(AXES) checks the given axes against being a 3D plot
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



%% Pre-process inputs
if nargin == 0
    Axis = gca;
end



%% Process inputs
% Get axis to handle
haAxes = Axis;



%% Magic
% Get the XData, YData, and ZData from the plot
ceZData = get(get(haAxes, 'Children'), 'ZData');

% For z-data
if ~iscell(ceZData) && ~isempty(ceZData)
    ceZData = mat2cell(ceZData, 1);
end

% Remove all empty or NaN cells from the Y and Z data
% ceXData = ceXData(cellfun(@(x) ~all(isempty(x)), ceXData));
% ceYData = ceYData(cellfun(@(y) ~all(isempty(y)), ceYData));
ceZData = ceZData(cellfun(@(z) ~all(isempty(z)), ceZData));

% It is assumed a 3D plot if the ZData contains values
res = isempty(ceZData);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
