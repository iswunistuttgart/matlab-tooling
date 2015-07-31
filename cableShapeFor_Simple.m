function [L, varargout] = cableShapeFor_Simple(vEnd)

nDiscretizationPoints = 10e3;

vEnd = vEnd(:);

dLength = sqrt(sum(vEnd.^2));

vShape = zeros(2, nDiscretizationPoints);
vLinspaceLength = linspace(0, dLength, nDiscretizationPoints);
vAngleCableWithZ = atan2(vEnd(2), vEnd(1));
vShape(1, :) = cos(vAngleCableWithZ).*vLinspaceLength;
vShape(2, :) = sin(vAngleCableWithZ).*vLinspaceLength;

L = dLength;

if nargout > 1
    varargout{1} = vShape;
end

end