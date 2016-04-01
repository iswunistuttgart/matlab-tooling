function [RectangularValue, varargout] = signalGenerator_Rectangular(CurrentTime, Amplitude, Period, Offset)

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
