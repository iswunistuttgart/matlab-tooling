function skew = vec2skew(vec)%#codegen
% VEC2SKEW Turn a vector into its skew-symmetric matrix form
% 
%   VEC2SKEW(VEC) turns vec into its skew-symmetric matrix form of type
%   [0,      -vec(3),  vec(2); ...
%    vec(3),  0,      -vec(1); ...
%   -vec(2),  vec(1),  0];
%   
%   
%   Inputs:
%   
%   VEC: a vector of length 3
%
%   Outputs:
%   
%   SKEW: Skew-symmetric matrix of VEC
%



%% Input parsing
% Gotta have doubles
assert(isa(vec, 'double') || isa(vec, 'sym'), 'Input must be double or symbolic.');
% Gotta have at least three elements inside VEC
assert(numel(vec) == 3, 'Input must be only three elements long.');



%% Magic
% Create skew symmetric matrix
skew = [0,      -vec(3),    vec(2); ...
        vec(3),  0,         -vec(1); ...
        -vec(2), vec(1),    0];


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
