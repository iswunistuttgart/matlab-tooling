function cif = iif(varargin)
% IIF Allows conditionals in inline and anonymous functions
% 
%   iif = @(varargin) varargin{2 * find([varargin{1:2:end}], 1, 'first')}();

cif = varargin{2 * find([varargin{1:2:end}], 1, 'first')}();


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header
% Your contribution towards improving this function will be acknowledged in the
% "Changes" section of the header
