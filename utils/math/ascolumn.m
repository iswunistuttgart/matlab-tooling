function Column = ascolumn(Vector)%#codegen
% ASCOLUMN ensures the vector is a column vector
% 
%   COLUMN = ASROW(VECTOR) Turns vector into a definite column form.
%
% 
%   Inputs:
% 
%   VECTOR: A random Nx1 or 1xN vector of length N
% 
%   Outputs:
% 
%   COLUMN: Column vector of size Nx1
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-05-10
% Changelog:
%   2016-05-10
%       * Add check with iscolumn so we do not loose too much time in case we
%       are already dealing with a column vector
%       * Add section `File Information`
%       * Add help section
%   2016-05-02
%       * Initial release



%% Reshaping
% If it is not already a row vector ...
if ~iscolumn(Vector)
    % ... reshape it such that it will be a column vector
    Column = reshape(Vector, numel(Vector), 1);
% It is already a column ...
else
    % ... so leave it as is
    Column = Vector;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
