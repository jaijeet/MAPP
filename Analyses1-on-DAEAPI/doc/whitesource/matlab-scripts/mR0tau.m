function out = mR0tau(tau,T)
% vector/matrix version of R0tau

for i=1:length(tau)
	out(i) = R0tau(tau(i),T);
end
