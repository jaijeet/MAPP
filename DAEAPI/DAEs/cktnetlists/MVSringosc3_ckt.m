function cktnetlist = MVSringosc3_ckt()
%function cktnetlist = MVSringosc3_ckt()
% This function returns a cktnetlist structure for a 3-stage ring oscillator
% made of MVS MOSFETs.
% 
%The circuit
%   A 3-stage ring oscillator made of N-type and P-type MVS MOS
%   devices. This circuit uses subcircuit MVSinverter.
%
%To see the schematic of this circuit, run:
%
% showimage('MVSringosc3.jpg');
%
%Examples
%--------
%
% % set up DAE %
% DAE = MNA_EqnEngine(MVSringosc3_ckt);
%
% % DC analysis %
% qss = dot_op(DAE);       
% feval(qss.print, qss);
%
% % transient analysis %
% xinit = zeros(feval(DAE.nunks, DAE),1);
% xinit(2) = 1;
% tstart = 0; tstep = 2e-13; tstop = 30e-12;
% LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
%
% % plot seleted state outputs
% souts = StateOutputs(DAE);
% souts = souts.DeleteAll(souts);
% souts = souts.Add({'e_inv1', 'e_inv2', 'e_inv3'}, souts);
% feval(LMSobj.plot, LMSobj, souts);
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts,
% dot_op, dot_transient
%

%
% Author: Tianshi Wang, 2014/02/04


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% MVS_Model = MVS_1_0_1_ModSpec();
	MVS_Model = MVS_1_0_1_ModSpec_vv4();
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
	%===========================================================================

	% ckt name
	cktnetlist.cktname = 'MVS MOS ring oscillator with 3 stages';

	% nodes (names)
	cktnetlist.nodenames = {'vdd', 'inv1', 'inv2', 'inv3'};
	cktnetlist.groundnodename = 'gnd';

	VddDC = 1;
	% IleakDC = -1e-6;
	% Ileakfunc = @(t, args) args.A * sin(2*pi*args.f * t + args.phi);
	% Ileakargs.A = 1e-3; Ileakargs.f = 4e10; Ileakargs.phi = 0;

	% vddElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, {{'E',...
	{'DC', VddDC}}});

	% ileakElem
	% cktnetlist = add_element(cktnetlist, isrcModSpec(), 'Ileak', {'inv1', 'gnd'}, {}, {{'I',...
	% {'DC', IleakDC}}});
	% {'TRAN', Ileakfunc, Ileakargs}}});

	inverter = subcktnetlist;
	inverter.terminalnames = {'in', 'out', 'vdd'};

	% X1Elem
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X1', {'inv3', 'inv1', 'vdd'});

	% X2Elem
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X2', {'inv1', 'inv2', 'vdd'});

	% X3Elem
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X3', {'inv2', 'inv3', 'vdd'});

end


