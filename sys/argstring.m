function s = argstring(varargin)
% ARGSTRING truns a list of arguments into a human-readable string
%
%   ARGSTRING(A, B) turns the list of arguments into 'A_ValueOfA_B_ValueOfB'.
%
%   Outputs:
%
%   S                   Description of argument S



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-09-29
% Changelog:
%   2018-09-29
%       * Initial release



%% Do your code magic here
% Init string as cell array
s = cell(1, nargin);

% Loop over all arguments
for iArg = 1:nargin
  % Set the argument's name
  n = matlab.lang.makeValidName(inputname(iArg));
  
  % Get the argument's value
  mxVal = varargin{iArg};
  
  % Depending on the type of the variable referenced, we will write it out
  if isa(mxVal, 'numeric')
    t = num2str(mxVal);
  elseif isa(mxVal, 'char')
    t = mxVal;
  elseif isa(mxVal, 'cell')
    t = 'cell';
  elseif isa(mxVal, 'struct')
    t = 'struct';
  elseif isa(mxVal, 'function_handle')
    try
      t = func2str(mxVal);
    catch me
      t = 'FH';
    end
  else
    t = 'X';
  end
  
  % Merge name and type
  s{iArg} = [n , '_', t];
  
end

% Return the cell of arguemnts
% s = arrayfun(@(ic) sprintf('%s_%s', s{ic}, s{ic + 1}), 1:2:nargin, 'UniformOutput', false);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
