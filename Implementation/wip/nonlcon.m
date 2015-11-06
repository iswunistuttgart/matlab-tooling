function [c, ceq] = nonlcon(vX, aAnchorPositionsInC, dE, dA0, dRho, dG, dFmin, dFmax)

% Nonlinear inequality constraints are
% f_max
% f_min
dRowsCEq = size(aAnchorPositionsInC, 2)*2;
dColsCEq = numel(vX);

% Nonlinear equality constraints are
% x_{end, i}
% z_{end, i}
dRowsC = size(aAnchorPositionsInC, 2)*2;
dColsC = numel(vX);


c = zeros(dRowsC, dColsC);
ceq = zeros(dRowsCEq, dColsCEq);

vForcesX = vX(1:3:end);
vForcesZ = vX(2:3:end);
vLength = vX(3:3:end);



% Set the equality constraints
for iCable = 1:size(aAnchorPositionsInC, 2)
    dOffset = (iCable-1)*2;
    % Position x
    ceq(iCable + 0 + dOffset) = vForcesX(iCable)*vLength(iCable)/(dE*dA0) ...
        + abs(vForcesX(iCable))/(dRho*dG)*(asinh(vForcesZ(iCable)/vForcesX(iCable)) - asinh((vForcesZ(iCable) - dRho*dG*vLength(iCable))/vForcesX(iCable))) ...
        - aAnchorPositionsInC(1, iCable);
    % Position z
    ceq(iCable + 1 + dOffset) = vForcesZ(iCable)*vLength(iCable)/(dE*dA0) ...
        - dRho*dG*vLength(iCable)^2/(2*dE*dA0) ...
        + 1/(dRho*dG)*(sqrt(vForcesX(iCable)^2 + vForcesZ(iCable)^2) - sqrt(vForcesX(iCable)^2 + (vForcesZ(iCable) - dRho*dG*vLength(iCable))^2)) ...
        - aAnchorPositionsInC(3, iCable);
end

% Set the inequality constraints
for iCable = 1:size(aAnchorPositionsInC, 2)
    dOffset = (iCable-1)*2;
    % Max force
    c(iCable + 0 + dOffset) = sqrt(vForcesX(iCable)^2 + vForcesZ(iCable)^2) - dFmax;
    % Min force
    c(iCable + 1 + dOffset) = dFmin - sqrt(vForcesX(iCable)^2 + vForcesZ(iCable)^2);
end

end