function alpha = quat2acc(q, q_dot, q_ddot)

alpha = quat2ratem(q_dot)*q_dot(:) + quat2ratem(q)*q_ddot(:);

end