function funcnew(Name, varargin)
% FUNCNEW creates a new function file based on a template
%
%   FUNCNEW(NAME) creates function NAME into a new file at the specified
%   target. It will not have any input or return arguments pre-defined.
%
%   FUNCNEW(NAME, ARGIN) also adds the list of input arguments defined in
%   ARGIN to the function declaration.
%
%   FUNCNEW(NAME, ARGIN, ARGOUT) creates function NAME into a new file at
%   the specified target. The cell array ARGIN and ARGOUT define the argument
%   input and argument output names.
%
%   Inputs:
%
%   NAME:   Name of the function. Can also be a fully qualified file name from
%           which the function name will then be extracted.
%
%   ARGIN:  Cell array of input variable names. If empty, function will not take
%           any arguments. Placeholder 'varargin' can be used by liking. Note
%           that, any variable name occuring after 'varargin' will be striped.
%
%   ARGOUT: Cell array of output variable names. If empty i.e., {}, function
%           will not return any arguments. Placeholder 'varargout' may be used
%           by requirement. Note that, any variable name occuring after
%           'varargout' will be striped.
%
%   Optional Inputs -- specified as parameter value pairs
%   Author      Author string to be set. Most preferable you'd use something
%               like
%               'Firstname Lastname <author-email@example.com>'
%   Description Description of function which is usually the first line after
%               the function declaration and contains the function name in all
%               caps.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-08-02
% Changelog:
%   2016-08-02
%       * Initial release



%% Define the input parser
ip = inputParser;

% Require: Filename
valFcn_Name = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Name');
addRequired(ip, 'Name', valFcn_Name);

% Allow custom input argument list
valFcn_ArgIn = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'ArgIn');
addOptional(ip, 'ArgIn', {}, valFcn_ArgIn);

% Allow custom return argument list
valFcn_ArgOut = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'ArgOut');
addOptional(ip, 'ArgOut', {}, valFcn_ArgOut);

% Description
valFcn_Description = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Description');
addParameter(ip, 'Description', '', valFcn_Description);

% Description
valFcn_Author = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Author');
addParameter(ip, 'Author', 'Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>', valFcn_Author);

% Open afterwards
valFcn_Open = @(x) any(validatestring(x, {'on', 'off'}, mfilename, 'Open'));
addParameter(ip, 'Open', 'off', valFcn_Open);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    args = [{Name}, varargin];
    
    parse(ip, args{:});
catch me
    throwAsCaller(MException(me.identifier, me.message));
end



%% Parse results
% Function name/path
chName = ip.Results.Name;
% Get function path, file name, and extension
[chFunction_Path, chFunction_Name, chFunction_Ext] = fileparts(chName);
% Empty filepath?
if isempty(chFunction_Path)
    % Save in the current working directory
    chFunction_Path = pwd;
end
% Empty file extension?
if isempty(chFunction_Ext)
    % Ensure we'll save as '.m' file
    chFunction_Ext = '.m';
end
% List of input arguments
ceArgIn = ip.Results.ArgIn;
% List of output arguments
ceArgOut = ip.Results.ArgOut;
% Description text
chDescription = ip.Results.Description;
% Author name
chAuthor = ip.Results.Author;
% Open afterwards?
chOpen = in_charToValidArgument(ip.Results.Open);

%%% Local variables
% Path to function template file
chTemplateFilepath = fullfile(fileparts(mfilename('fullpath')), 'functiontemplate.mtpl');
% Date of creation of the file
chDate = datestr(now, 'yyyy-mm-dd');



%% Assert variables
% Assert we have a valid function template filepath
assert(2 == exist(chTemplateFilepath, 'file'), 'Function template cannot be found at %s', chTemplateFilepath);



%% Create the file contents
% Read the file template
try
    fidSource = fopen(chTemplateFilepath);
    ceFunction_Contents = textscan(fidSource, '%s', 'Delimiter', '\n', 'Whitespace', ''); ceFunction_Contents = ceFunction_Contents{1};
    fclose(fidSource);
catch me
    if strcmp(me.identifier, 'MATLAB:FileIO:InvalidFid')
        throw(MException('PHILIPPTEMPEL:NewFunction:InvalidFid', 'Could not open source file for reading.'));
    end
    throwAsCaller(MException(me.identifier, me.message));
end

% String of input arguments
if ~isempty(ceArgIn)
    % Find the index of 'varargin' in the input argument names
    idxVarargin = find(strcmp(ceArgIn, 'varargin'));
    % Reject everything after 'varargin'
    if ~isempty(idxVarargin) && numel(ceArgIn) > idxVarargin
        ceArgIn(idxVarargin+1:end) = [];
    end
end
% Join the input arguments
chArgIn = strjoin(ceArgIn, ', ');
% ceFunction_Contents = cellfun(@(x) iif(strcmp(x, '{{ARGIN}}'), chArgIn, true, x), 'Uniform', false);

% String of output arguments
if ~isempty(ceArgOut)
    % Find the index of 'varargin' in the input argument names
    idxVarargout = find(strcmp(ceArgOut, 'varargout'));
    % Reject everything after 'varargin'
    if ~isempty(idxVarargout) && numel(ceArgOut) > idxVarargout
        ceArgOut(idxVarargout+1:end) = [];
    end
end
% Join the input arguments
chArgOut = strjoin(ceArgOut, ', ');

% Description string
chDescription = sprintf('%s %s', upper(chFunction_Name), chDescription);

% Define the set of placeholders to replace here
ceReplacers = {...
    'FUNCTION', chFunction_Name; ...
    'ARGIN', chArgIn; ...
    'ARGOUT', chArgOut; ...
    'DESCRIPTION', chDescription; ...
    'AUTHOR', chAuthor; ...
    'DATE', chDate;
};
% Replace all placeholders with their respective content
for iReplace = 1:size(ceReplacers, 1)
    ceFunction_Contents = cellfun(@(str) strrep(str, sprintf('{{%s}}', ceReplacers{iReplace,1}), ceReplacers{iReplace,2}), ceFunction_Contents, 'Uniform', false);
end


% Target file path
chFunction_FullFile = fullfile(chFunction_Path, sprintf('%s%s', chFunction_Name , chFunction_Ext));
% Save the file
try
    fidTarget = fopen(chFunction_FullFile, 'w+');
    for row = 1:numel(ceFunction_Contents)
        fprintf(fidTarget, '%s\r\n', ceFunction_Contents{row,:});
    end
    fcStatus = fclose(fidTarget);
    assert(fcStatus == 0);
catch me
    if strcmp(me.identifier, 'MATLAB:FileIO:InvalidFid')
        throw(MException('PHILIPPTEMPEL:NewFunction:InvalidFid', 'Could not open target file for writing.'));
    end
    throwAsCaller(MException(me.identifier, me.message));
end



%% Assign output quantities
% Open file afterwards?
if strcmp(chOpen, 'on')
    open(chFunction_FullFile);
end


end



function out = in_charToValidArgument(in)

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