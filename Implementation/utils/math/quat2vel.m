function omega = quat2vel(q, q_dot)

omega = quat2ratem(q)*q_dot(:);

end