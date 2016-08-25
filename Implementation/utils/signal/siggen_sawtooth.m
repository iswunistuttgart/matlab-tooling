function [SawtoothValue, varargout] = siggen_sawtooth(CurrentTime, Period, Amplitude, Offset, Algorithm)

if nargin < 2
    Period = 2*pi;
end

if nargin < 3
    Amplitude = 1;
end

if nargin < 4
    Offset = 0;
end

if nargin < 5
    Algorithm = 'simple';
end

dTimeEval = CurrentTime*pi/Period;

switch lower(Algorithm)
    case 'atan'
        SawtoothValue = Offset + Amplitude*(0.5 - 1/pi*atan(cot(dTimeEval)));
    otherwise
        SawtoothValue = Offset + Amplitude*(dTimeEval/pi - floor(dTimeEval/pi));
end

end
