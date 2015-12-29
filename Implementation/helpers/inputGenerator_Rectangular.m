function [RectangularValue, varargout] = inputGenerator_Rectangular(CurrentTime, Amplitude, Period, Offset)

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

RectangularValue = Offset;

if dEvalTime > 1/2*Period
    RectangularValue = RectangularValue + Amplitude;
end

end