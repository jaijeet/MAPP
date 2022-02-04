function cktnetlist = SHringosc101_ckt()
%function cktnetlist = SHringosc101_ckt()
%This function returns a cktnetlist structure for a ring oscillator
% 
%This is a test for speeding-up MNA_EqnEngine.
%
%The circuit
%   A 101-stage ring oscillator made of N-type and P-type Shichman-Hodges MOS
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
% % nodes inv1, inv50, and inv101 are outputs. To see others use
% % StateOutputs(DAE).
% % The period T is approximately (8.86-3.94)e-3 = 4.92e-3
%
% % DC analysis %
% qss = dot_op(DAE);       
% feval(qss.print, qss);
%
% % transient analysis %
% %load('SHringosc101_ckt_xinit_GEAR2_tstep1e-5.mat'); % sets up a periodic xinit.
% load('SHringosc101_ckt_xinit_TRAP_3000pts.mat'); % sets up a periodic xinit.
% %T=4.92e-3; % w tstep = 1e-5, GEAR2
% %T=4.80398e-3; % w pts/cycle = 3000, TRAP
% T=4.80328e-3; % w pts/cycle = 6000, TRAP
% % pts_per_cycle = 3000; % takes 3478s with TRAP on jaam
% pts_per_cycle = 6000; % takes {5842,6567}s with TRAP on jaam
% tstart = 0; tstop = T; tstep = T/pts_per_cycle; % simulates "exactly" one period
% %xinit = zeros(feval(DAE.nunks, DAE),1); % this will show startup transients
% tic; LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop, 'method', 'TRAP'); toc
% feval(LMSobj.plot, LMSobj);
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI[TODO], DAE[TODO]
% dot_op, dot_transient
%

%
% Updated 2021/07/15, JR, to shorten osc. period, fix strange asymmetry in the last inverter, and speed up simulation.
% Author: Tianshi Wang, 2016/10/02

% %thisfile_fullpath = which('SHringosc101_ckt.m');
% %thisdir = regexprep(thisfile_fullpath, '/SHringosc101_ckt.m','');
% %initcondfile=sprintf('%s/%s', thisdir, 'SHringosc101_ckt_xinit.mat');


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
    %CL = 1e-6;
    CL = 1e-7;

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
	cktnetlist.cktname = 'Shichman-Hodges MOS ring oscillator with 101 stages';

	% nodes (names)
	cktnetlist.nodenames = {'vdd'};
	for c = 1:101
		cktnetlist.nodenames{end+1} = sprintf('inv%d', c);
	end
	cktnetlist.groundnodename = 'gnd';

	% vddElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, {{'E',...
	{'DC', VddDC}}});

	inverter = subcktnetlist;
	inverter.terminalnames = {'in', 'out'};

	% X1Elem
	% cktnetlist = add_subcircuit(cktnetlist, inverter, 'X1', {'inv101', 'inv1'},...
	% 	{{'NMOS:::Beta', 2.1e-3}, {'PMOS:::Beta', 2.1e-3}}, {{'Vdd:::E', {'DC', 5.1}}});
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X1', {'inv101', 'inv1'}, {}, {});

	% c1Elem
	cktnetlist = add_element(cktnetlist, capModSpec(), 'C1', {'inv1', 'gnd'}, ...
	{{'C', CL}}, {});

	for c = 2:101
		% XcElem
		eval(sprintf('cktnetlist = add_subcircuit(cktnetlist, inverter, ''X%d'', {''inv%d'', ''inv%d''}, {}, {});', c, c-1, c));
		% % CcElem
		% eval(sprintf('cktnetlist = add_element(cktnetlist, capModSpec(), ''C%d'', {''inv%d'', ''gnd''}, {{''C'', CL}}, {});'), c, c);
	end
    cktnetlist = add_output(cktnetlist, 'inv1');
    cktnetlist = add_output(cktnetlist, 'inv50');
    cktnetlist = add_output(cktnetlist, 'inv101');
end


