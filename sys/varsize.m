function varargout = varsize(varargin)
% VARSIZE determines the size of each variable given
%
%   VARSIZE(X) prints the size of variable X to the screen
%
%   VARSIZE(X, Y) prints the size of variables X and Y to the screen
%
%   S = VARSIZE(...) returns the size of all variables in bytes in struct S.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-02-06
% Changelog:
%   2018-02-06
%       * Initial release



%% Validate arguments
try
    % VARSIZE(X)
    % VARSIZE(X, ...)
    narginchk(1, Inf);
    
    % VARSIZE(...)
    % S = VARSIZE(...)
    nargoutchk(0, 1);
    
catch me
    throwAsCaller(me);
end



%% Do your code magic here
% Store the names of the variables passed to this function in here
ceVarnames = cell(1, nargin);

% Get the original variable names passed to this function
for iArg = 1:nargin
    if ~isa(varargin{iArg}, 'char')
        ceVarnames{iArg} = inputname(iArg);
    else
        ceVarnames{iArg} = varargin{iArg};
    end
end

% Get all variables in the caller's workspace
stWho = evalin('caller', 'whos();');

% Get info of only the variables that were passed to this function
stWho(~ismember({stWho.name}, ceVarnames)) = [];

% Clean the structure
stWho = rmfield(stWho, 'class');
stWho = rmfield(stWho, 'complex');
stWho = rmfield(stWho, 'global');
stWho = rmfield(stWho, 'persistent');
stWho = rmfield(stWho, 'sparse');
stWho = rmfield(stWho, 'size');
stWho = rmfield(stWho, 'nesting');

% Convert bytes to respective byte sizes
ceBytes = bytes2str([stWho.bytes]);
[stWho.bytes] = deal(ceBytes{:});



%% Assign output quantities
% No output, display the data
if nargout == 0
    display(struct2table(stWho))
end

% One output: return the structure
if nargout > 0
    varargout{1} = stWho;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
