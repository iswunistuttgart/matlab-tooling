function [Inertia_O] = parallel_axis_inertia(Inertia_C, Mass, Offset)
% PARALLEL_AXIS_INERTIA determines the inertia of another point O following the
% parallel axis theorem
%
%   INERTIA_O = PARALLEL_AXIS_INERTIA(INERTIA_C, MASS, OFFSET) determines the
%   inertia matrix INERTIA_O with respect to point O given by offset OFFSET from
%   the center of gravity of the body for which the inertia is defined by
%   INERTIA_C. The rigid body's mass is given by MASS.
%
%   Inputs:
%
%   INERTIA_C       3x3 inertia matrix of the rigid body with respect to its
%                   center of gravity.
%
%   MASS            Mass of the rigid body.
%
%   OFFSET          Offset of the reference point on the rigid body with respect
%                   to the center of gravity.
%
%   Outputs:
%
%   INERTIA_O       3x3 inertia matrix with respect to point OFFSET.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-12-09
% Changelog:
%   2016-12-09
%       * Propagate rename of function `ascolumn` to `ascol`
%   2016-09-12
%       * Modify assertion because inertia matrix can be negative, too
%       * Add assertion for finite values of all values
%   2016-08-29
%       * Initial release



%% Assertion
% Inertia_C: Double. Non-negative.
assert(isa(Inertia_C, 'double'), 'PHILIPPTEMPEL:MATLAB_TOOLING:PARALLEL_AXIS_INERTIA:invalidTypeInertiaC', 'Inertia_C must be double.');
assert(all(all(~isinf(Inertia_C))), 'PHILIPPTEMPEL:MATLAB_TOOLING:PARALLEL_AXIS_INERTIA:nonNegativeInertiaC', 'Inertia_C must be finite.');

% Mass: Double. Non-negative.
assert(isa(Mass, 'double'), 'PHILIPPTEMPEL:MATLAB_TOOLING:PARALLEL_AXIS_INERTIA:invalidTypeMass', 'Mass must be double.');
assert(Mass > 0, 'PHILIPPTEMPEL:MATLAB_TOOLING:PARALLEL_AXIS_INERTIA:positiveMass', 'Mass must be positive.');
assert(~isinf(Mass), 'PHILIPPTEMPEL:MATLAB_TOOLING:PARALLEL_AXIS_INERTIA:finiteMass', 'Mass must be finite');

% Offset: Double.
assert(isa(Offset, 'double'), 'PHILIPPTEMPEL:MATLAB_TOOLING:PARALLEL_AXIS_INERTIA:invalidTypeOffset', 'Offset must be double.');
assert(all(~isinf(Offset)), 'PHILIPPTEMPEL:MATLAB_TOOLING:PARALLEL_AXIS_INERTIA:nonfiniteOffset', 'Offset must be finite.');



%% Do your code magic here

% Parallel axis theorem: $I_{O} = I_{C} + m \cdot \tilde{a}^{\intercal}$
Inertia_O = Inertia_C + Mass.*transpose(vec2skew(asrow(Offset)))*vec2skew(asrow(Offset));
% Inertia_O = Inertia_C + Mass.*(asrow(Offset)*ascol(Offset)*eye(3) - ascol(Offset)*asrow(Offset));


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
