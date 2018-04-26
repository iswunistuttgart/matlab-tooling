function [TF, ID] = isfunction(fcn)
% ISFUNCTION - true for valid matlab functions
%
%   TF = ISFUNCTION(FUN) returns 1 if FUN is a valid matlab function, and 0
%   otherwise. Matlab functions can be strings or function handles.
%
%   [TF, ID] = ISFUNCTION(FUN) also returns an identier ID. ID can take the
%   following values:
%      1  : FUN is a function string
%      2  : FUN is a function handle
%      0  : FUN is not a function, but no further specification
%     -1  : FUN is script
%     -2  : FUN is not a valid function m-file (e.g., a matfile)
%     -3  : FUN does not exist (as a function)
%     -4  : FUN is not a function but something else (a variable)
%
%   FUN can also be a cell array, TF and ID will then be arrays.
%
%   Examples:
%     tf = isfunction('lookfor') 
%        % tf = 1
%     [tf, id] = isfunction({@isfunction, 'sin','qrqtwrxxy',1:4, @clown.jpg})
%        % -> tf = [ 1  1  0  0  0 ]
%        %    id = [ 2  1 -2 -4 -3 ]
%
%   See also FUNCTION, SCRIPT, EXIST, ISA, WHICH, NARGIN, FUNCTION_HANDLE



%% File information
% Author: Jos van der Geest <jos@jasen.nl>
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Url: http://mathworks.com/matlabcentral/fileexchange/45778-isfunction
% Date: 2016-12-12
% Changelog:
%   2016-12-12
%       * Initial release



%% Do your code magic here
% We use cellfun, so convert to cells
if ~iscell(fcn)
    fcn = {fcn};
end

% Get the identifier for each "function"
ID = cellfun(@local_isfunction,fcn) ;
% Valid matlab functions have a positive identifier
TF = ID > 0;


end


function ID = local_isfunction(fcnname)

try
    % nargin errors when FUNNAME is not a function
    nargin(fcnname);
    % 1 for m-file, 2 for handle
    ID = 1  + isa(fcnname, 'function_handle') ;
catch ME
    % catch the error of nargin
    switch ME.identifier
        % Script
        case 'MATLAB:nargin:isScript'
            ID = -1 ;
        % Probably another type of file, or it does not exist
        case 'MATLAB:narginout:notValidMfile'
            ID = -2 ;
        % Probably a handle, but not to a function
        case 'MATLAB:narginout:functionDoesnotExist'
            ID = -3 ;
        % Probably a variable or an array
        case 'MATLAB:narginout:BadInput'
            ID = -4 ;
        % Unknown cause for error
        otherwise
            ID = 0 ;
    end
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
