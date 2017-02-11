MOD = MVS_ModSpec();
% MOD = MVS_ModSpec_noabs();
% OtherIONames = {'vdb', 'vgb', 'vsb'}; % vecX
% internal_unk_names = {'vdib', 'vsib'}; % vecY
% MOD = feval(MOD.setparms,'Rs0',1e12, MOD);
% MOD = feval(MOD.setparms,'Rd0',1e12, MOD);

VGBs = 0:0.1:1;
VDBs = [-0.5:0.1:-0.1, -0.09:0.01:0.09, 0.1:0.1:1.5];
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

        dfidvecX = feval(MOD.dfi_dvecX, vecX, vecY, vecLim, u, MOD); % vdb,  vgb, vsb
        dfedvecY = feval(MOD.dfe_dvecY, vecX, vecY, vecLim, u, MOD); % vdib, vsib
        dfidvecY = feval(MOD.dfi_dvecY, vecX, vecY, vecLim, u, MOD); % vdib, vsib
		dIDSdVGBs(c, d) = dfidvecX(1, 2);
		dIDSdVDBs(c, d) = dfidvecY(1, 1) + dfedvecY(1, 1);
		% dIDSdVSBs(c, d) = dfidvecY(1, 2);
        fprintf('.');
    end
end
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
