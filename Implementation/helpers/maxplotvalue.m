function MaxValue = maxplotvalue(Axis)

if nargin == 0
    Axis = gca;
end

MaxValue = plotrange(Axis, 'max');

end