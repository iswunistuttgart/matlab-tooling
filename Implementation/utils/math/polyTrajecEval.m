function Eval = polyTrajecEval(TimeCurrent, SystemOrder, TimeEnd, EndPosition, StartPosition)

% Default system order is 1 []
if nargin < 2
    SystemOrder = 1;
end

% Default transition time is 1 [s]
if nargin < 3
    TimeEnd = 1;
end

% Default end position is 1 []
if nargin < 4
    EndPosition = 1;
end

% Default start position is 0 []
if nargin < 5
    StartPosition = 0;
end

% Get all coefficients from a_0 to a_{2n+1} 
coeffs = polyTrajecCoeffs(SystemOrder);

% Create the power series from 0 to 2n+1
PowerSeries = 0:1:(2*SystemOrder + 1);

% Calculate the time vector as a function of (t/T)^i with i = 1..2n+1
TimeVector = transpose(cell2mat(transpose(arrayfun(@(ti) (ti./TimeEnd).^PowerSeries, TimeCurrent, 'UniformOutput', false))));

% Calculate delta z
DeltaPosition = EndPosition - StartPosition;

% Calculate the span of the delta position
DeltaPosition = cell2mat(transpose(arrayfun(@(zi) zi.*(coeffs*TimeVector), DeltaPosition, 'UniformOutput', false)));

% And evaluate the trajectory for every start position given
Eval = transpose(cell2mat(transpose(arrayfun(@(zi) StartPosition(zi) + DeltaPosition(zi,:), 1:numel(StartPosition), 'UniformOutput', false))));

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
