function cktnetlist = MOS1_D_latch_core_2N1P_ckt()
%function cktnetlist = MOS1_D_latch_core_2N1P_ckt()
% This function returns a cktnetlist structure for the core circuit of a
% phase-logic D latch made of MOS1Modspec MOSFETs.
% 
%The circuit
%   A 3-stage ring oscillator made of N-type and P-type MOS1ModSpec
%   devices with a majority gate between two of the inverters. The output and
%   one of the inputs of the majority gate connects two stages of inverters in
%   the three-stage ring osc. The extra inputs of the majority gate are inputs
%   to the D_latch_core.
%
%   Its mechanism is easy to understand: when the two inputs represent
%   phase-logic 1 or 0, the output of the majority gate is determined as 1 or 0
%   accordingly, the logic latched in the ring osc will follow the inputs.
%   When the two inputs become different, one is 1 and the other is 0, the ring
%   osc w/ majority gate system is an oscillator latch by itself. So it retains
%   its original logic state because of SHIL.
%
%   With extra logic gates tied to this core circuit of a D latch, a regular D
%   latch controlled by D and EN signals can be constructed.
%
%To see the schematic of this circuit, run:
%
% showimage('MOS1_D_latch_core.png'); % Note: shows D latch core with 1N1P
%
%Examples
%--------
%
% % set up DAE %
% DAE = MNA_EqnEngine(MOS1_D_latch_core_2N1P_ckt);
%
% %%%%% compute QSS (DC) solution
% % print input names of DAE
% qss = dot_op(DAE);
% feval(qss.print, qss);
% qssSol = feval(qss.getSolution, qss);
% DAE.inputnames(DAE) % 'Vdd:::E' 'V1:::E' 'V2:::E'
% uDC = [3; 1.5; 1.5];  % 'Vdd:::E' 'V1:::E' 'V2:::E'
%
% %%%%% set transient input to the DAE
% utargs1.A = 1.5; utargs1.f=10e3; utargs1.phi=0; utargs1.offset = 1.5;
% utfunc = @(t, args) args.offset + args.A*sin(2*pi*args.f*t + args.phi);
% DAE = feval(DAE.set_utransient, 'V1:::E', utfunc, utargs1, DAE);
% DAE = feval(DAE.set_utransient, 'V2:::E', utfunc, utargs1, DAE);
% 
% %%%%% set up transient parameters
% tstart = 0; tstep = 0.02e-4; tstop = 3e-4;
%
% %%%%% set up and run the transient analysis
% LMSobj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
%
% % plot transient results
% feval(LMSobj.plot, LMSobj);
%
% %%%%% set a different set of transient inputs to the DAE
% utargs2.A = 1.5; utargs2.f=10e3; utargs2.phi=pi; utargs2.offset = 1.5;
% utfunc = @(t, args) args.offset + args.A*sin(2*pi*args.f*t + args.phi);
% DAE = feval(DAE.set_utransient, 'V1:::E', utfunc, utargs2, DAE);
% DAE = feval(DAE.set_utransient, 'V2:::E', utfunc, utargs2, DAE);
% 
% LMSobj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
% feval(LMSobj.plot, LMSobj);
%
% %%%%% set a different set of transient inputs to the DAE
%     % let the ring osc w/ majority osciallte by itself
% DAE = feval(DAE.set_utransient, 'V1:::E', utfunc, utargs1, DAE);
% DAE = feval(DAE.set_utransient, 'V2:::E', utfunc, utargs2, DAE);
% 
% LMSobj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
% feval(LMSobj.plot, LMSobj);
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI[TODO], DAE[TODO]
% dot_op, dot_transient
%

