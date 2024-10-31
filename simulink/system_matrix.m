function [S] = system_matrix(f, k, R1, L1, C1, R2, L2, C2)
% Returns the 2x2 matrix S that characterizes the steady-state at frequency 
% f of the system of two coupled RLC circuits where:
%         V = S * I
% 
% where I is the complex vector of the two steady-state currents in the 
% circuits and V is the complex vector of
% resulting voltages

Z1 = R1 + 2*pi*f*1i*L1 + 1/(2*pi*f*1i*C1);
Z2 = R2 + 2*pi*f*1i*L2 + 1/(2*pi*f*1i*C2);

M  = k*sqrt(L1*L2);
ZM = 2*pi*f*1i*M;

S = [Z1     ZM
     ZM     Z2];

end

