function varargout = circle(varargin)
% CIRCLE draws a circle of specified radius
%
%   CIRCLE() draws a unit circle at [0,0] i.e., with radius rho = 1.
%
%   CIRCLE(RHO) draws a unit circle at [0,0] with radius RHO.
%
%   CIRCLE(RHO, CENTER) draws a circle located at 1x2 vector CENTER with radius
%   of RHO.
%
%   CIRCLE(RHO, CENTER, ...) passes additional arguments that are not processed
%   by this function to the underlying patch command for drawing the circle
%   object. This allows user-defined plot data to be easily appended like e.g.,
%       CIRLCE(1, [0,0], 'FaceColor', 'red', 'EdgeColor', 'green');
%
%   CIRCLE(AX, ...) plots into the given axes.
%
%   H = CIRCLE(...) returns the handle of the line series graphics object.
%
%   CIRCLE('Name', 'Value', ...) allows setting optional inputs using name/value
%   pairs.
%
%   Optional Inputs -- specified as parameter value pairs
%
%   See also: PATCH



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-01-05
% Changelog:
%   2017-01-05
%       * Initial release



%% Adjust Arguments to Allow for Multiple Circles
% if nargin > 1
%     % Number of radii and of centers
%     nRhos = numel(varargin{1});
%     nCenters = size(varargin{2}, 1);
%     
%     % Too few radii?
%     if nRhos < nCenters
%         varargin(1) = repmat(varargin{1}, nCenters, 1);
%     end
%     % Too few centers?
%     if nCenters < nRhos
%         varargin(2) = repmat(varargin{2}, nRhos, 1);
%     end
% end
% 
% nRhos = numel(varargin{1});



%% Define the input parser
ip = inputParser;

% Optional 1: Radius; numeric; scalar, non-empty, positive, finite;
valFcn_Radius = @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive', 'finite', 'nonempty', 'nonsparse'}, mfilename, 'rho');
addOptional(ip, 'Radius', 1, valFcn_Radius);

% Optional 2: Center; numeric; vector, numel 2, finite;
valFcn_Center = @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 2, 'finite', 'nonempty', 'nonsparse'}, mfilename, 'center');
addOptional(ip, 'Center', [0, 0], valFcn_Center);

% Parameter: LineSpec; cell; non-empty;
% valFcn_LineSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'LineSpec');
% addParameter(ip, 'LineSpec', {}, valFcn_LineSpec);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    [haTarget, args, ~] = axescheck(varargin{:});
    
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results
% Radius
dRadius = ip.Results.Radius;
% Center location
vCenter = ip.Results.Center;
% Additional plot styles for the circle are the ones we didn't match with the IP
stLinespec = ip.Unmatched;
ceLinespec = {};
% if isfield(stLinespec, 'color')
%     stLinespec.FaceColor = stLinespec.Color;
%     stLinespec.EdgeColor = stLinespec.Color;
%     stLinespec = rmfield(stLinespec, 'color');
% end
% Convert the structure of possible linespecs to a proper cell
ceFields_Linespec = fieldnames(stLinespec);
if numel(ceFields_Linespec)
    ceLinespec = cell(1, numel(ceFields_Linespec)*2, 1);
    ceLinespec(1:2:end) = ceFields_Linespec;
    ceLinespec(2:2:end) = struct2cell(stLinespec);
end
loIsColor = strcmpi(ceLinespec, 'color');
loIsEdgeColor = strcmpi(ceLinespec, 'edgecolor');
if any(loIsColor)
    ceLinespec{loIsColor} = 'FaceColor';
    if ~any(loIsEdgeColor)
        ceLinespec{end+1} = 'EdgeColor';
        ceLinespec{end+1} = ceLinespec{find(loIsColor) + 1};
    end
end
% Get a valid axes handle
haTarget = newplot(haTarget);
% Old hold state
lOldHold = ishold(haTarget);
% Tell figure to add next plots
hold(haTarget, 'on');



%% Draw the circle
% Linear space of the angle
vTheta = 0:1e-3:2*pi;

% Draw the circle
hRadius = patch(haTarget,  vCenter(1,1) + dRadius(1)*cos(vTheta), vCenter(1,2) + dRadius(1)*sin(vTheta), 0);

% Set user-defined plot styles?
if ~isempty(ceLinespec)
    set(hRadius, ceLinespec{:});
end



%% Cleanup
% Draw the figure
drawnow

% Reset the old hold state if it wasn't set
if ~lOldHold
    hold(haTarget, 'off');
end



%% Assign output quantities
% Return the plot handle?
if nargout > 0
    varargout{1} = hRadius;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
