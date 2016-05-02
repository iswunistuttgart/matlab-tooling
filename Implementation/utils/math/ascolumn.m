function Column = ascolumn(Vector)%#codegen

Column = reshape(Vector, numel(Vector), 1);

end