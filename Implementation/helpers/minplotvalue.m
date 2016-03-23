function MinValue = minplotvalue(Axis)

if nargin == 0
    Axis = gca;
end

MinValue = plotrange(Axis, 'min');

end