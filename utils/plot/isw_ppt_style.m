function [Style] = isw_ppt_style(Layout, varargin)
% ISW_PPT_STYLE returns the struct representing the figure export style
%
%   STYLE = ISW_PPT_STYLE(LAYOUT) returns the struct representing the ISW
%   powerpoint style layout that can be used for hgexport. The resulting struct
%   STYLE can then be used in the following way
%
%       STYLE = ISW_PPT_STYLE('Inhalt')
%       FILENAME = 'file.jpg';
%       STYLE.Format = 'jpeg';
%       HGEXPORT(gcf, FILENAME, STYLE);
%
%   Inputs:
%
%   LAYOUT      ame of the layout that shall be used for creating the struct
%
%   Outputs:
%
%   STYLE       Structure of figure export configuration that can be used for
%   HGEXPORT
%
%   See also: HGEXPORT



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-10-12
% Changelog:
%   2016-10-12
%       * Initial release



%% Define the input parser
ip = inputParser;

% Layout: Required; Matches {'Inhalt', 'Zwei Inhalte'}
valFcn_Layout = @(x) any(validatestring(lower(x), {'inhalt', 'zwei inhalte'}, mfilename, 'Layout'));
addRequired(ip, 'Layout', valFcn_Layout);

% Format: Optional; Matches {'4:3', '16:9'}
valFcn_Format = @(x) any(validatestring(lower(x), {'4:3', '16:9'}, mfilename, 'Format'));
addOptional(ip, 'Format', '4:3', valFcn_Format);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    varargin = [{Layout}, varargin];
    
    parse(ip, varargin{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results
% Grab the layout
chLayout = lower(ip.Results.Layout);
% Format
chFormat = lower(ip.Results.Format);



%% Local variables
% Final structure
stStyle = struct('Version', '1' ...
    , 'Format', 'jpeg' ...
    , 'Preview', 'none' ...
    , 'Width', '13.1' ...
    , 'Height', '13.1' ...
    , 'Units', 'centimeters' ...
    , 'Color', 'rgb' ...
    , 'Background', 'w' ...
    , 'FixedFontSize', '18' ...
    , 'ScaledFontSize', 'auto' ...
    , 'FontMode', 'scaled' ...
    , 'FontSizeMin', '12' ...
    , 'FixedLineWidth', '1.5' ...
    , 'ScaledLineWidth', 'auto' ...
    , 'LineMode', 'scaled' ...
    , 'LineWidthMin', '1.5' ...
    , 'FontName', 'Frutiger LT Com 55 Roman' ...
    , 'FontWeight', 'normal' ...
    , 'FontAngle', 'auto' ...
    , 'FontEncoding', 'latin1' ...
    , 'PSLevel', '2' ...
    , 'Renderer', 'painters' ...
    , 'Resolution', '600' ...
    , 'LineStyleMap', 'none' ...
    , 'ApplyStyle', '1' ...
    , 'Bounds', 'loose' ...
    , 'LockAxes', 'on' ...
    , 'LockAxesTicks', 'off' ...
    , 'ShowUI', 'on' ...
    , 'SeparateText', 'off' ...
);



%% Off we go
% Create a string for the switch so we do not have a nested switch
chSwitch = sprintf('%s|%s', chLayout, chFormat)

% Switch according to layout and format
switch chSwitch
    case 'inhalt|4:3'
        stStyle.Width = '22.8';
    case 'inhalt|16:9'
        stStyle.Width = '30.4';
    case 'zwei inhalte|4:3'
        stStyle.Width = '11.2';
    case 'zwei inhalte|16:9'
        stStyle.Width = '14.93';
end



%% Assign outputs
% First output: Style structure
Style = stStyle;

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
