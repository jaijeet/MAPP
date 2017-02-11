function cktnetlist = MVSinverterChain_ckt(N)
%function cktnetlist = MVSinverterChain_ckt(N)
% This function returns a cktnetlist structure for an inverter chain
% made of MVS MOSFETs
% 
%The circuit
% An inverter chain with N stages. N is the input to this function.
% For information on the structure of each stage of inverters, see
% >> help MVSinverter_ckt
%
%To see the schematic of this circuit, run:
%
% showimage('MVSinverterChain.jpg'); % TODO: no image
%
%Examples
%--------
%
% % set up DAE %
% N = 9;
% DAE = MNA_EqnEngine(MVSinverterChain_ckt(N));
%
% % DC analysis %
% % [TODO] doesn't converge reliably.
% qss = dot_op(DAE);       
% feval(qss.print, qss);
% qssSol = feval(qss.getSolution, qss);
%
% % transient analysis %
% xinit = zeros(feval(DAE.nunks, DAE), 1);
% tstart = 0; tstep = 0.1e-9; tstop = 3e-9;
% LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
% feval(LMSobj.plot, LMSobj);
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI[TODO], DAE[TODO]
% dot_op, dot_transient
%

%
% Author: Tianshi Wang, 2014/07/07


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	MVS_Model = MVS_1_0_1_ModSpec();
	% MVS_Model = MVS_1_0_1_ModSpec_wrapper();

	%===========================================================================
	% subcircuit: MVSinverter
	%---------------------------------------------------------------------------
    % ckt name
    subcktnetlist.cktname = 'MVS inverter';

    % nodes (names)
    subcktnetlist.nodenames = {'vdd', 'in', 'out'};
    subcktnetlist.groundnodename = 'gnd';

    VddDC = 1;
    VinDC = 0;
    CL = 3e-15;

    % nmosElem
    subcktnetlist = add_element(subcktnetlist, MVS_Model, 'NMOS', {'out', 'in', 'gnd', 'gnd'}, ...
    {{'Type', 1}, {'W', 1e-4}, {'Lgdr', 32e-7}, {'dLg', 9e-7}, {'Cg', 2.57e-6},...
   	{'Beta', 1.8}, {'Alpha', 3.5}, {'Tjun', 300}, {'Cif', 1.38e-12}, {'Cof', 1.47e-12},...
   	{'phib', 1.2}, {'Gamma', 0.1}, {'mc', 0.2}, {'CTM_select', 1}, {'Rs0', 100},...
   	{'Rd0', 100}, {'n0', 1.68}, {'nd', 0.1}, {'vxo', 1.2e7}, {'Mu', 200}, {'Vt0', 0.4}, {'delta', 0.15}});

    % pmosElem
    subcktnetlist = add_element(subcktnetlist, MVS_Model, 'PMOS', {'vdd', 'in', 'out', 'vdd'}, ...
    {{'Type', -1}, {'W', 1.0e-4}, {'Lgdr', 32e-7}, {'dLg', 8e-7}, {'Cg', 2.57e-6},...
   	{'Beta', 1.8}, {'Alpha', 3.5}, {'Tjun', 300}, {'Cif', 1.38e-12}, {'Cof', 1.47e-12},...
   	{'phib', 1.2}, {'Gamma', 0.1}, {'mc', 0.2}, {'CTM_select', 1}, {'Rs0', 100},...
   	{'Rd0', 100}, {'n0', 1.68}, {'nd', 0.1}, {'vxo', 7542204}, {'Mu', 165}, {'Vt0', 0.5535}, {'delta', 0.15}}); 

    % clElem
    subcktnetlist = add_element(subcktnetlist, capModSpec(), 'CL', {'out', 'gnd'}, ...
    {{'C', CL}}, {});

	% ====== hack for convergence =========
    % rlElem
    % subcktnetlist = add_element(subcktnetlist, resModSpec(), 'RL', {'out', 'gnd'}, ...
    % {{'R', 1e6}}, {});
	%===========================================================================

	if 0 == nargin
		N = 99;
	end

	% ckt name
	cktnetlist.cktname = 'MVS MOS inverter chain';

	% nodes (names)
	cktnetlist.nodenames = {'vdd', 'in'}; % to be augmented in the for loop below
	cktnetlist.groundnodename = 'gnd';

	VddDC = 1;

	VinDC = 0;
	Vinfunc = @(t, args) args.offset + args.A * sin(2*pi*args.f * t + args.phi);
	Vinargs.offset = 0.5; Vinargs.A = 0.5; Vinargs.f = 1e9; Vinargs.phi = 0;

	% vddElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, {{'E',...
	{'DC', VddDC}}});

	% VinElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin', {'in', 'gnd'}, {}, {{'E',...
	{'TRAN', Vinfunc, Vinargs}}});

	inverter = subcktnetlist;
	inverter.terminalnames = {'in', 'out', 'vdd'};

	for c = 1:N
		% augment nodes
		cktnetlist.nodenames = {cktnetlist.nodenames{:}, sprintf('%d', c)};
		%
		% template for adding inverters:
		% cktnetlist = add_subcircuit(cktnetlist, inverter, 'X1', {'inv3', 'inv1', 'vdd'});
		%
		if 1 == c
			cktnetlist = add_subcircuit(cktnetlist, inverter, sprintf('X%d', c),...
			{'in', sprintf('%d', c), 'vdd'});
		else
			cktnetlist = add_subcircuit(cktnetlist, inverter, sprintf('X%d', c),...
			{sprintf('%d', c-1), sprintf('%d', c), 'vdd'});
		end
	end
end
