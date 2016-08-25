function [TrapezoidalValue, varargout] = siggen_trapezoid(CurrentTime, Amplitude, Period, Transition, Offset)

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

TrapezoidalValue = Offset.*ones(1, numel(CurrentTime));

TrapezoidalValue(dEvalTime >= 1/2*Period & dEvalTime < 1/2*Period + Transition) = Offset + Amplitude/Transition*(dEvalTime(dEvalTime >= 1/2*Period & dEvalTime < 1/2*Period + Transition) - 1/2*Period);

TrapezoidalValue(dEvalTime >= 1/2*Period + Transition & dEvalTime < Period - Transition) = Amplitude + Offset;

TrapezoidalValue(dEvalTime >= Period - Transition & dEvalTime < Period) = Offset + Amplitude*(1 - 1/Transition*(dEvalTime(dEvalTime >= Period - Transition & dEvalTime < Period) - (Period - Transition)));

end
