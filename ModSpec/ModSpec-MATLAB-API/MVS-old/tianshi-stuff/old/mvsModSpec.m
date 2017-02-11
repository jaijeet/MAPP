function MOD = mvsModSpec()

   MOD = ee_model();

   MOD = add_to_ee_model (MOD, 'terminals', {'d', 'g', 's', 'b'});
   MOD = add_to_ee_model (MOD, 'explicit_outs', {'igb', 'idb', 'isb'});
   MOD = add_to_ee_model (MOD, 'parms', ...
	   {'version', 1.00, ...
	   'tipe', 1, ...
	   'W', 1e-4, ...
	   'Lgdr', 80e-7, ...
	   'dLg', 10.5e-7, ...
	   'Cg', 2.2e-6, ...
	   'etov', 1.3e-3, ...
	   'delta', 0.10, ...
	   'n0', 1.5, ...
	   'Rs0', 100, ...
	   'Rd0', 100, ...
	   'Cif', 1e-12, ...
	   'Cof', 2e-13, ...
	   'vxo', 0.765e7, ...
	   'parm_mu', 200, ...
	   'parm_beta', 1.7, ...
	   'phit', 0.0256, ...
	   'phib', 1.2, ...
	   'parm_gamma', 0.0, ...
	   'Vt0', 0.486, ...
	   'parm_alpha', 3.5, ...
	   'mc', 0.2, ...
	   'CTM_select', 1, ...
	   'CC', 0, ...
	   'nd', 0});
   MOD = add_to_ee_model(MOD, 'fe', @fe);
   MOD = add_to_ee_model(MOD, 'qe', @qe);
   MOD = finish_ee_model(MOD);

end

function out = fe(S)
    v2struct(S);

	% version, tipe, W, Lgdr, dLg, Cg, etov, delta, n0, Rs0, Rd0, Cif, Cof,
	% vxo, mu, beta, phit, phib, gamma, Vt0, alpha, mc, CTM_select, CC, nd

    % vgb, vdb, vsb

	global input_parms
	input_parms =[tipe;W;Lgdr;dLg;parm_gamma;phib;Cg;Cif;Cof;etov;mc;phit;parm_beta;parm_alpha;CTM_select]; % set of input parameters
	coeff=[Rs0; Rd0; delta; n0; nd; vxo; parm_mu;Vt0];
		Vb = 0;
		Vd = vdb;
		Vg = vgb;
		Vs = vsb;
	bias_data=[Vd,Vg,Vb,Vs];

	[Idlog,Id,Qs,Qd,Qg,Qb,Vdsi_out]=daa_mosfet(coeff,bias_data);

	idb = Id;
	igb = 0;
	isb = 0;

    out = [igb; idb; isb];
end

function out = qe(S)
    v2struct(S);

	global input_parms
	input_parms =[tipe;W;Lgdr;dLg;parm_gamma;phib;Cg;Cif;Cof;etov;mc;phit;parm_beta;parm_alpha;CTM_select]; % set of input parameters
	coeff=[Rs0; Rd0; delta; n0; nd; vxo; mu;Vt0];
		Vb = 0;
		Vd = vdb;
		Vg = vgb;
		Vs = vsb;
	bias_data=[Vd,Vg,Vb,Vs];

	[Idlog,Id,Qs,Qd,Qg,Qb,Vdsi_out]=daa_mosfet(coeff,bias_data);

	qgb = Qg;
	qdb = Qd;
	qsb = Qs;

    out = [qgb; qdb; qsb];
end
% Model exerciser for daa_mosfet
