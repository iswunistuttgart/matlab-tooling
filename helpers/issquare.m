function flag = issquare(A)

flag = ismatrix(A) && isequal(size(A, 1), size(A, 2));

end