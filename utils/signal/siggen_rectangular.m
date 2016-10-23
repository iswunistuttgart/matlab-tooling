function [RectangularValue, varargout] = siggen_rectangular(CurrentTime, Amplitude, Period, Offset)
% SIGGEN_RECTANGULAR generates a rectangular signal
%
%   SIG = SIGEN_RECTANGULAR() generates a rectangular signal over time
%   t = [0, 1] with amplitude 1 and rising edge at t = 0.5.
%
%   SIG = SIGEN_RECTANGULAR(TIME) generates a rectangular signal over
%   time TIME with amplitude 1 and rising edge at t = TIME/2.
%
%   SIG = SIGEN_RECTANGULAR(TIME, 'Name', 'Value') generates a
%   rectangular signal signal with optional parameters specified as name-value
%   pairs.
%
%   Inputs:
%
%   TIME    Time at which to evaluate
%
%   Optional Inputs -- specified as parameter value pairs
%
%   Offset

if nargin < 2
    Amplitude = 1;
end

if nargin < 3
    Period = 2*pi;
end

if nargin < 4
    Offset = 0;
end

dEvalTime = rem(CurrentTime, Period);

RectangularValue = Offset.*ones(1, numel(CurrentTime));

RectangularValue(dEvalTime >= 1/2*Period) = Amplitude + Offset;

end
