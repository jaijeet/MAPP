function DAE = inverterchain(uniqIDstr, nstages, VDDs, betaNs, betaPs, VtNs, VtPs, RdsNs, RdsPs, CLs)
%function DAE = inverterchain(uniqIDstr, nstages, VDDs, betaNs, betaPs, VtNs, VtPs, RdsNs, RdsPs, CLs)
% An inverter chain
%Author: J. Roychowdhury <jr@berkeley.edu>, 2011/sometime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	DAE1 = inverterchain_floating('invchain', nstages, VDDs, betaNs, betaPs, VtNs, VtPs, RdsNs, RdsPs, CLs);

	DAE2 = vsrc('Vin');

	nodes1 = {'e0'}; KCLs1  = {'KCL0'};
	nodes2 = {'e1'}; KCLs2 =  {'KCL1'};
	nodesKCLs1 = {nodes1, KCLs1}; nodesKCLs2 = {nodes2, KCLs2};

	DAE = connectCktsAtNodes('inverterchain_vsrc', DAE1, nodesKCLs1, nodesKCLs2, DAE2);

	% rename unks and eqns
	unknames = feval(DAE.unknames,DAE);
	newunknames = regexprep(unknames, '^invchain\.', '');
	DAE = DAE.renameUnks(DAE, unknames, newunknames);

	eqnnames = feval(DAE.eqnnames,DAE);
	neweqnnames = regexprep(eqnnames, '^invchain\.', '');
	DAE = DAE.renameEqns(DAE, eqnnames, neweqnnames);

	% rename parameters
	parmnames = feval(DAE.parmnames,DAE);
	newparmnames = regexprep(parmnames, '^invchain\.', '');
	DAE = DAE.renameParms(DAE, parmnames, newparmnames);

	% TODO: we need a renameInputs and renameOutputs
	% TODO: (less urgent) we need an add system outputs function

	% ugly hack - should implement renameDAE instead
	DAE.C = @(DAE) eye(length(DAE.unknameList));
    DAE.D = @(DAE) zeros(length(DAE.unknameList), 1);
	DAE.daename = @(DAE) 'inverterchain driven by voltage source';
% end inverterchain
