function omega = quat2vel(q, q_dot)

omega = quat2trafo(q)*q_dot(:);

end