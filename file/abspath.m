function AF = abspath(varargin)
% ABSPATH returns an absolute file path for the given arguments
%
%   ABSPATH(FOLDERNAME1, FOLDERNAME2, ..., FILENAME) works much like FULLFILE
%   except it returns an fully qualified absolute file path.
%
%   Outputs:
%
%   AF                  Absolute file path(s).
%
%   See also:
%       FULLFILE



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-05-02
% Changelog:
%   2018-05-02
%       * Initial release



%% Do your code magic here

% First, call MATLAB's fullfile function to get the arguments sorted out
% correctly
F = fullfile(varargin{:});

% If F is a cell, then the user requested multiple paths to be translated
if isa(F, 'cell')
    % So turn all entries of F into absolute paths
    AF = cellfun(@make_absolute, F, 'UniformOutput', false);
% A single path needs to be converted
else
    % So convert that single path
    AF = make_absolute(F);
end


end


function f = make_absolute(f)
%% MAKE_ABSOLUTE turns the relative path F into an absolute path F
%
%   F = MAKE_ABSOLUTE(F) makes sure that path F is absolute. If it isn't
%   absolute, it will be preceeded by the current working directory PWD.
%
%   Inputs:
%
%   F                   Char of a file/folder path
%
%   Outputs:
%
%   F                   Absolute path to F.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-05-02
% Changelog:
%   2018-05-02
%       * Initial release



%% Convert
% Get a java file object
F = java.io.File(f);

% If the path isn't already absolute, we need to prepend the current working
% directory
if ~F.isAbsolute()
    f = java.io.File(fullfile(pwd, f)).getCanonicalPath();
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
