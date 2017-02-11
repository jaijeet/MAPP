function out=S0(omega, T)
% stationary PSD of Rttau

out = -(8*cos(T*omega)-2*cos(2*T*omega)-6)./omega.^4/T^3;
