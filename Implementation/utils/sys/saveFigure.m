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
%       pdf
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
%   PdfPrint    - Pass custom print options to pdf print command. Default
%               command configuration is
%               '-dpdf', '-painters', '-loose', '-zbuffer'
%
%   PngPrint    - Pass custom print options to png print command. Default
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
% Date: 2016-09-11
% Changelog:
%   2016-09-11
%       * Add support for printing to PDF
%   2016-08-08
%       * Update logic for checking for figure handles in the first argument
%       * Add support for printing a batch of files at once with number appended
%       to the file name
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%   2016-06-10
%       * Fix check of function for a valid figure handle
%       * Update docs to reflect proper Name-Value pair arguments
%   2016-03-30
%       * Initial release



%% Pre-process inputs
hfSource = [];
% If there's more than the required argument FILENAME and the first argument is
% only figures, then shift arguments
if ~isempty(varargin) && any(isfig(Filename))
    assert(all(isfig(Filename)), 'PHILIPPTEMPEL:SAVEFIGURE:incorrectHandleType', 'All handles must be figure handles');
    hfSource = Filename;
    Filename = varargin{1};
    varargin = varargin(2:end);
end



%% Input parser
ip = inputParser;

% Require: Filename without ending
valFcn_Filename = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Filename');
addRequired(ip, 'Filename', valFcn_Filename);

% Optional 1: Types of files to save as
ceAllowedTypes = {'eps', 'fig', 'tikz', 'png', 'emf', 'pdf'};
valFcn_Types = @(x) assert(all(ismember(x, ceAllowedTypes)), 'The value of ''Types'' is invalid. It must be a member of:\n\n%s', strjoin(ceAllowedTypes, ', '));
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

% Optional: Allow custom pdf print options
valFcn_PdfPrint = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'PdfPrint');
addOptional(ip, 'PdfPrint', {}, valFcn_PdfPrint);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    parse(ip, Filename, varargin{:});
catch me
    throw(MException(me.identifier, me.message));
end



%% Parse inputs
% Filename
chFileTarget = ip.Results.Filename;
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
% Custom pdf print options
cePdfConfig = ip.Results.PdfPrint;



%% Off we go
% If no specific figure was given, we will just use the current figure
if isempty(hfSource)
    hfSource = gcf;
end

% Count how many figure shall be saved
nFigures = numel(hfSource);

% Check the filename is a valid file i.e., starts with a directory
chFileTarget = GetFullPath(chFileTarget);
[chPath, chFilename, ~] = fileparts(chFileTarget);

% Loop over all figures
for iFig = 1:nFigures
    try
        % Get the current figure
        hfTheSource = hfSource(iFig);

        % Make the given figure active and visible
        figure(hfTheSource);
        set(hfTheSource, 'Visible', 'on');

        % Append number of figure if more than one figure
        if nFigures > 1
            chFilename = sprintf(sprintf('%%s-%%0%dd', length(sprintf('%d', nFigures)) + 1), chFilename, iFig);
        end

        % Save as fig
        if ismember('fig', ceOutputTypes)
            chFilepath = in_createFilepath('fig');
            % Matlab .FIG file
            saveas(hfTheSource, [chFilepath , '.fig']);
        end

        % Save as emf
        if ismember('emf', ceOutputTypes)
            chFilepath = in_createFilepath('emf');
            % Windows Enhanced Meta-File (best for powerpoints)
            saveas(hfTheSource, [chFilepath , '.emf']);
        end

        % Save as png
        if ismember('png', ceOutputTypes)
            chFilepath = in_createFilepath('png');
            % Standard PNG graphics file (best for web)
            print('-dpng', '-loose', '-zbuffer', '-r200', [chFilepath, '.png'], cePngConfig{:});
        end

        % Save as eps
        if ismember('eps', ceOutputTypes)
            chFilepath = in_createFilepath('eps');
            % Enhanced Postscript (Level 2 color) (Best for LaTeX documents)
            print('-depsc', '-tiff', '-zbuffer', '-r200', [chFilepath, '.eps'], ceEpsConfig{:});
        end

        % Save as pdf
        if ismember('pdf', ceOutputTypes)
            chFilepath = in_createFilepath('pdf');
            % Full page Portable Document Format (PDF) color
            print('-dpdf', '-painters', [chFilepath, '.pdf'], cePdfConfig{:});
        end

        % Save as tikz
        if ismember('tikz', ceOutputTypes)
            chFilepath = in_createFilepath('tikz');
            % matlab2tikz([chTargetFolder , '.tikz'], 'Height', '\figureheight', 'Width', '\figurewidth', 'ShowInfo', false);
            matlab2tikz('FigureHandle', hfTheSource, 'filename', [chFilepath, '.tikz'], 'figurehandle', hfSource, 'ShowInfo', false, ceTikzConfig{:});
        end
    catch me
        me = addCause(me, MException('PHILIPPTEMPEL:SAVEFIGURE:errorSaveFile', 'Error saving file [%s]', chFilepath));
        
        throwAsCaller(me);
    end
end


    function chTargetPath = in_createFilepath(chFolder)
        chTargetPath = fullfile(chPath);
        if strcmp('on', chInDir)
            mkdir(fullfile(chPath, chFolder));
            chTargetPath = fullfile(chTargetPath, chFolder);
        end
        
        chTargetPath = fullfile(chTargetPath, chFilename);
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
