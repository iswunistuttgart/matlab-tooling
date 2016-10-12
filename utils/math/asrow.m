function Row = asrow(Vector)%#codegen
% ASROW ensures the vector is a row vector
% 
%   ROW = ASROW(VECTOR) Turns vector into a definite row form.
%
% 
%   Inputs:
% 
%   VECTOR: A random Nx1 or 1xN vector of length N
% 
%   Outputs:
% 
%   ROW: Row vector of size 1xN
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-05-10
% Changelog:
%   2016-05-10
%       * Add check with isrow so we do not loose too much time in case we are
%       already already dealing with a row vector
%       * Add section `File Information`
%       * Add help section
%   2016-05-02
%       * Initial release



%% Reshaping
% If it is not already a row vector ...
if ~isrow(Vector)
    % ... reshape it such that it will be a row vector
    Row = reshape(Vector, 1, numel(Vector));
% It is already a row ...
else
    % ... so leave it as is
    Row = Vector;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
