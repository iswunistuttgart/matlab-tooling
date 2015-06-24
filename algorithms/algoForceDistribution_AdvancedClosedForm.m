function [Distribution, varargout] = algoForceDistribution_AdvancedClosedForm(Wrench, StructureMatrix, ForceMinimum, ForceMaximum)
% ALGOFORCEDISTRIBUTION_ADVANCEDCLOSEDFORM - Determine the force distribution
%   for the given robot using the closed-form force distribution algorithm
% 
%   DISTRIBUTION = ALGOFORCEDISTRIBUTION_ADVANCEDCLOSEDFORM(WRENCH,
%   STRUCTUREMATRIX, FORCEMINIMU, FORCEMAXIMUM) calculates the closed-form force
%   distribution for the given wrench and the pre-calculated structure matrix
%   
%   Inputs:
%   
%   WRENCH: Column-vector of the wrench on the system. Preferably should be a
%   6x1 vector, but if you know what you are doing, it might work with other
%   dimensions, too. Generally, 6x1 vectors will work fine, too, as long as you
%   adjust it properly to your cable robot design
%   
%   STRUCTUREMATRIX: The structure matrix At, which must be calculated
%   beforehand, for which to determine the closed-form force distribution as
%   given by A. Pott.
%   
%   FORCEMINIMUM: Minimum force as required for the algorithm to work. Must
%   be either a scalar which is then being translated as the minimum for all
%   cables, or a column vector that has the same number of rows as
%   STRUCTUREMATRIX has columns
%   
%   FORCEMAXIMUM: Maximum force as required for the algorithm to work. Must
%   be either a scalar which is then being translated as the minimum for all
%   cables, or a column vector that has the same number of rows as
%   STRUCTUREMATRIX has columns
% 
%   Outputs:
% 
%   DISTRIBUTION: Vector of force distribution values as determined by the
%   algorithm
%
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-06-12
% Changelog:
%   2015-06-12:
%       * Make sure that vForce{Max,Min}imum are column vectors
%       * Fix typos in comments and variable names
%       * Finally write method help documentation
%   2015-04-22:
%       * Initial release


%% Assert and parse variables
% Wrench
vWrench = Wrench;
% Structure matrix to determine force distribution for
aStructureMatrixAt = StructureMatrix;
% Number of cables (is being used quite often in the following code)
nNumberOfWires = size(aStructureMatrixAt, 2);

% Force minimum, can be given a scalar or a vector
if isscalar(ForceMinimum)
    vForceMinimum = ForceMinimum.*ones(nNumberOfWires, 1);
else
    vForceMinimum = reshape(ForceMinimum, nNumberOfWires, 1);
end
% Force maximum, can be given a scalar or a vector
if isscalar(ForceMaximum)
    vForceMaximum = ForceMaximum.*ones(nNumberOfWires, 1);
else
    vForceMaximum = reshape(ForceMaximum, nNumberOfWires, 1);
end
% Vector of mean force values
vForceMean = 0.5.*(vForceMinimum + vForceMaximum);

% Initialize the force distribution holding vector
vForceDistribution = zeros(1, nNumberOfWires);



%% Do the magic
% Simple case where the number of wires matches the number of degrees of
% freedom, we can just solve the linear equation system At*f = -w;
if issquare(aStructureMatrixAt)
    vForceDistribution = aStructureMatrixAt\(-vWrench);
% Non standard case, where we have more cables than degrees of freedom
else
    % Solve A^t f_v & = - ( w + A^t f_m )
    % Determine the pseudo inverse of A^t
    aStructureMatrixPseudeoInverse = transpose(aStructureMatrixAt)/(aStructureMatrixAt*transpose(aStructureMatrixAt));
    % And determine the force distribution
    vForceDistribution = vForceMean - aStructureMatrixPseudeoInverse*(vWrench + aStructureMatrixAt*vForceMean);
    
    % Keeps the index of the violated force value
    iViolationIndex = 0;
    % Violation of min = -1 or max = 1 force
    iViolationType = 0;
    % Keeps the violated amount
    dViolationAmount = 0;
    for iUnit = 1:nNumberOfWires
        if vForceDistribution(iUnit) < vForceMinimum(iUnit)
            iViolationIndex = iUnit;
            iViolationType = -1;
            dViolationAmount = max(dViolationAmount, vForceMinimum(iUnit) - vForceDistribution(iUnit));
        elseif vForceDistribution(iUnit) > vForceMaximum(iUnit)
            iViolationIndex = iUnit;
            iViolationType = 1;
            dViolationAmount = max(dViolationAmount, vForceDistribution(iUnit) - vForceMaximum(iUnit));
        end
    end
    
    % Found a violation of forces?
    if iViolationIndex > 0
        % Get reduced maximum and minimum forces
        vReducedForceMinimum = zeros(nNumberOfWires - 1, 1);
        vReducedForceMaximum = zeros(nNumberOfWires - 1, 1);
        % Get reduced structure matrix
        aReducedStructureMatrixAt = zeros(size(aStructureMatrixAt, 1), size(aStructureMatrixAt, 2) - 1);
        
        iReducedUnit = 1;
        % Loop over all cables
        for iUnit = 1:nNumberOfWires
            % Skip the limits violating cable
            if iUnit == iViolationIndex
                continue
            end
            
            % Reduce the minimum and maximum cable forces
            vReducedForceMinimum(iReducedUnit) = vForceMinimum(iUnit);
            vReducedForceMaximum(iReducedUnit) = vForceMaximum(iUnit);
            % And also reduce the structure matrix omitting the violated
            % cable's column
            aReducedStructureMatrixAt(:,iReducedUnit) = aStructureMatrixAt(:,iUnit);
            
            % Counter so we know what our 
            iReducedUnit = iReducedUnit + 1;
        end
        
        % Copy the original wrench so we can alter it to the "reduced"
        % wrench
        vReducedWrench = vWrench;
        % Modify external wrench by the violated force, either the maximum
        if iViolationType == 1
            vReducedWrench = vReducedWrench + aStructureMatrixAt(:,iViolationIndex)*vForceMaximum(iUnit);
        % or minimum force
        else
            vReducedWrench = vReducedWrench + aStructureMatrixAt(:,iViolationIndex)*vForceMinimum(iUnit);
        end
        
        % Recursively call the algorithm for advanced closed form, yet this
        % time with the reduced values
        vReducedForceDistribution = algoForceDistribution_AdvancedClosedForm(vReducedWrench, aReducedStructureMatrixAt, vReducedForceMinimum, vReducedForceMaximum);
        
        % Restore initial cable force distribution from the reduced cable
        % forces as well as the violated cable force
        iReducedUnit = 1;
        for iUnit = 1:nNumberOfWires
            % Violated unit?
            if iUnit == iViolationIndex
                % Then take its maximum force if the maximum was violated
                if iViolationType == 1
                    vForceDistribution(iUnit) = vForceMaximum(iUnit);
                % or the minimum force, if the minimum was violated
                else
                    vForceDistribution(iUnit) = vForceMinimum(iUnit);
                end
                
                continue;
            end
            
            % Not the violated unit so we can just take the reduced force
            % distribution's value
            vForceDistribution(iReducedUnit) = vReducedForceDistribution(iUnit);
            iReducedUnit = iReducedUnit + 1;
        end
    end
end



%% Create output quantities
Distribution = vForceDistribution;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
