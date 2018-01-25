function save_figure(Filename, varargin)
% SAVE_FIGURE Saves the figure under the specified filename with variable types
% 
%   SAVE_FIGURE(FILENAME) saves the current figure under FILENAME. If FILENAME
%   is only a file name, then it will be relative to the current pwd. FILENAME
%   may also be an absolute path. However, FILENAME must always end with the
%   actual file name for the figure to be stored under without the extension
%   such as 'fig' or 'eps'.
%   
%   SAVE_FIGURE(FILENAME, TYPES) saves the current figure with the specified
%   file types given as a cell array Currently supported export types are:
%
%       emf
%       eps
%       fig
%       png
%       pdf
%       tikz
%
%   The default save type is {'fig'}. Also works with attribute-value key
%   'Types'.
%
%   For example, SAVE_FIGURE(FILENAME, {'fig', 'eps', 'png'}) saves the current
%   figure as fig, eps, and png.
%
%   SAVE_FIGURE(FILENAME, 'ParameterName', 'ParameterValue') allows passing
%   additional supported parameter name-value pairs.
%
%   SAVE_FIGURE(FIG, ...) stores the given figure instead of the currently
%   active figure.
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
%   InDir       Ensures that each figure save is stored inside its own
%               directory depending on the filetype i.e., 'tikz' files will be
%               saved under 'tikz/FILENAME' whereas 'eps' files will be saved
%               under 'eps/FILENAME'. The directory level will be the last level
%               before the actual file name. Usage options are
%                   'on', 'yes'     enable storing per file type
%                   'off', 'no'     disable storing per file type (default)
%   
%   EpsPrint    Pass custom print options to eps print command. Default
%               command configuration is
%               '-depsc', '-tiff', '-zbuffer', '-r200'
%               '-dpng', '-loose', '-zbuffer', '-r200'
%
%   PdfPrint    Pass custom print options to pdf print command. Default
%               command configuration is
%               '-dpdf', '-painters', '-loose', '-zbuffer'
%
%   PngPrint    Pass custom print options to png print command. Default
%               command configuration is
%               '-dpng', '-loose', '-zbuffer', '-r200'
%   
%   TikzPrint   Pass custom print options to tikz print command.
%
%
%   See also: SAVEAS, PRINT
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-01-22
% Changelog:
%   2018-01-22
%       * Change printer for PNG from 'zbuffer' to 'opengl'
%   2016-11-11
%       * Adjust message identifiers of MExceptions
%       * Replace `in_charToValidArgument` with `parseswitcharg`
%   2016-09-22
%       * Rename to 'save_figure' as it shadows with
%       `toolbox/matlab/graphics/saveFigure.m`
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
    assert(all(isfig(Filename)), 'PHILIPPTEMPEL:SAVE_FIGURE:incorrectHandleType', 'All handles must be figure handles');
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
chInDir = parseswitcharg(ip.Results.InDir);
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
chFileTarget = fullpath(chFileTarget);
[chPath, chFilename, ~] = fileparts(chFileTarget);

% Loop over all figures
for iFig = 1:nFigures
    try
        % Get the current figure
        hfTheSource = hfSource(iFig);

        % Make the given figure active and visible
        figure(hfTheSource);
        hfTheSource.Visible = 'on';

        % Append number of figure if more than one figure
        if nFigures > 1
            chFilename = sprintf(sprintf('%%s-%%0%dd', length(sprintf('%d', nFigures)) + 1), chFilename, iFig);
        end

        % FIG
        if ismember('fig', ceOutputTypes)
            chFilepath = in_createFilepath(chPath, 'fig', chInDir);
            % Matlab .FIG file
            saveas(hfTheSource, [chFilepath , '.fig']);
        end

        % EMF
        if ismember('emf', ceOutputTypes)
            chFilepath = in_createFilepath(chPath, 'emf', chInDir);
            % Windows Enhanced Meta-File (best for powerpoints)
            saveas(hfTheSource, [chFilepath , '.emf']);
        end

        % PNG
        if ismember('png', ceOutputTypes)
            chFilepath = in_createFilepath(chPath, 'png', chInDir);
            % Standard PNG graphics file (best for web)
            print('-dpng', '-loose', '-opengl', '-r200', [chFilepath, '.png'], cePngConfig{:});
        end

        % EPS
        if ismember('eps', ceOutputTypes)
            chFilepath = in_createFilepath(chPath, 'eps', chInDir);
            % Enhanced Postscript (Level 2 color) (Best for LaTeX documents)
            print('-depsc', '-tiff', '-zbuffer', '-r200', [chFilepath, '.eps'], ceEpsConfig{:});
        end

        % PDF
        if ismember('pdf', ceOutputTypes)
            chFilepath = in_createFilepath(chPath, 'pdf', chInDir);
            % Full page Portable Document Format (PDF) color
            print('-dpdf', '-painters', [chFilepath, '.pdf'], cePdfConfig{:});
        end

        % TikZ
        if ismember('tikz', ceOutputTypes)
            chFilepath = in_createFilepath(chPath, 'tikz', chInDir);
            matlab2tikz('FigureHandle', hfTheSource, 'filename', [chFilepath, '.tikz'], 'figurehandle', hfSource, 'ShowInfo', false, ceTikzConfig{:});
        end
    catch me
        % Add a cause to the exception
        me = addCause(me, MException('PHILIPPTEMPEL:MATLAB_TOOLING:SAVE_FIGURE:errorSaveFile', 'Error saving file [%s].', chFilepath));
        
        % And throw the exception
        throwAsCaller(me);
    end
end


end


function chTargetPath = in_createFilepath(chPath, chFolder, chInDir)
%% IN_CREATEFILEPATH creates the filepath given the base path and InDir flag


% Get a FQPN of the target path
chTargetPath = fullfile(chPath);

% Store inside directories?
if strcmp('on', chInDir)
    % Ensure we have a directory
    mkdir(fullfile(chPath, chFolder));
    % Append this directory to the target path
    chTargetPath = fullfile(chTargetPath, chFolder);
end

% Append the filename to the target path
chTargetPath = fullfile(chTargetPath, chFilename);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
