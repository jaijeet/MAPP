clear; 

cktnetlist = MVS_char_curves_ckt;
DAE = MNA_EqnEngine(cktnetlist);

% DAE = DAE.set_uQSS('Vdd:::E', 1, DAE);
% dcop = dot_op(DAE);
% dcop.print(dcop);
% qssSol = dcop.getSolution(dcop);

vgg = 1;
DAE = DAE.set_uQSS('Vgg:::E', vgg, DAE);
swp = dot_dcsweep(DAE, [], 'Vdd:::E', -0.5, 0.5, 20);
% swp.plot(swp);

[vdds, sols] = swp.getSolution(swp);

% vdb = vecX(1); vgb = vecX(2); vsb = vecX(3);
% vdib = vecY(1); vsib = vecY(2);

% obsolete: qg is qe(2,1), cgs (cgb) is dqe_dvecX(2,2)
% vecX from sols --> vecX = [vdb; vgb; vsb] = [sol(1); sol(2); 0]
% vecY from sols --> vecY = [vdib; vsib] = [sol(5); sol(6)]

% cgd = -d Qg / dVds
% DAE.unknames:  'e_drain' 'e_gate' 'Vdd:::ipn' 'Vgg:::ipn' 'NMOS:::vdib' 'NMOS:::vsib'
% DAE.eqnnames:  'KCL_drain' 'KCL_gate' 'KVL_Vdd_vpn' 'KVL_Vgg_vpn' 'NMOS:::eqn_vdib' 'NMOS:::eqn_vsib'
% Vds would be DAE's x(1)
% Qg would be DAE's q(2) or -q(2) %TODO to make sure, look at MNAEqnEngine
% cgd = -d Qg / dVds would be +or- DAE.dq_dx(2, 1)
% DAE.inputnames: 'Vdd:::E' 'Vgg:::E'
% u would be [vdd; vgg]

for c = 1:length(vdds)
	vdd = vdds(c);
	sol = sols(:,c);
	dq = feval(DAE.dq_dx, sol, DAE);
	Cgd(c, 1) = dq(2, 1);
	% Cgd(c, 1) = dq(2, 5); % d Qg d vdib
end
figure; plot(vdds, Cgd); grid on;
%{
MOD = MVS_ModSpec;
for c = 1:length(vdds)
	vdd = vdds(c);
	sol = sols(:,c);
	dqe = feval(MOD.dqe_dvecX, [sol(1); sol(2); 0], [sol(5); sol(6)], [], MOD);
	Cgs(c, 1) = dqe(2, 2);
end
%}

% swp2 = dot_dcsweep(DAE, [], 'Vdd:::E', -1, 1, 10, 'Vgg:::E', -1, 1, 10);
% swp2.plot(swp2);

%{
VGBs = 0:0.1:1;
VDBs = -0.5:0.2:1.5;

% output Ids
IDs = zeros(length(VGBs), length(VDBs));
idx = unkidx_DAEAPI('Vdd:::ipn', DAE);

for c = 1:length(VGBs)
	DAE = DAE.set_uQSS('Vgg:::E', VGBs(c), DAE);
	swp = dot_dcsweep(DAE, [], 'Vdd:::E', min(VDBs), max(VDBs), length(VDBs));
	[pts, Sols] = swp.getsolution(swp);
	IDs(c, :) = - Sols(idx, :);
end % Vgg

figure; surf(VDBs, VGBs, IDs);

% view([0, -1, 0]);
set(gcf,'color','white'); box on;
xlabel('Vd (V)','FontName','Times New Roman','FontSize',18);
ylabel('Vg (V)','FontName','Times New Roman','FontSize',18);
zlabel('Id (A)','FontName','Times New Roman','FontSize',18);
title(['I/V curves of MVS'],'FontName','Times New Roman','FontSize',18);
set(gca,'FontName','Times New Roman','FontSize',15);
%}
