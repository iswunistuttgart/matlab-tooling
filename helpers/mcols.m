function [m] = mcols(A)

validateattributes(A, {'numeric'}, {'row'}, mfilename, 'A');

m = size(A, 2);

end
