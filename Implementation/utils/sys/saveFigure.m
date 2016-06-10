function saveFigure(Filename, varargin)
% SAVEFIGURE Saves the figure under the specified filename with variable types
% 
%   SAVEFIGURE(FILENAME) saves the current figure under FILENAME. If FILENAME is
%   only a file name, then it will be relative to the current pwd. FILENAME may
%   also be an absolute path. However, FILENAME must always end with the actual
%   file name for the figure to be stored under without the extension such as
%   'fig' or 'eps'.
%   
%   SAVEFIGURE(FILENAME, TYPES) saves the current figure with the specified file
%   types given as a cell array Currently supported export types are:
%
%       emf
%       eps
%       fig
%       png
%       tikz
%
%   The default save type is {'fig'}. Also works with attribute-value key
%   'Types'
%
%   For example, SAVEFIGURE(FILENAME, {'fig', 'eps', 'png'}) saves the current
%   figure as fig, eps, and png.
%
%   SAVEFIGURE(FILENAME, 'ParameterName', 'ParameterValue') allows passing
%   additional supported parameter name-value pairs.
%
%   SAVEFIGURE(FIG, ...) stores the given figure instead of the currently active
%   figure
%   
%   Inputs:
%   
%   FILENAME: Name of the file to store figure under. Can be a relative or
%   absolute paths (relatives are of course relative to the current pwd). The
%   file name can end with an extension, the corresponding image file type
%   extensions will be appended nevertheless
%
%   TYPES: Cell array of file types to store figure under. Defaults to {'fig'}.
%
%   Optional Inputs -- specified as parameter value pairs
%   InDir       - Ensures that each figure save is stored inside its own
%               directory depending on the filetype i.e., 'tikz' files will be
%               saved under 'tikz/FILENAME' whereas 'eps' files will be saved
%               under 'eps/FILENAME'. The directory level will be the last level
%               before the actual file name. Usage options are
%                   'on', 'yes'     enable storing per file type
%                   'off', 'no'     disable storing per file type (default)
%   
%   EpsPrint    - Pass custom print options to eps print command. Default
%               command configuration is
%               '-depsc', '-tiff', '-zbuffer', '-r200'
%               '-dpng', '-loose', '-zbuffer', '-r200'
%
%   PngPrint    - Pass custom print options to tikz print command. Default
%               command configuration is
%               '-dpng', '-loose', '-zbuffer', '-r200'
%   
%   TikzPrint   - Pass custom print options to tikz print command.
%
%
%   See also: SAVEAS, PRINT
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-06-10
% Changelog:
%   2016-06-10
%       * Fix check of function for a valid figure handle
%       * Update docs to reflect proper Name-Value pair arguments
%   2016-03-30
%       * Initial release



%% Pre-process inputs
haFig = false;

if ~isempty(varargin) && ishandle(Filename) && strcmpi(get(Filename, 'type'), 'figure')
    haFig = Filename;
    Filename = varargin{1};
    varargin = varargin(2:end);
end



%% Input parser
ip = inputParser;

% Require: Filename without ending
valFcn_Filename = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Filename');
addRequired(ip, 'Filename', valFcn_Filename);

% Optional 1: Types of files to save as
valFcn_Types = @(x) all(cellfun(@(x) any(validatestring(x, {'eps', 'fig', 'tikz', 'png', 'emf'}, mfilename, 'Types'))));
addOptional(ip, 'Types', {'fig'}, valFcn_Types);

% Optional 2: Create subdirs for each type
valFcn_Subdirs = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'InDir'));
addOptional(ip, 'InDir', 'off', valFcn_Subdirs);

% Optional: Allow custom eps print options
valFcn_EpsPrint = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'EpsPrint');
addOptional(ip, 'EpsPrint', {}, valFcn_EpsPrint);

% Optional: Allow custom tikz print options
valFcn_TikzPrint = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'TikzPrint');
addOptional(ip, 'TikzPrint', {}, valFcn_TikzPrint);

