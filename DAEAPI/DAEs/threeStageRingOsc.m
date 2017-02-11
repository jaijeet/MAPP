function DAE = threeStageRingOsc()
%function DAE = threeStageRingOsc()
% 3-stage ring oscillator
%Author: J. Roychowdhury <jr@berkeley.edu>, 2011/sometime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	VDD = 1.2;
	betaN = 1e-3;
	betaP = 1e-3;
	VTN = 0.25;
	VTP = 0.25;
	RDSN = 5800;
	RDSP = 5800;
	CL = 1e-7;

	DAE1 = inverterchain_floating('1inv', 1, VDD, betaN, betaP, VTN, VTP, RDSN, RDSP, CL);
	DAE2 = inverterchain_floating('2invs', 2, VDD, betaN, betaP, VTN, VTP, RDSN, RDSP, CL);

	nodes1 = {'e0', 'e1'}; KCLs1  = {'KCL0', 'KCL1'};
	nodes2 = {'e2', 'e0'}; KCLs2 =  {'KCL2', 'KCL0'};
	nodesKCLs1 = {nodes1, KCLs1}; nodesKCLs2 = {nodes2, KCLs2};

	DAE = connectCktsAtNodes('ringosc', DAE1, nodesKCLs1, nodesKCLs2, DAE2);
	DAE = feval(DAE.renameUnks, DAE, {'1inv.e0', '1inv.e1', '2invs.e1'}, ...
		{'n1', 'n2', 'n3'});
	DAE = feval(DAE.renameEqns, DAE, ...
		{'1inv.KCL0', '1inv.KCL1', '2invs.KCL1'}, ...
		{'KCL1', 'KCL2', 'KCL3'});

	% ugly hack - should implement renameDAE instead
	DAE.daename = @(DAE) '3-stage ring oscillator';
% end threeStageRingOsc
