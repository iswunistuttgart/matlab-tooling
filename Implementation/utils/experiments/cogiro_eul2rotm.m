function R = cogiro_eul2rotm(eul, varargin)

R = transpose(eul2rotm(-eul, varargin{:}));

end
