%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% 
% Test various DAEAPI fucntions on xgate-vsrc-resistor DAE
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
	
	%%% check Jacobian %%%
	curDAE = xgate;
	nunks = feval(curDAE.nunks, curDAE);
	x = rand(nunks,1);
	ninps = feval(curDAE.ninputs, curDAE);
	if ninps > 0
		u = rand(ninps,1);
	else
		u = [];
	end
	Jhand = feval(curDAE.df_dx, x, u, curDAE)
	Jauto = df_dx_auto(x, u, curDAE)
	%%% check Jacobian %%%


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

	unknames = feval(DAE.unknames, DAE);
	eqnnames = feval(DAE.eqnnames, DAE);
	DAE = feval(DAE.renameUnks, DAE, unknames, ...
		regexprep(unknames,'^DAE2.',''));
	DAE = feval(DAE.renameEqns, DAE, eqnnames, ...
		regexprep(eqnnames,'^DAE2.',''));

	%%% check Jacobian %%%
	curDAE = DAE;
	nunks = feval(curDAE.nunks, curDAE);
	x = rand(nunks,1);
	ninps = feval(curDAE.ninputs, curDAE);
	if ninps > 0
		u = rand(ninps,1);
	else
		u = [];
	end
	Jhand = feval(curDAE.df_dx, x, u, curDAE)
	Jauto = df_dx_auto(x, u, curDAE)
	Jhand - Jauto
	%%% end check Jacobian %%%
	return
	% use vecvalder-based automatic differentiation for df_dx, df_du, dq_dx and dm_dx
	DAE.df_dx = @df_dx_auto;
	DAE.df_du = @df_du_auto;
	DAE.dq_dx = @dq_dx_auto;
	DAE.dm_dx = @dm_dx_auto;

	% ugly hack - should implement renameDAE instead
	DAE.daename = @(DAE) 'vsrc_xgate_resistor';

	%feval(DAE.unknames, DAE)
	%feval(DAE.eqnnames, DAE)
	%error('getting out')
