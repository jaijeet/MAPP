function out = mRsource(t,tau,T)
% vector/matrix version of Rsource

for i=1:length(t)
	for j=1:length(tau)
		out(i,j) = Rsource(t(i),tau(j),T);
	end
end
