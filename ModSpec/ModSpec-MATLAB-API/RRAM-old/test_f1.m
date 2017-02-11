% This script plots the f1 function of RRAM_v0_all with different f1_switch
% values. Then I can adjust default parameters to make them more consistent.

Vs = -1.1:0.02:1.1;
ss = [0, 0.5, 1];

for c = 1:5
	MOD = RRAM_v0_all(c, 6);
	MEO = model_exerciser(MOD);
	for d = 1:length(ss)
		Is = MEO.ipn_fe(Vs, ss(d), MEO);
		figure(d); plot(Vs, Is); hold on;
	end % d
end % c
for d = 1:length(ss)
	figure(d); grid on; box on; 
	title(sprintf('s=%g', ss(d)));
	xlabel('vpn');
	ylabel('ipn');
	legend('f1\_switch=1', 'f1\_switch=2', 'f1\_switch=3', ...
	    'f1\_switch=4', 'f1\_switch=5');
end % d