% Optional: Allow custom png print options
valFcn_PngPrint = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'PngPrint');
addOptional(ip, 'PngPrint', {}, valFcn_PngPrint);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, Filename, varargin{:});



%% Parse inputs
% Filename
chFilepath = ip.Results.Filename;
% Types
ceOutputTypes = ip.Results.Types;
% Create dirs for each type
chInDir = inCharToValidArgument(ip.Results.InDir);
% Custom eps print options
ceEpsConfig = ip.Results.EpsPrint;
% Custom tikz print options
ceTikzConfig = ip.Results.TikzPrint;
% Custom png print options
cePngConfig = ip.Results.PngPrint;



%% Off we go
% If no specific figure was given, we will just use the current figure
if ~ishandle(haFig)
    haFig = gcf;
end

% Make the given figure active and visible
figure(haFig);
set(haFig, 'Visible', 'on');

% Check the filename is a valid file i.e., starts with a directory
chFilepath = GetFullPath(chFilepath);
[chPath, chFilename, chExtension] = fileparts(chFilepath);
% % Get the parts of the FQFN to make sure we don't have an extension
% [pathstr, name, ext] = fileparts(chFilename);
% % If there's an extension givne 
% if ~isempty(ext)
%     chFilename = fullfile(pathstr, name);
% end

% Save as fig
if ismember('fig', ceOutputTypes)
    if strcmp(chInDir, 'on')
        mkdir(fullfile(chPath, 'fig'));
        chTargetFolder = fullfile(chPath, 'fig', chFilename);
    else
        chTargetFolder = fullfile(chPath);
    end
    
    saveas(haFig, [chTargetFolder , '.fig']);   % Matlab .FIG file
end

% Save as emf
if ismember('emf', ceOutputTypes)
    if strcmp(chInDir, 'on')
        mkdir(fullfile(chPath, 'emf'));
        chTargetFolder = fullfile(chPath, 'emf', chFilename);
    else
        chTargetFolder = fullfile(chPath);
    end
    
    saveas(haFig, [chTargetFolder , '.emf']);   % Windows Enhanced Meta-File (best for powerpoints)
end

% Save as png
if ismember('png', ceOutputTypes)
    if strcmp(chInDir, 'on')
        mkdir(fullfile(chPath, 'png'));
        chTargetFolder = fullfile(chPath, 'png', chFilename);
    else
        chTargetFolder = fullfile(chPath);
    end
    
%     saveas(haFig, [chTargetFolder, '.png']);   % Standard PNG graphics file (best for web)
    print('-dpng', '-loose', '-zbuffer', '-r200', [chTargetFolder, '.png'], cePngConfig{:}); 
end

% Save as eps
if ismember('eps', ceOutputTypes)
    if strcmp(chInDir, 'on')
        mkdir(fullfile(chPath, 'eps'));
        chTargetFolder = fullfile(chPath, 'eps', chFilename);
    else
        chTargetFolder = fullfile(chPath);
    end
    
%     eval(['print -depsc2 ' , [chTargetFolder, '.eps']]);   % Enhanced Postscript (Level 2 color) (Best for LaTeX documents)
    print('-depsc', '-tiff', '-zbuffer', '-r200', [chTargetFolder , '.eps'], ceEpsConfig{:});
end

% Save as tikz
if ismember('tikz', ceOutputTypes)
    % Save in a subdir? Then make sure we have the subdirectory set
    if strcmp(chInDir, 'on')
        mkdir(fullfile(chPath, 'tikz'));
        chTargetFolder = fullfile(chPath, 'tikz');
    else
        chTargetFolder = fullfile(chPath);
    end
    
%     matlab2tikz([chTargetFolder , '.tikz'], 'Height', '\figureheight', 'Width', '\figurewidth', 'ShowInfo', false);
    matlab2tikz([chTargetFolder , '.tikz'], ceTikzConfig{:});
end


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

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
