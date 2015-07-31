function [L, varargout] = cableShapeFor_Pulley(vEnd, dPulleyRadius)

nDiscretizationPoints = 10e3;

vP2B = vEnd(:);

vP2M = dPulleyRadius.*[1; 0];

vM2B = vP2B - vP2M;

dCableLengthCtoB = sqrt( norm(vM2B).^2 + dPulleyRadius.^2 );


dBeta1 = atan2(vM2B(2), vM2B(1));
dBeta2 = atan2(dCableLengthCtoB, dPulleyRadius);

dBeta3 = dBeta1 + dBeta2;

vM2C = dPulleyRadius.*[cos(dBeta3); sin(dBeta3)];

dBeta = acos(dot(-vP2M, vM2C)/(norm(vP2M)*norm(vM2C)));

dCableLengthPtoC = dBeta*dPulleyRadius;

dCableLengthTotal = dCableLengthCtoB + dCableLengthPtoC;
L = dCableLengthTotal;

if nargout > 1
    aCableShape = zeros(2, nDiscretizationPoints);
    
    dRatioPulleyToTotal = dCableLengthPtoC/dCableLengthTotal;
    dRatioWorkspaceToTotal = dCableLengthCtoB/dCableLengthTotal;
    nDiscretizationPointsOnPulley = round(dRatioPulleyToTotal*nDiscretizationPoints);
    nDiscretizationPointsInWorkspace = round(dRatioWorkspaceToTotal*nDiscretizationPoints);
    
    vLinspaceOfCableOnPulley = linspace(0, dBeta, nDiscretizationPointsOnPulley);
    % and the part in the workspace
    vLinspaceOfCableInWorkspace = linspace(dCableLengthPtoC, dCableLengthCtoB, nDiscretizationPointsInWorkspace + 1);
    
    vC2B = vP2B - ([0; 0] + vP2M + vM2C);
    vAc2B_in_C_normed = vC2B./norm(vC2B);
    
    % The shape of the cable on the pulley can be easily inferred from a
    % parametrization of a circle shifted along the x-axis by the radius of
    % the pulley
    aCableShape(:, 1:nDiscretizationPointsOnPulley) = dPulleyRadius.*[(1 - cos(vLinspaceOfCableOnPulley)); sin(vLinspaceOfCableOnPulley)];

    % The shape of the cable in the workspace is as easy as stretching the
    % normalized vector from A_c,i to B_i but offsetting it with the final
    % position on the pulley
    aCableShape(1, nDiscretizationPointsOnPulley:end) = dPulleyRadius.*(1-cos(dBeta)) + vAc2B_in_C_normed(1).*vLinspaceOfCableInWorkspace;
    aCableShape(2, nDiscretizationPointsOnPulley:end) = dPulleyRadius.*(sin(dBeta)) +  vAc2B_in_C_normed(2).*vLinspaceOfCableInWorkspace;
    
    varargout{1} = aCableShape;
end

end