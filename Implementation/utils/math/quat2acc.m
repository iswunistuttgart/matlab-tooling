function alpha = quat2acc(q, q_dot, q_ddot)

alpha = quat2trafo(q_dot)*q_dot(:) + quat2trafo(q)*q_ddot(:);

end