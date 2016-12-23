function varargout = shadow3(plane, varargin)
% SHADOW3 plots a 3D shadow3 plot of all data into the given axes onto the given
% plane
%
%   SHADOW3(PLANE) draws a shadow3 plot of the current axes data onto plane PLANE.
%   Plane must be any of the following:
%       xy|yx   Plot onto the XY plane
%       yz|zy   Plot onto the YZ plane
%       xz|zx   Plot onto the XZ plane
%
%   Inputs:
%
%   PLANE                Description of argument PLANE



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-12-23
% Changelog:
%   2016-12-23
%       * Initial release



%% Define the input parser
ip = inputParser;

% Plane: Char. Matches {'xy', 'yx', 'yz', 'zy', 'xz', 'zx'};
% valFcn_Plane = @(x) any(validatestring(lower(x), {'xy', 'yx', 'yz', 'zy', 'zx', 'xz'}, mfilename, 'Plane'));
addRequired(ip, 'Plane', @valFcn_Plane);

% PatchSpec: Cell, Empty
valFcn_PatchSpec = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'PatchSpec');
addParameter(ip, 'PatchSpec', {}, valFcn_PatchSpec);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    varargin = [{plane}, varargin];
    [haTarget, args, ~] = axescheck(varargin{:});
    
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results and prepare local variables
% Parse the plane as 'xy', 'yz', or 'xz'
chPlane = in_parsePlane(ip.Results.Plane);
% Specs of the patches
cePatchSpec = ip.Results.PatchSpec;
% Get a valid axes handle
haTarget = newplot(haTarget);
% Old hold state
lOldHold = ishold(haTarget);
% Tell figure to add next plots
hold(haTarget, 'on');



%% Draw the shadow3

[idxPlane, idxZero, idxAxisLim] = in_planeToIdx(chPlane);

% Get all child objects (lines, patch, surfaces, ...) that are not already
% shadow3 objects
hbOjects = findobj(haTarget.Children, '-not', {'-regexp', 'Tag', '^Shadow_\d'});

% Get axis limits and the respective limit for the selected target axis
vAxisLims = axis(haTarget);
dAxisLim = vAxisLims(idxAxisLim);

% Count children
nChildren = numel(hbOjects);

% Get the plot data of all children of the given axes
ceGraphicData = get(hbOjects, {'XData', 'YData', 'ZData'});
% Stores handles to the shadow3 patches
goShadows = gobjects(nChildren, 1);

% dimdiff = 2;    % Most cases
% if ( idxZero == 2 && dimvar == 3 ) || ( idxZero == 3 )
%     dimdiff = 1;
% end

% Copy the graphics opjects to shadow3 objects
ceShadowData = ceGraphicData;
% % Loop over each child
for iCh = 1:nChildren
    % Skip empty children (created from plot3(NaN,NaN,NaN))
    if isempty([ceShadowData{iCh,:}]) || aall(isnan([ceShadowData{iCh,:}]))
        continue
    end
    
%     % Stores the outside of the shadow3
%     ceData = cell(3, 1);
%     % The squished dimension has a constant value
%     ceData{idxZero} = dAxisLim.*ones(size(shiftdata(ceGraphicData{iCh,idxZero}, []), 1)*2, 1);
    
    % Set the values of the dimension that is going to be squished to the
    % smallest axes dimensions value
    ceShadowData{iCh,idxZero} = dAxisLim.*ones(size(ceGraphicData{iCh,idxZero}));
    % Use MATLAB's SURF2PATCH to convert the modified surface object to a proper
    % patch object (that's the easiest thing)
    goShadows(iCh) = patch(surf2patch(ceShadowData{iCh,1}, ceShadowData{iCh,2}, ceShadowData{iCh,3}));
%     goShadows(iCh) = patch(ceData{1}, ceData{2}, ceData{3});
    goShadows(iCh).FaceColor = [1, 0, 0];
    goShadows(iCh).FaceAlpha = 0.3;
    goShadows(iCh).LineStyle = 'none';
    goShadows(iCh).Tag = sprintf('Shadow_%i', iCh);
    
    % Set user-defined patch specs
    if ~isempty(cePatchSpec)
        set(goShadows(iCh), cePatchSpec{:});
    end
end


end


function [chPlane] = in_parsePlane(chPlane)

chPlane = sort(lower(chPlane));

end

function [idxPlane, idxZero, idxAxisLim] = in_planeToIdx(chPlane)

stNames = regexp(in_parsePlane(chPlane), '(?<sign>[\+|\-]?)(?<plane>[xyz]{2})', 'names');

switch sort(stNames.plane)
    case 'xy'
        idxPlane = [1, 2];
        idxZero = 3;
        if strcmp(stNames.sign, '+')
            idxAxisLim = 6;
        else
            idxAxisLim = 5;
        end
    case 'yz'
        idxPlane = [2, 3];
        idxZero = 1;
        if strcmp(stNames.sign, '-')
            idxAxisLim = 1;
        else
            idxAxisLim = 2;
        end
    case 'xz'
        idxPlane = [1, 3];
        idxZero = 2;
        if strcmp(stNames.sign, '-')
            idxAxisLim = 3;
        else
            idxAxisLim = 4;
        end
end

end

function valFcn_Plane(chPlane)

stNames = regexp(chPlane, '(?<sign>[\+|\-]?)(?<plane>[xyz]{2})', 'names');

assert(~isempty(stNames.plane), 'PHILIPPTEMPEL:MATLABTOOLING:SHADOW3:InvalidPlaneSelection', 'Invalid plane selection. Must be signed versions of {xy, yz, xz}.');

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
