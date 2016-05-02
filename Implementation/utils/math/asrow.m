function Row = asrow(Vector)%#codegen

Row = reshape(Vector, 1, numel(Vector));

end