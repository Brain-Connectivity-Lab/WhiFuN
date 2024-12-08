function fd = fd_calc(Y)
% calculate framewise displacement
Y_diff = diff(Y);
multp = Y_diff*Y_diff';
fd = sqrt(diag(multp));
end