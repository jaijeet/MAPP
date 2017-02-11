function cktnetlist = SHringosc3_ckt()
%function cktnetlist = SHringosc3_ckt()
%This function returns a cktnetlist structure for a ring oscillator made of
%Shichman Hodges MOS devices.
%
%The circuit
%   A 3-stage ring oscillator made of N-type and P-type Shichman Hodges MOS
%   devices.
%
%To see the schematic of this circuit, run:
%
% showimage('SHringosc3.jpg');
%
%Examples
%--------
%
% % set up DAE %
% DAE = MNA_EqnEngine(SHringosc3_ckt); % or DAE = STA_EqnEngine(SHringosc3_ckt);
% 
% % DC analysis %
% qss = dot_op(DAE);       
% feval(qss.print, qss);
%
% % transient analysis %
% xinit = mod(1:feval(DAE.nunks,DAE),2)-0.5; % alternating 0.5 and -0.5
% tstart = 0; tstep = 1e-5; tstop = 2.5e-3;
% LMSobj = transient(DAE, xinit, tstart, tstep, tstop);
%
% % plot seleted state outputs
% souts = StateOutputs(DAE);
% souts = souts.DeleteAll(souts);
% souts = souts.Add({'e_inv1', 'e_inv2', 'e_inv3'}, souts);
% feval(LMSobj.plot, LMSobj, souts);
%
%See also
%--------
% add_element, add_output, supported_ModSpec_devices[TODO], DAEAPI[TODO], 
% DAE_concepts, op, transient
%

%
% Author: Tianshi Wang, 2013/09/29


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	% ckt name
	cktnetlist.cktname = 'Shichman Hodges MOS ring oscillator with 3 stages';

	% nodes (names)
	cktnetlist.nodenames = {'vdd', 'inv1', 'inv2', 'inv3'};
	cktnetlist.groundnodename = 'gnd';

	VddDC = 5;
	% IleakDC = -1e-6;
	CL = 1e-6;

	% vddElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, {{'E',...
	{'DC', VddDC}}});

	% ileakElem
	% cktnetlist = add_element(cktnetlist, isrcModSpec(), 'Ileak', {'inv1', 'gnd'}, {}, {{'I',...
	% {'DC', IleakDC}}});

	% nmos1Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'NMOS1', {'inv1', 'inv3', 'gnd'}, ...
	{{'Beta', 1.8e-3}, {'VT', 0.3}}, {});

	% pmos1Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'PMOS1', {'inv1', 'inv3', 'vdd'}, ...
	{{'Type', 'P'}, {'Beta', 1.8e-3}, {'VT', 0.3}}, {});

	% c1Elem
	cktnetlist = add_element(cktnetlist, capModSpec(), 'C1', {'inv1', 'gnd'}, ...
	{{'C', CL}}, {});

	% nmos2Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'NMOS2', {'inv2', 'inv1', 'gnd'}, ...
	{{'Beta', 1.8e-3}, {'VT', 0.3}}, {});

	% pmos2Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'PMOS2', {'inv2', 'inv1', 'vdd'}, ...
	{{'Type', 'P'}, {'Beta', 1.8e-3}, {'VT', 0.3}}, {});

	% c2Elem
	cktnetlist = add_element(cktnetlist, capModSpec(), 'C2', {'inv2', 'gnd'}, ...
	{{'C', CL}}, {});

	% nmos3Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'NMOS3', {'inv3', 'inv2', 'gnd'}, ...
	{{'Beta', 1.8e-3}, {'VT', 0.3}}, {});

	% pmos3Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'PMOS3', {'inv3', 'inv2', 'vdd'}, ...
	{{'Type', 'P'}, {'Beta', 1.8e-3}, {'VT', 0.3}}, {});

	% c3Elem
	cktnetlist = add_element(cktnetlist, capModSpec(), 'C3', {'inv3', 'gnd'}, ...
	{{'C', CL}}, {});

end
