function DAE = vsrc_xgate_resistor()
%function DAE = vsrc_xgate_resistor()
% <TODO> vsrc-xgate-resistor circuit
%Author: J. Roychowdhury <jr@berkeley.edu>, 2011/sometime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	betaN = 10e-3;
	betaP = 10e-3;
	VTN = 0.25;
	VTP = 0.25;
	RDSN = 100000;
	RDSP = 100000;
	CgsN = 1e-7;
	CgsP = 1e-7;
	CgdN = 1e-7;
	CgdP = 1e-7;

	xgate = CMOS_xgate_floating('xgate', betaN, betaP, VTN, VTP, RDSN, RDSP, CgsN, CgsP, CgdN, CgdP);
	vinp = vsrc('vinp');

	res = resistor_floating('res', 1000);
	vgnd = vsrc('vgnd');

	nodesRes = {'e2'}; KCLsRes  = {'KCL2'}; nodesKCLsRes = {nodesRes, KCLsRes};
	nodesVgnd = {'e1'}; KCLsVgnd =  {'KCL1'}; nodesKCLsVgnd = {nodesVgnd, KCLsVgnd};
	resTOgnd = connectCktsAtNodes('resTOgnd', res, nodesKCLsRes, nodesKCLsVgnd, vgnd);

	nodesVinp = {'e1'}; KCLsVinp =  {'KCL1'}; nodesKCLsVinp = {nodesVinp, KCLsVinp};
	nodesXgate = {'e1'}; KCLsXgate  = {'KCL1'}; nodesKCLsXgate = {nodesXgate, KCLsXgate};
	vinpXgate = connectCktsAtNodes('vinpXgate', vinp, nodesKCLsVinp, nodesKCLsXgate, xgate);
	%feval(vinpXgate.nNoiseSources, vinpXgate)
	%feval(vinpXgate.NoiseSourceNames, vinpXgate)


	nodes1 = {'xgate.e2'}; KCLs1  = {'xgate.KCL2'}; nodesKCLs1 = {nodes1, KCLs1};
	nodes2 = {'res.e1'}; KCLs2  = {'res.KCL1'}; nodesKCLs2 = {nodes2, KCLs2};

	%fprintf(2,'setting up DAE1\n');
	DAE1 = connectCktsAtNodes('DAE1', vinpXgate, nodesKCLs1, nodesKCLs2, resTOgnd);

	% rename eqns and unknowns 
	%{
	DAE1 = feval(DAE1.renameUnks, DAE1, feval(DAE1.unknames,DAE1), ...
		{'e1', 'iVin', 'e2', 'eEN', 'eENbar', 'e3', 'iVgnd'});
	DAE1 = feval(DAE1.renameEqns, DAE1, feval(DAE1.eqnnames,DAE1), ...
		{'KCL1', 'BCRVin', 'KCL2', 'KCL_EN', 'KCL_ENbar', ...
		 'KCL3', 'BCRVgnd'});
	%}

	vEN = vsrc('vEN');
	%fprintf(2,'setting up DAE2\n');
	DAE2 = connectCktsAtNodes('DAE2', DAE1, {{'vinpXgate.xgate.eEN'},{'vinpXgate.xgate.KCL_EN'}}, ...
		{{'e1'},{'KCL1'}}, vEN);

	% rename eqns and unknowns 
	%{
	unknames = feval(DAE2.unknames, DAE2);
	eqnnames = feval(DAE2.eqnnames, DAE2);
	%DAE2 = feval(DAE2.renameUnks, DAE2, unknames, ...
		regexprep(unknames,'^DAE1.',''));
	DAE2 = feval(DAE2.renameEqns, DAE2, eqnnames, ...
		regexprep(eqnnames,'^DAE1.',''));
	%}

	vENbar = vsrc('vENbar');
	DAE = connectCktsAtNodes('vsrc-xgate-res', DAE2, {{'DAE1.vinpXgate.xgate.eENbar'},{'DAE1.vinpXgate.xgate.KCL_ENbar'}}, ...
		{{'e1'},{'KCL1'}}, vENbar);

	% now rename unks and eqns
	unknames = feval(DAE.unknames, DAE);
	%{ unknames:
		%[1,1] = DAE2.DAE1.vinpXgate.vinp.e1 	-> eVin
		%[1,2] = DAE2.DAE1.vinpXgate.vinp.iE 	-> iVin
		%[1,3] = DAE2.DAE1.vinpXgate.xgate.e2 	-> eOutR
		%[1,4] = DAE2.DAE1.vinpXgate.xgate.eEN 	-> eEN
		%[1,5] = DAE2.DAE1.vinpXgate.xgate.eENbar-> eENbar
		%[1,6] = DAE2.DAE1.resTOgnd.res.e2	-> eVgnd
		%[1,7] = DAE2.DAE1.resTOgnd.vgnd.iE	-> iVgnd
		%[1,8] = DAE2.vEN.iE			-> ivEN
		%[1,9] = vENbar.iE			-> ivENbar
	%}
	DAE = feval(DAE.renameUnks, DAE, unknames, {'eVin', 'iVin', 'eOutR', ...
		'eEN', 'eENbar', 'eVgnd', 'iVgnd', 'ivEN', 'ivENbar'});

	eqnnames = feval(DAE.eqnnames, DAE);
	%{ eqnnames:
		%[1,1] = DAE2.DAE1.vinpXgate.vinp.KCL1 		-> nVin_KCL
		%[1,2] = DAE2.DAE1.vinpXgate.vinp.BCRE		-> Vin_BCR
		%[1,3] = DAE2.DAE1.vinpXgate.xgate.KCL2		-> eOutR_KCL
		%[1,4] = DAE2.DAE1.vinpXgate.xgate.KCL_EN	-> nEN_KCL
		%[1,5] = DAE2.DAE1.vinpXgate.xgate.KCL_ENbar	-> nENbar_KCL
		%[1,6] = DAE2.DAE1.resTOgnd.res.KCL2		-> nVgnd_KCL
		%[1,7] = DAE2.DAE1.resTOgnd.vgnd.BCRE		-> Vgnd_BCR
		%[1,8] = DAE2.vEN.BCRE				-> vEN_BCR
		%[1,9] = vENbar.BCRE				-> vENbar_BCR
	%}
	DAE = feval(DAE.renameEqns, DAE, eqnnames, {'nVin_KCL', 'Vin_BCR', 'eOutR_KCL', 'nEN_KCL', ...
		'nENbar_KCL', 'nVgnd_KCL', 'Vgnd_BCR', 'vEN_BCR', 'vENbar_BCR'});

	% use vecvalder-based automatic differentiation for df_dx, df_du, dq_dx and dm_dx
	DAE.df_dx = @df_dx_DAEAPI_auto;
	DAE.df_du = @df_du_DAEAPI_auto;
	DAE.dq_dx = @dq_dx_DAEAPI_auto;
	DAE.dm_dx = @dm_dx_DAEAPI_auto;

	% ugly hack - should implement renameDAE instead
	DAE.daename = @(DAE) 'vsrc_xgate_resistor';

	%feval(DAE.unknames, DAE)
	%feval(DAE.eqnnames, DAE)
	%error('getting out')
% end vsrc_xgate_resistor