%
% Author: Tianshi Wang, 2014/09/11


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% MOS1_Model = MOS1ModSpec_v5_wrapper();
	MOS1_Model = MOS1ModSpec_v6_wrapper();

    ALD1106parms = {{'CBD', 0.5e-12}, ...
                    {'CBS', 0.5e-12}, ...
                    {'CGDO', 0.1e-12}, ...
                    {'CGSO', 0.1e-12}, ...
                    {'GAMMA', 0.85}, ...
                    {'KP', 225e-6}, ...
                    {'L', 10e-6}, ...
                    {'LAMBDA', 0.029}, ...
                    {'PHI', 0.9}, ...
                    {'VTO', 0.7}, ...
                    {'W', 20e-6}};
    % parms are for ALD1106, from
    % http://web.eece.maine.edu/~hummels/classes/ece343/docs/umaine.lib

    ALD1107parms = {{'TYPE', 'P'}, ...
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
                    {'W', 20E-6}};
    % parms are for ALD1107, from
    % http://web.eece.maine.edu/~hummels/classes/ece343/docs/umaine.lib


	%===========================================================================
	% subcircuit: MOS1inverter_2N1P
	%---------------------------------------------------------------------------
	clear subcktnetlist;
    % ckt name
    subcktnetlist.cktname = 'MOS1 inverter 2N1P';

    % nodes (names)
    subcktnetlist.nodenames = {'vdd', 'in', 'out'};
    subcktnetlist.groundnodename = 'gnd';

    CL = 4.7e-9;

    % nmos1Elem
	subcktnetlist = add_element(subcktnetlist, MOS1_Model, 'NMOS1', ...
             	{'out', 'in', 'gnd', 'gnd'}, ALD1106parms);

    % nmos2Elem
    subcktnetlist = add_element(subcktnetlist, MOS1_Model, 'NMOS2', ...
             	{'out', 'in', 'gnd', 'gnd'}, ALD1106parms);

    % pmosElem
    subcktnetlist = add_element(subcktnetlist, MOS1_Model, 'PMOS', ...
   	           {'vdd', 'in', 'out', 'vdd'}, ALD1107parms);

    % clElem
    subcktnetlist = add_element(subcktnetlist, capModSpec(), 'CL', ...
     	{'out', 'gnd'}, {{'C', CL}}, {});
    inverter = subcktnetlist;
	inverter.terminalnames = {'in', 'out', 'vdd'};
	%===========================================================================

	%===========================================================================
	% subcircuit: MOS1majority
	%---------------------------------------------------------------------------
	clear subcktnetlist;
    % ckt name
    subcktnetlist.cktname = 'MOS1 majority gate';

    % nodes (names)
    subcktnetlist.nodenames = {'vdd', 'in1', 'in2', 'in3', 'in', 'out', '1',...
                            '2', 'g', 'outp', 'bias'};
    subcktnetlist.groundnodename = 'gnd';

    VddDC = 3;
	Rin = 330e3;
	Rf = 220e3;
	R0 = 100e3;
    ALD1106parms = {{'CBD', 0.5e-12}, ...
                    {'CBS', 0.5e-12}, ...
                    {'CGDO', 0.1e-12}, ...
                    {'CGSO', 0.1e-12}, ...
                    {'GAMMA', 0.85}, ...
                    {'KP', 225e-6}, ...
                    {'L', 10e-6}, ...
                    {'LAMBDA', 0.029}, ...
                    {'PHI', 0.9}, ...
                    {'VTO', 0.7}, ...
                    {'W', 20e-6}};
    % parms are for ALD1106, from
    % http://web.eece.maine.edu/~hummels/classes/ece343/docs/umaine.lib

    ALD1107parms = {{'TYPE', 'P'}, ...
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
                    {'W', 20E-6}};
    % parms are for ALD1107, from
    % http://web.eece.maine.edu/~hummels/classes/ece343/docs/umaine.lib

    % MP1
    subcktnetlist = add_element(subcktnetlist, MOS1_Model, 'MP1', ...
          {'1', '1', 'vdd', 'vdd'}, ALD1107parms);

    % MP2
    subcktnetlist = add_element(subcktnetlist, MOS1_Model, 'MP2', ...
          {'out', '1', 'vdd', 'vdd'}, ALD1107parms);

    % MN1
    subcktnetlist = add_element(subcktnetlist, MOS1_Model, 'MN1', ...
          {'1', 'in', '2', 'gnd'}, ALD1106parms);

    % MN2
    subcktnetlist = add_element(subcktnetlist, MOS1_Model, 'MN2', ...
          {'out', 'outp', '2', 'gnd'}, ALD1106parms);

    % MN3
    subcktnetlist = add_element(subcktnetlist, MOS1_Model, 'MN3', ...
          {'2', 'g', 'gnd', 'gnd'}, ALD1106parms);

    % R1
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R1', ...
          {'in', 'in1'}, {{'R', Rin}});

    % R2
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R2', ...
          {'in', 'in2'}, {{'R', Rin}});

    % R3
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R3', ...
          {'in', 'in3'}, {{'R', Rin}});

    % Rf
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'Rf', ...
          {'out', 'outp'}, {{'R', Rf}});

    % R0
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R0', ...
          {'outp', 'bias'}, {{'R', R0}});

    % Rgup
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'Rgup', ...
          {'vdd', 'g'}, {{'R', 330e3}});

    % Rgdown
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'Rgdown', ...
          {'g', 'gnd'}, {{'R', 220e3}});

    % Rbiasup
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'Rbiasup', ...
          {'vdd', 'bias'}, {{'R', 1e3}});

    % Rbiasdown
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'Rbiasdown', ...
          {'bias', 'gnd'}, {{'R', 1e3}});

    majority = subcktnetlist;
	majority.terminalnames = {'in1', 'in2', 'in3', 'out', 'vdd'};
	%===========================================================================


	% ckt name
	cktnetlist.cktname = 'MOS1 D latch core 2N1P';

	% nodes (names)
	cktnetlist.nodenames = {'vdd', 'inv1in', 'inv1out', 'inv2', ...
	                       'inv3', 'in1', 'in2'};
	cktnetlist.groundnodename = 'gnd';

	VddDC = 3;

	% Vdd
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', ...
	             {'vdd', 'gnd'}, {}, {{'E', {'DC', VddDC}}});

	% X1
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X1', ...
	             {'inv3', 'inv1in', 'vdd'});

	% X2
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X2', ...
	             {'inv1out', 'inv2', 'vdd'});

	% X3
	cktnetlist = add_subcircuit(cktnetlist, inverter, 'X3', ...
	             {'inv2', 'inv3', 'vdd'});

	% X4
	cktnetlist = add_subcircuit(cktnetlist, majority, 'X4', ...
	             {'in1', 'in2', 'inv1in', 'inv1out', 'vdd'});

	% V1
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'V1', ...
	             {'in1', 'gnd'}, {}, {{'E', {'DC', 3}}});

	% V2
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'V2', ...
	             {'in2', 'gnd'}, {}, {{'E', {'DC', 3}}});
end
