function out = R0tau(tau, T)
% stationary component of R(t,tau,T)

if (tau <= -2*T)
	out = 0;
elseif (tau<=-T)
	out = 1/(6*T^3)*(12*tau*T^2+8*T^3+6*T*tau^2+tau^3);
elseif (tau<=0)
	out = 1/(6*T^3)*(2*(2*T^3-tau^3+3*tau*T^2)-tau*(6*T^2+tau^2+6*T*tau));
elseif (tau<=T)
	out = 1/(6*T^3)*(tau*(6*T^2+tau^2-6*T*tau)+2*(2*T^3+tau^3-3*tau*T^2));
elseif (tau<=2*T)
	out = 1/(6*T^3)*(2*T-tau)^3;
else
	out = 0;
end

