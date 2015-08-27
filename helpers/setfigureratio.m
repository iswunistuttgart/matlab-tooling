function setfigureratio(Ratio, varargin)

%% Default arguments
hFig = false;

if ~isempty(varargin) && isa(Ratio, 'matlab.ui.Figure')
    hFig = Ratio;
    Ratio = varargin{1};
    varargin = varargin(2:end);
end



%% Assertion
assert(isa(Ratio, 'char'));


%% Parse arguments
chRatio = Ratio;
% Parse the string to find either 'width' or 'width:height'
stRatio = regexp(chRatio, '(?<width>\d+):(?<height>\d+)', 'names');

% If no figure given, we will fallback to the active one
if ~ishandle(hFig)
    hFig = gcf;
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
vPosition = get(hFig, 'Position');
vWidth = vPosition(3);
vHeight = vPosition(4);

% Set the new height
vNewHeight = vHeight;
% Calculate the new width
vNewWidth = vNewHeight/(stRatio.height)*(stRatio.width);

% Create the new position vector
vNewPosition = [vPosition(1), vPosition(2), vNewWidth, vNewHeight];

% And set the position (thus location and dimensions) on the figure;
set(hFig, 'Position', vNewPosition);

end