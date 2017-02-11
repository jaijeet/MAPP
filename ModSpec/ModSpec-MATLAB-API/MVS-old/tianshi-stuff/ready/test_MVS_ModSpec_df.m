clear; 

MOD = MVS_ModSpec();
% MOD = MVS_ModSpec_20140415();
%{
	optim_params_45=dlmread('coeff_op_final_45nm.txt');

	%% UNCOMMENT appropriate file from the following two lines
	%optim_params = optim_params_32; % change to optim_params_45 for 45 nm
	optim_params = optim_params_45; % change to optim_params_45 for 45 nm

	Rs0=optim_params(1);     % *** Access resistance for terminal "x" [ohm-micron] (Typically Rs)  
	Rd0=optim_params(1);     % *** Access resistance for terminal "y" (Typically assume Rs=Rd)
	delta=optim_params(3);   % *** DIBL [V/V] 
	n0 = optim_params(4);    % *** subthreshold swing factor [unit-less]
	nd=optim_params(5);      % *** Factor allowing for modest punchthrough.  
							 % *** Normally, nd=0.  If some punchtrhough 0<nd<0.4

	vxo = optim_params(6);   % *** Virtual source velocity [cm/s]    
	mu = optim_params(7);    % *** Mobility [cm^2/V.s]
	Vt0 = optim_params(8);   % Threshold voltage [V]

	%'version'    'Type'    'W'    'Lgdr'    'dLg'    'Cg'    'etov'    'delta'
 	%'n0'    'Rs0'    'Rd0' 'Cif'    'Cof'    'vxo'    'Mu'    'Beta'    'Tjun'
 	%'phib'    'Gamma'    'Vt0'    'Alpha'    'mc' 'CTM_select'    'CC'    'nd'

	MOD = MOD.setparms('Rs0', Rs0, MOD);
	MOD = MOD.setparms('Rd0', Rd0, MOD);
	MOD = MOD.setparms('delta', delta, MOD);
	MOD = MOD.setparms('n0', n0, MOD);
	MOD = MOD.setparms('nd', nd, MOD);
	MOD = MOD.setparms('vxo', vxo, MOD);
	MOD = MOD.setparms('Mu', mu, MOD);
	MOD = MOD.setparms('Vt0', Vt0, MOD);
%}

% MOD = MVS_ModSpec_noabs();
% OtherIONames = {'vdb', 'vgb', 'vsb'}; % vecX
% internal_unk_names = {'vdib', 'vsib'}; % vecY
% MOD = feval(MOD.setparms,'Rs0',1e12, MOD);
% MOD = feval(MOD.setparms,'Rd0',1e12, MOD);

VGBs = 0:0.1:1;
% VDBs = [-0.5:0.1:-0.1, -0.09:-0.01:-0.01, -0.009:0.001:0.009, 0.01:0.01:0.09, 0.1:0.1:0.5];
VDBs = [-0.5:0.1:-0.1, -0.09:0.01:0.09, 0.1:0.1:0.5];
dIDSdVGBs = zeros(length(VGBs), length(VDBs));
dIDSdVDBs = zeros(length(VGBs), length(VDBs));
for c = 1:length(VGBs)
    for d = 1:length(VDBs)
        % vdb = 1;
        vdb = VDBs(d);
        vgb = VGBs(c);
        vsb = 0;
        vdib = VDBs(d);
        vsib = 0;

        vecX = [vdb; vgb; vsb];
        vecY = [vdib; vsib];
        vecLim = [];
        u = [];

		%{
        dfidvecX = feval(MOD.dfi_dvecX, vecX, vecY, vecLim, u, MOD); % vdb,  vgb, vsb
        dfedvecY = feval(MOD.dfe_dvecY, vecX, vecY, vecLim, u, MOD); % vdib, vsib
        dfidvecY = feval(MOD.dfi_dvecY, vecX, vecY, vecLim, u, MOD); % vdib, vsib
        dqedvecX = feval(MOD.dqe_dvecX, vecX, vecY, vecLim, MOD); % vdb,  vgb, vsb
		dIDSdVGBs(c, d) = dfidvecX(1, 2);
		dIDSdVDBs(c, d) = dfidvecY(1, 1) + dfedvecY(1, 1);
		dQGBdVGBs(c, d) = dqedvecX(2, 2);
		%}

        dqedvecY = feval(MOD.dqe_dvecY, vecX, vecY, vecLim, MOD); % vdib, vsib
		dQGBdVDIBs(c, d) = dqedvecY(2, 1) - dqedvecY(2, 2);
        fprintf('.');
    end
end
%{
figure; surf(VDBs, VGBs, dIDSdVDBs);
set(gcf,'color','white'); box on;
xlabel('Vd (V)','FontName','Times New Roman','FontSize',18);
ylabel('Vg (V)','FontName','Times New Roman','FontSize',18);
zlabel('Id (A)','FontName','Times New Roman','FontSize',18);
title(['dId dVd curves of MVS'],'FontName','Times New Roman','FontSize',18);
set(gca,'FontName','Times New Roman','FontSize',15);

figure; surf(VDBs, VGBs, dIDSdVGBs);
set(gcf,'color','white'); box on;
xlabel('Vd (V)','FontName','Times New Roman','FontSize',18);
ylabel('Vg (V)','FontName','Times New Roman','FontSize',18);
zlabel('Id (A)','FontName','Times New Roman','FontSize',18);
title(['dId dVg curves of MVS'],'FontName','Times New Roman','FontSize',18);
set(gca,'FontName','Times New Roman','FontSize',15);

figure; surf(VDBs, VGBs, dQGBdVGBs);
set(gcf,'color','white'); box on;
xlabel('Vd (V)','FontName','Times New Roman','FontSize',18);
ylabel('Vg (V)','FontName','Times New Roman','FontSize',18);
zlabel('dQg dVg','FontName','Times New Roman','FontSize',18);
title(['dQg dVg curves of MVS'],'FontName','Times New Roman','FontSize',18);
set(gca,'FontName','Times New Roman','FontSize',15);
%}

figure; surf(VDBs, VGBs, dQGBdVDIBs);
set(gcf,'color','white'); box on;
xlabel('Vd (V)','FontName','Times New Roman','FontSize',18);
ylabel('Vg (V)','FontName','Times New Roman','FontSize',18);
zlabel('dQg dVdi','FontName','Times New Roman','FontSize',18);
title(['dQg dVdi curves of MVS'],'FontName','Times New Roman','FontSize',18);
set(gca,'FontName','Times New Roman','FontSize',15);
