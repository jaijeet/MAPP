function cktnetlist = MOS1ringOsc3_ckt()
%function cktnetlist = MOS1ringOsc3_ckt()
% This function returns a cktnetlist structure for a 3-stage ring oscillator
% made of MOS1Modspec MOSFETs
% 
%The circuit
%   A 3-stage ring oscillator made of N-type and P-type MOS1ModSpec
%   devices. This circuit uses subcircuit MOS1inverter.
%
%To see the schematic of this circuit, run:
%
% showimage('MVSringosc3.jpg'); % TODO: update name to MOS1
%
%Examples
%--------
%
% % set up DAE %
% DAE = MNA_EqnEngine(MOS1ringOsc3_ckt);
%
% % DC analysis %
% qss = dot_op(DAE);       
% feval(qss.print, qss);
%
% % transient analysis %
% xinit = zeros(feval(DAE.nunks, DAE),1);
% xinit(2) = 3;
% tstart = 0; tstep = 1e-6; tstop = 3e-4;
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
% Author: Tianshi Wang, 2014/07/08


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% MOS1_Model = MOS1ModSpec_v5_wrapper();
	MOS1_Model = MOS1ModSpec_v6_wrapper();

	%===========================================================================
	% subcircuit: MOS1inverter
	%---------------------------------------------------------------------------
    % ckt name
    subcktnetlist.cktname = 'MOS1 inverter';

    % nodes (names)
    subcktnetlist.nodenames = {'vdd', 'in', 'out'};
    subcktnetlist.groundnodename = 'gnd';

    CL = 4.7e-9;

    % nmosElem
    subcktnetlist = add_element(subcktnetlist, MOS1_Model, 'NMOS', {'out', 'in', 'gnd', 'gnd'}, ...
	{{'TYPE', 'N'}, ...
	 {'CBD', 0.5e-12}, ...
	 {'CBS', 0.5e-12}, ...
	 {'CGDO', 0.1e-12}, ...
	 {'CGSO', 0.1e-12}, ...
	 {'GAMMA', 0.85}, ...
	 {'KP', 225e-6}, ...
	 {'L', 10e-6}, ...
	 {'LAMBDA', 0.029}, ...
	 {'PHI', 0.9}, ...
	 {'VTO', 0.7}, ...
	 {'W', 20e-6}});
	 % parms are for ALD1106, from
	 % http://web.eece.maine.edu/~hummels/classes/ece343/docs/umaine.lib

    % pmosElem
    subcktnetlist = add_element(subcktnetlist, MOS1_Model, 'PMOS', {'vdd', 'in', 'out', 'vdd'}, ...
	{{'TYPE', 'P'}, ...
	 {'CBD', 0.5e-12}, ...
	 {'CBS', 0.5e-12}, ...
	 {'CGDO', 0.1e-12}, ...
	 {'CGSO', 0.1e-12}, ...
	 {'GAMMA', .45}, ...
	 {'KP', 100e-6}, ...
	 {'L', 10e-6}, ...
	 {'LAMBDA', 0.0304}, ...
	 {'PHI', .8}, ...
	 {'VTO', -0.82}, ...
	 {'W', 20E-6}});
	 % parms are for ALD1107, from
	 % http://web.eece.maine.edu/~hummels/classes/ece343/docs/umaine.lib

    % clElem
    subcktnetlist = add_element(subcktnetlist, capModSpec(), 'CL', {'out', 'gnd'}, ...
    {{'C', CL}}, {});
	%===========================================================================

	% ckt name
	cktnetlist.cktname = 'MOS1 ring oscillator with 3 stages';

	% nodes (names)
	cktnetlist.nodenames = {'vdd', 'inv1', 'inv2', 'inv3'};
	cktnetlist.groundnodename = 'gnd';

	VddDC = 3;

	% vddElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, {{'E',...
	{'DC', VddDC}}});

	inverter = subcktnetlist;
	inverter.terminalnames = {'in', 'out', 'vdd'};

	% X1Elem
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X1', {'inv3', 'inv1', 'vdd'});

	% X2Elem
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X2', {'inv1', 'inv2', 'vdd'});

	% X3Elem
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X3', {'inv2', 'inv3', 'vdd'});
end


