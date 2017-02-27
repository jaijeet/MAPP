function vt = sim_vt_vapp(T)
	if nargin < 1
		T = 300;
	end
	P_Q = 1.6021918e-19; % from constants.vams
	P_K = 1.3806503e-23; % from constants.vams
	vt = T * P_K / P_Q;
end % sim_vt
