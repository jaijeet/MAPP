function cktnetlist = SHringosc101_ckt()
%function cktnetlist = SHringosc101_ckt()
%This function returns a cktnetlist structure for a ring oscillator
% 
%This is a test for speeding-up MNA_EqnEngine.
%
%The circuit
%   A 101-stage ring oscillator made of N-type and P-type Shichman-Hodeges MOS
%   devices. This circuit uses subcircuit SHinverter.
%
%To see the schematic of this circuit, run:
%
% showimage('SHringosc101.jpg'); [TODO]
%
%Examples
%--------
%
% % set up DAE %
% DAE = MNA_EqnEngine(SHringosc101_ckt);
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
% Author: Tianshi Wang, 2016/10/02


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
	cktnetlist.nodenames = {'vdd'};
	for c = 1:101
		cktnetlist.nodenames{end+1} = sprintf('inv%d', c);
	end
	cktnetlist.groundnodename = 'gnd';

	VddDC = 5;
	CL = 1e-6;

	% vddElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, {{'E',...
	{'DC', VddDC}}});

	inverter = subcktnetlist;
	inverter.terminalnames = {'in', 'out'};

	% X1Elem
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X1', {'inv101', 'inv1'},...
		{{'NMOS:::Beta', 2.1e-3}, {'PMOS:::Beta', 2.1e-3}}, {{'Vdd:::E', {'DC', 5.1}}});

	% c1Elem
	cktnetlist = add_element(cktnetlist, capModSpec(), 'C1', {'inv1', 'gnd'}, ...
	{{'C', CL}}, {});

	for c = 2:101
		% XcElem
		eval(sprintf('cktnetlist = add_subcircuit(cktnetlist, inverter, ''X%d'', {''inv%d'', ''inv%d''}, {}, {});', c, c-1, c));
		% % CcElem
		% eval(sprintf('cktnetlist = add_element(cktnetlist, capModSpec(), ''C%d'', {''inv%d'', ''gnd''}, {{''C'', CL}}, {});'), c, c);
	end
end


