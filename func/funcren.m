function funcren(Old, New, varargin)
% FUNCREN renames the function to a new name
%
%   FUNCREN(OLD, NEW) renames function OLD to NEW and changes its signature.
%
%   FUNCNREN(OLD, NEW, 'Name', 'Value', ...) allows setting optional inputs
%   using name/value pairs.
%
%   Inputs:
%
%   OLD                 Old name of function. Must be the old name and not the
%                       file name of the function
%
%   Optional Inputs -- specified as parameter value pairs
%
%   Open                Flag to open file after renaming or not. Possible values
%                       are
%                       'on', 'yes'     Open file in editor after renaming
%                       'off', 'no',    Do not open file in editor after
%                                       renaming
%                       Defaults to 'off'
%
%   NEW                 New name of function. Must be the new name and not the
%                       file name of the function



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-01-10
% TODO:
%   * Need to be able to handle packaged function names. For the old function
%   name it seems to work, but for the new function name it does (somehow
%   magically, but not really) work.
% Changelog:
%   2018-03-03
%       * Change parameter 'silent' to 'open' and change it's default value to
%       'off'.
%       * Update H1 with help on name/value-parameters
%   2017-01-10
%       * Add TODO to handle packaged functions
%   2016-12-03
%       * Fix bug that would prevent function name to be replaced if the full
%       filename was given i.e., `funcren('oldname.m', 'newname.,')` would not
%       have renamed any occurence of `OLDNAME` in the script but only of
%       `OLDNAME.M`
%   2016-11-11
%       * Adjust message identifiers of MExceptions
%       * Replace `in_charToValidArgument` with `parseswitcharg`
%   2016-10-08
%       * Fix bug when file-extension was given in old filename and new file
%       content would be without replaced function name in text inside
%   2016-08-25
%       * Add option 'Silent' to silent renaming i.e., to not open file
%       afterwards
%   2016-08-02
%       * Initial release



%% Define the input parser
ip = inputParser;

% Require: Filename
valFcn_Old = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Old');
addRequired(ip, 'Old', valFcn_Old);

% Allow custom input argument list
valFcn_New = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'New');
addRequired(ip, 'New', valFcn_New);

% Silent creation i.e., not opening file afterwards
valFcn_Open = @(x) any(validatestring(x, {'on', 'off', 'yes', 'no', 'please', 'never'}, mfilename, 'Open'));
addParameter(ip, 'Open', 'off', valFcn_Open);


% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    % FUNCREN(OLD, NEW);
    % FUNCREN(OLD, NEW, 'Name', 'Value', ...);
    narginchk(2, Inf);
    
    % FUNCREN(OLD, NEW);
    nargoutchk(0, 0);
    
    args = [{Old}, {New}, varargin];
    
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Parse results
% Old function name
chName_Old = ip.Results.Old;
% New function name
chName_New = ip.Results.New;
% Open after rename
chOpen = parseswitcharg(ip.Results.Open);




%% Rename file
% Get the path to the specified function
chOld_Filepath = which(chName_Old);
assert(~isempty(chOld_Filepath), 'PHILIPPTEMPEL:MATLAB_TOOLING:FUNCREN:InvalidFuncName', 'Could not find function %s anywhere in your path', chName_Old);

% Get the path parts of the old and new file
[chOld_Path, chOld_Name, chOld_Ext] = fileparts(chOld_Filepath);
[~, chNew_Name, ~] = fileparts(chName_New);
% Create path parts for the new file
chNew_Path = chOld_Path;
chNew_Ext = chOld_Ext;

% Find out if the old function is a packaged function, if so, check the new
% function name if its packaged or not and adjust accordingly (fail if there is
% no such new module)

% Create path of new file
chNew_Filepath = fullfile(chNew_Path, sprintf('%s%s', chNew_Name, chNew_Ext));

% Try copying the file
try
    movefile(chOld_Filepath, chNew_Filepath);
catch me
    throwAsCaller(MException(me.identifier, me.message));
end

% Read the new file's content
try
    fidSource = fopen(chNew_Filepath);
    ceFunction_Contents = textscan(fidSource, '%s', 'Delimiter', '\n', 'Whitespace', ''); ceFunction_Contents = ceFunction_Contents{1};
    fclose(fidSource);
catch me
    if strcmp(me.identifier, 'MATLAB:FileIO:InvalidFid')
        throw(MException('PHILIPPTEMPEL:MATLAB_TOOLING:FUNCREN:InvalidFid', 'Could not open source file for reading.'));
    end
    throwAsCaller(MException(me.identifier, me.message));
end

% Replace the function name
ceReplacers = {
    chOld_Name, chNew_Name;
    upper(chOld_Name), upper(chNew_Name);
};
% Replace all placeholders with their respective content
for iReplace = 1:size(ceReplacers, 1)
    ceFunction_Contents = cellfun(@(str) strrep(str, sprintf('%s', ceReplacers{iReplace,1}), ceReplacers{iReplace,2}), ceFunction_Contents, 'Uniform', false);
end
% Save the changed function contentes
try
    fidTarget = fopen(chNew_Filepath, 'w+');
    for row = 1:numel(ceFunction_Contents)
        fprintf(fidTarget, '%s\r\n', ceFunction_Contents{row,:});
    end
    fcStatus = fclose(fidTarget);
    assert(fcStatus == 0);
catch me
    if strcmp(me.identifier, 'MATLAB:FileIO:InvalidFid')
        throw(MException('PHILIPPTEMPEL:MATLAB_TOOLING:FUNCREN:InvalidFid', 'Could not open target file for writing.'));
    end
    throwAsCaller(MException(me.identifier, me.message));
end



%% Assign output quantities

% Open file afterwards?
if strcmp('on', chOpen)
    edit(chNew_Filepath);
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
