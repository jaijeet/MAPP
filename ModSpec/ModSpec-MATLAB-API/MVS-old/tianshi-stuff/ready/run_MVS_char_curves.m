cktnetlist = MVS_char_curves_ckt;

DAE = MNA_EqnEngine(cktnetlist);

DAE = DAE.set_uQSS('Vdd:::E', 1, DAE);

dcop = dot_op(DAE);
dcop.print(dcop);
qssSol = dcop.getSolution(dcop);

 
swp = dot_dcsweep(DAE, [], 'Vdd:::E', -1, 1, 20);
swp.plot(swp);

% swp2 = dot_dcsweep(DAE, [], 'Vdd:::E', -1, 1, 10, 'Vgg:::E', -1, 1, 10);
% swp2.plot(swp2);

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
