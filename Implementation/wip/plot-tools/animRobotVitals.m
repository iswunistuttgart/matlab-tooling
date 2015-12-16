function [varargout] = animRobotVitals(Time, Poses, CableForces, varargin)
% ANIMROBOTVITALS Animates the vitals of the robot movement
% 
%   ANIMROBOTVITALS(TIME, POSES, CABLEFORCES) animates the robot vitals over
%   TIME with the robots POSES and CABLEFORCES
%
%   See also: VIEW, PLOT3, TEXT, PATCH, GRID, TITLE, XLABEL, YLABEL, ZLABEL
%
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-11-14
% Changelog:
%   2015-11-14
%       * Rename options 'AnchorLabel' and 'AnchorLabelSpec' to 'PulleyLabel'
%       and 'PulleyLabelSpec', respectively
%       * Update function to no longer do fancy things with transforming the
%       cable shape in any magic way but not uses the output of algoCableShape_*
%       as a direct argument to the plot command only shifting the shape to
%       start at the cable's respective winch
%   2015-08-24:
%       * Initial release



%% Preprocess inputs (allows to have the axis defined as first argument)



%% Parse inputs
ip = inputParser;

% Require: Time. Must be a 1d vector
valFcn_Time = @(x) validateattributes(x, {'numeric'}, {'vector'}, mfilename, 'Time');
addRequired(ip, 'Time', valFcn_Time);

% Require: Poses. Must be a 2d vector 
valFcn_Poses = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', numel(Time)}, mfilename, 'Poses');
addRequired(ip, 'Poses', valFcn_Poses);

% Require: CableForces. Must be a 2d vector 
valFcn_CableForces = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', numel(Time)}, mfilename, 'CableForces');
addRequired(ip, 'CableForces', valFcn_CableForces);

% Optional: ForceSplit; Allow user to choose which forces shall be displayed in
% which plot
valFcn_ForceSplit = @(x) validateattributes(x, {'numeric'}, {'2d', 'numel', size(CableForces, 2)}, mfilename, 'ForceSplit');
addOptional(ip, 'ForceSplit', [1 2 3 4; 5 6 7 8], valFcn_ForceSplit);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, Time, Poses, CableForces, varargin{:});



%% Off we go
% Extract variables from input parser
vTime = ip.Results.Time;
aPoses =ip.Results.Poses;
aCableForces = ip.Results.CableForces;
aForceSplit = ip.Results.ForceSplit;

% Create a new figure
hFig = figure();

% How maney force plots?
nForcePlots = size(aForceSplit, 1);


%% Prepare our axes
% First axes spanning the first column is the pose
hAx1 = subplot(nForcePlots, 2, 1:2:2*nForcePlots);
plot3(hAx1, NaN, NaN, NaN);
% Following axes will be the forces depending on nForcePlots
hAxForces = zeros(nForcePlots, 1);
for iForcePlot = 1:nForcePlots
    % Create an empty axes object
    hAxForces(iForcePlot) = subplot(nForcePlots, 2, 2*iForcePlot);
    % Plot an empty data set
    plot(hAxForces(iForcePlot), NaN, NaN);
    xlabel(hAxForces(iForcePlot), 'Time $t \left[ \rm{s} \right]$');
    ylabel(hAxForces(iForcePlot), 'Net force $f_i \left[ \rm{N} \right]$');
    xlim(hAxForces(iForcePlot), [vTime(1), vTime(end)]);
    ylim(hAxForces(iForcePlot), [min(min(aCableForces(:, aForceSplit(iForcePlot,:)))), max(max(aCableForces(:, aForceSplit(iForcePlot,:))))]);
    title(sprintf('Cable forces $%i..%i$', aForceSplit(iForcePlot,1), aForceSplit(iForcePlot,end)));
end




%% Assign outputs
if nargout > 0
    varargout{1} = hFig;
end


end