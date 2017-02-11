MOD = MVS_1_0_1_6_ModSpec;
% OtherIONames = {'vdb', 'vgb', 'vsb'}; % vecX
% internal_unk_names = {'vdib', 'vsib'}; % vecY
% parm_names = {'version', 'tipe', 'W', 'Lgdr', 'dLg', 'Cg',
% 'etov', 'delta', 'n0', 'Rs0', 'Rd0', 'Cif', 'Cof', 'vxo',
% 'parm_mu', 'parm_beta', 'phit', 'phib', 'parm_gamma', 'Vt0',
% 'parm_alpha', 'mc', 'CTM_select', 'CC', 'nd'}

%   Rs=1
MOD = feval(MOD.setparms,'Rs0',1, MOD);
%   Rd=1 
MOD = feval(MOD.setparms,'Rd0',1, MOD);
%TODO: change back
MOD = feval(MOD.setparms,'smoothing',1e-3, MOD);

VGBs = 0:0.1:1;
% VDBs = -1.5:0.02:1.5;
% VDBs = -0.5:0.1:1.5;
VDBs = -0.04:0.001:0.02;
ALL_OUT1s = [];
ALL_OUT2s = [];
ALL_OUT3s = [];
ALL_OUT4s = [];
for c = 1:length(VGBs)
	OUT1s = 0 * VDBs;
	OUT2s = 0 * VDBs;
	OUT3s = 0 * VDBs;
	OUT4s = 0 * VDBs;
	for d = 1:length(VDBs)
		% vdb = 1;
		vdb = VDBs(d);
		vgb = VGBs(c);
		vsb = 0;
		vdib = vdb;
		vsib = vsb;

		vecX = [vdb; vgb; vsb];
		vecY = [vdib; vsib];
		vecLim = [];
		u = [];

		dvecZdvecX = feval(MOD.dfe_dvecX, vecX, vecY, vecLim, u, MOD);
		dvecWdvecX = feval(MOD.dfi_dvecX, vecX, vecY, vecLim, u, MOD);

		OUT1s(d) = dvecWdvecX(1, 1);
		OUT2s(d) = dvecWdvecX(1, 2);
		OUT3s(d) = dvecWdvecX(2, 1);
		OUT4s(d) = dvecWdvecX(2, 2);
	end
	% plot(VDBs, OUT1s, '-k');
	% hold on;
	% plot(VDBs, OUT2s, '-.r');
	% plot(VDBs, OUT3s, '.b');
	% plot(VDBs, OUT4s, '--c');
	ALL_OUT1s = [ALL_OUT1s; OUT1s];
	ALL_OUT2s = [ALL_OUT2s; OUT2s];
	ALL_OUT3s = [ALL_OUT3s; OUT3s];
	ALL_OUT4s = [ALL_OUT4s; OUT4s];
end
figure;
surf(VDBs, VGBs, ALL_OUT1s);
xlabel('Vdisi'); ylabel('Vgsi');
figure;
surf(VDBs, VGBs, ALL_OUT2s);
xlabel('Vdisi'); ylabel('Vgsi');
figure;
surf(VDBs, VGBs, ALL_OUT3s);
xlabel('Vdisi'); ylabel('Vgsi');
figure;
surf(VDBs, VGBs, ALL_OUT4s);
xlabel('Vdisi'); ylabel('Vgsi');
