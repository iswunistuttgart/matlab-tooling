function setfigureratio(Ratio, varargin)
% SETFIGURERATIO sets the ratio of the current or given figure
%
%   SETFIGURERATIO(RATIO) sets the figure to the chosen width:height ratio.
%
%   SETFIGURERATIO(FIG, ...) sets ratio RATIO on the given figure.
%
%   Inputs:
%
%   RATIO:  Ratio to be set on the current or given figure. Ratios are defined
%           as 'width:height' or 'width' where the latter results in a figure
%           with square ratio i.e., 'width:width'. Examples are '16:9' or '4:3'.
%
%   FIG:    Valid figure handle (not axes handle) that shall have the ratio set
%           on



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-08-02
% Changelog:
%   2016-08-02
%       * Add help doc block and update other doc blocks
%       * Update to using ```newplot``` and ```acestor```
%   2016-04-01
%       * Initial release



%% Pre-process inputs
% Target figure
hfTarget = [];
% Allow the target figure to be given as the first argument
if ~isempty(varargin) && isa(Ratio, 'matlab.ui.Figure')
    hfTarget = Ratio;
    Ratio = varargin{1};
    varargin = varargin(2:end);
end




%% Assertion
assert(isa(Ratio, 'char'), 'Ratio must be a char');



%% Parse arguments
if isempty(hfTarget)
    % Target axes
    haTarget = newplot();
    hfTarget = ancestor(haTarget,'figure');
end
% Ratio
chRatio = Ratio;
% Parse the string to find either 'width' or 'width:height'
stRatio = regexp(chRatio, '(?<width>\d+):(?<height>\d+)', 'names');
% If no figure given, we will fallback to the active one
if ~ishandle(hfTarget)
    hfTarget = gcf;
end

% Ensure we have at least a width given
if ~isfield(stRatio, 'width')
    error('No width set');
end

% If there is no height given it will be a 1:1 figure
if ~isfield(stRatio, 'height')
    stRatio.height = stRatio.width;
end

% Parse chars to be nums
stRatio.height = str2double(stRatio.height);
stRatio.width = str2double(stRatio.width);

% Get the current figures position (thus position and width)
vPosition = get(hfTarget, 'Position');
vWidth = vPosition(3);
vHeight = vPosition(4);

% Set the new height
vNewHeight = vHeight;
% Calculate the new width
vNewWidth = vNewHeight/(stRatio.height)*(stRatio.width);

% Create the new position vector
vNewPosition = [vPosition(1), vPosition(2), vNewWidth, vNewHeight];

% And set the position (thus location and dimensions) on the figure;
set(hfTarget, 'Position', vNewPosition);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
