function [n] = nrows(A)

validateattributes(A, {'numeric'}, {'column'}, mfilename, 'A');

n = size(A, 1);

end
