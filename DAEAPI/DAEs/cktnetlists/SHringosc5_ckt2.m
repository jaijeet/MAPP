function cktnetlist = SHringosc5_ckt2()
%function cktnetlist = SHringosc5_ckt2()
%This function returns a cktnetlist structure for a ring oscillator
% 
% This is a test for subcircuit support using add_subcircuit
%
%The circuit
%   A 5-stage ring oscillator made of N-type and P-type Shichman-Hodeges MOS
%   devices. This circuit uses subcircuit SHinverter.
%
%To see the schematic of this circuit, run:
%
% showimage('SHringosc5.jpg'); [TODO]
%
%Examples
%--------
%
% % set up DAE %
% DAE = MNA_EqnEngine(SHringosc5_ckt);
%
% % DC analysis %
% qss = dot_op(DAE);       
% feval(qss.print, qss);
%
% % transient analysis %
% xinit = zeros(feval(DAE.nunks, DAE),1);
% tstart = 0; tstep = 1e-5; tstop = 5e-3;
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
% Author: Tianshi Wang, 2013/10/31


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%===========================================================================
	% subcircuit: inverter
	%---------------------------------------------------------------------------
    % ckt name
    subcktnetlist.cktname = 'Shichman-Hodges MOS inverter';

    % nodes (names)
    subcktnetlist.nodenames = {'vdd', 'in', 'out'};
    subcktnetlist.groundnodename = 'gnd';

    VddDC = 5;
    VinDC = 1;
    CL = 1e-6;

    % vddElem
    subcktnetlist = add_element(subcktnetlist, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, {{'E',...
    {'DC', VddDC}}});

    % % vinElem
    % subcktnetlist = add_element(subcktnetlist, vsrcModSpec(), 'Vin', {'in', 'gnd'}, {}, {{'E',...
    % {'DC', VinDC}}});

    % nmosElem
    subcktnetlist = add_element(subcktnetlist, SH_MOS_ModSpec(), 'NMOS', {'out', 'in', 'gnd'}, ...
    {{'Beta', 1.8e-3}, {'VT', 0.3}}, {});

    % pmosElem
    subcktnetlist = add_element(subcktnetlist, SH_MOS_ModSpec(), 'PMOS', {'out', 'in', 'vdd'}, ...
    {{'Type', 'P'}, {'Beta', 1.8e-3}, {'VT', 0.3}}, {});

    % clElem
    subcktnetlist = add_element(subcktnetlist, capModSpec(), 'CL', {'out', 'gnd'}, ...
    {{'C', CL}}, {});
	%===========================================================================


	% ckt name
	cktnetlist.cktname = 'Shichman-Hodges MOS ring oscillator with 5 stages';

	% nodes (names)
	cktnetlist.nodenames = {'vdd', 'inv1', 'inv2', 'inv3', 'inv4', 'inv5'};
	cktnetlist.groundnodename = 'gnd';

	VddDC = 5;
	IleakDC = -1e-6;
	CL = 1e-6;

	% vddElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, {{'E',...
	{'DC', VddDC}}});

	% ileakElem
	cktnetlist = add_element(cktnetlist, isrcModSpec(), 'Ileak', {'inv1', 'gnd'}, {}, {{'I',...
	{'DC', IleakDC}}});

	inverter = subcktnetlist;
	inverter.terminalnames = {'in', 'out'};

	% X1Elem
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X1', {'inv5', 'inv1'},...
		{{'NMOS:::Beta', 2.1e-3}, {'PMOS:::Beta', 2.1e-3}}, {{'Vdd:::E', {'DC', 5.1}}});

	% X2Elem
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X2', {'inv1', 'inv2'},...
		{{'NMOS','Beta', 2.2e-3}, {'PMOS', 'Beta', 2.2e-3}}, {{'Vdd', {'DC', 5.2}}});

	% X3Elem
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X3', {'inv2', 'inv3'}, {}, {});

	% X4Elem
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X4', {'inv3', 'inv4'}, {}, {});

	% X5Elem
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X5', {'inv4', 'inv5'}, {}, {});

	% c1Elem
	cktnetlist = add_element(cktnetlist, capModSpec(), 'C1', {'inv1', 'gnd'}, ...
	{{'C', CL}}, {});

	% c2Elem
	cktnetlist = add_element(cktnetlist, capModSpec(), 'C2', {'inv2', 'gnd'}, ...
	{{'C', CL}}, {});

	% c3Elem
	cktnetlist = add_element(cktnetlist, capModSpec(), 'C3', {'inv3', 'gnd'}, ...
	{{'C', CL}}, {});

	% c4Elem
	cktnetlist = add_element(cktnetlist, capModSpec(), 'C4', {'inv4', 'gnd'}, ...
	{{'C', CL}}, {});

	% c5Elem
	cktnetlist = add_element(cktnetlist, capModSpec(), 'C5', {'inv5', 'gnd'}, ...
	{{'C', CL}}, {});

end


