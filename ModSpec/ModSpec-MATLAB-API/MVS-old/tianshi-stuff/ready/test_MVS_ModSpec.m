function out = test_MVS_ModSpec()
    MOD = MVS_ModSpec();

	S = ee_model_parm2struct(MOD);

	VGBs = 0:0.1:1;
	VDBs = -0.5:0.02:1.5;

	% output Ids
	IDSs = zeros(length(VGBs), length(VDBs));

	for c = 1:length(VGBs)
		for d = 1:length(VDBs)
			S.vdb = VDBs(d);
			S.vgb = VGBs(c);
			S.vsb = 0;

			S.vdib = VDBs(d);  
			S.vsib = 0;

			fiout = MOD.fi_of_S(S);
			IDSs(c, d) = fiout(1); % Idisi
			fprintf('.');
		end
	end

	figure; surf(VDBs, VGBs, IDSs);

	% view([0, -1, 0]);
	set(gcf,'color','white'); box on;
	xlabel('Vd (V)','FontName','Times New Roman','FontSize',18);
	ylabel('Vg (V)','FontName','Times New Roman','FontSize',18);
	zlabel('Id (A)','FontName','Times New Roman','FontSize',18);
	title(['I/V curves of MVS'],'FontName','Times New Roman','FontSize',18);
	set(gca,'FontName','Times New Roman','FontSize',15);
end
