function cktnetlist = MOS1majority_ckt()
%function cktnetlist = MOS1majority_ckt()
% This function returns a cktnetlist structure for a majority gate
% made of MOS1 MOSFETs with parms for ALD1107, ALD1106.
%
% The majority gate works based on resistive feedback around a diff pair.
% It's not particularly well-designed. The major problems are:
% 1. when inputs have logic 1/1/1 and 1/1/0, the outputs are quite different,
%    causing difficulties for logic computation in the next stage.
% 2. because of the resistive feedback, the input/output resistances are
%    determined mainly by the resistors of choice. When connected with other
%    gates, loading must be considered.
% 3. the output is not rail-to-rail.
% 
%The circuit
%   majority gate (three input adder) made of MOS level 1 devices.
%
%To see the schematic of this circuit, run:
%
% showimage('MOS1majority.png');
%
%Examples
%--------
%
% %%%%% set up DAE
% DAE = MNA_EqnEngine(MOS1majority_ckt);
% 
% %%%%% compute QSS (DC) solution
% % print input names of DAE
% qss = dot_op(DAE);
% feval(qss.print, qss);
% qssSol = feval(qss.getSolution, qss);
% DAE.inputnames(DAE) % 'Vdd:::E' 'Vin1:::E' 'Vin2:::E' 'Vin3:::E'
% uDC = [3; 1.5; 1.5; 1.5];  % 'Vdd:::E' 'Vin1:::E' 'Vin2:::E' 'Vin3:::E'
%
% %%%%% set transient input to the DAE
% utargs.A = 1.5; utargs.f=10e3; utargs.phi=0; utargs.offset = 1.5;
% utfunc = @(t, args) args.offset + args.A*sin(2*pi*args.f*t + args.phi);
% DAE = feval(DAE.set_utransient, 'Vin1:::E', utfunc, utargs, DAE);
% DAE = feval(DAE.set_utransient, 'Vin2:::E', utfunc, utargs, DAE);
% DAE = feval(DAE.set_utransient, 'Vin3:::E', utfunc, utargs, DAE);
% 
% %%%%% set up transient parameters
% tstart = 0; tstep = 0.02e-4; tstop = 2e-4;
%
% %%%%% set up and run the transient analysis
% LMSobj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
%
% % plot transient results
% feval(LMSobj.plot, LMSobj);
%
% %%%%% set a different set of transient inputs to the DAE
% utargs.A = 1.5; utargs.f=10e3; utargs.phi=pi; utargs.offset = 1.5;
% utfunc = @(t, args) args.offset + args.A*sin(2*pi*args.f*t + args.phi);
% DAE = feval(DAE.set_utransient, 'Vin1:::E', utfunc, utargs, DAE);
% 
% LMSobj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
% feval(LMSobj.plot, LMSobj);
%
% %%%%% set AC analysis input as a function of frequency
% Ufargs.string = 'no args used';; % 
% Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
% DAE = feval(DAE.set_uLTISSS, 'Vin1:::E', Uffunc, Ufargs, DAE);
%
% %%%%% run the AC analysis to show input resistance
% sweeptype = 'DEC'; fstart=1e4; fstop=1.2e4; nsteps=10;
% acobj = dot_ac(DAE, qssSol, uDC, fstart, fstop, nsteps, sweeptype);
% [fpts, sols] = acobj.getsolution(acobj);
%
% % Rin for in1 at 10kHz
% idx = DAE.unkidx('Vin1:::ipn', DAE);
% 1./abs(sols(idx, 1, 1))
%

    % MOS1_Model = MOS1ModSpec_v3_wrapper;
    % MOS1_Model = MOS1ModSpec_v4_wrapper;
    MOS1_Model = MOS1ModSpec_v6_wrapper;

    % ckt name
    cktnetlist.cktname = 'MOS level 1 majority gate';

    % nodes (names)
    cktnetlist.nodenames = {'vdd', 'in1', 'in2', 'in3', 'in', 'out', '1',...
                            '2', 'g', 'outp', 'bias'};
    cktnetlist.groundnodename = 'gnd';

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

    % Vdd
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', ...
          {'vdd', 'gnd'}, {}, {{'E', {'DC', VddDC}}});

    % MP1
    cktnetlist = add_element(cktnetlist, MOS1_Model, 'MP1', ...
          {'1', '1', 'vdd', 'vdd'}, ALD1107parms);

    % MP2
    cktnetlist = add_element(cktnetlist, MOS1_Model, 'MP2', ...
          {'out', '1', 'vdd', 'vdd'}, ALD1107parms);

    % MN1
    cktnetlist = add_element(cktnetlist, MOS1_Model, 'MN1', ...
          {'1', 'in', '2', 'gnd'}, ALD1106parms);

    % MN2
    cktnetlist = add_element(cktnetlist, MOS1_Model, 'MN2', ...
          {'out', 'outp', '2', 'gnd'}, ALD1106parms);

    % MN3
    cktnetlist = add_element(cktnetlist, MOS1_Model, 'MN3', ...
          {'2', 'g', 'gnd', 'gnd'}, ALD1106parms);

    % R1
    cktnetlist = add_element(cktnetlist, resModSpec(), 'R1', ...
          {'in', 'in1'}, {{'R', Rin}});

    % R2
    cktnetlist = add_element(cktnetlist, resModSpec(), 'R2', ...
          {'in', 'in2'}, {{'R', Rin}});

    % R3
    cktnetlist = add_element(cktnetlist, resModSpec(), 'R3', ...
          {'in', 'in3'}, {{'R', Rin}});

    % Rf
    cktnetlist = add_element(cktnetlist, resModSpec(), 'Rf', ...
          {'out', 'outp'}, {{'R', Rf}});

    % R0
    cktnetlist = add_element(cktnetlist, resModSpec(), 'R0', ...
          {'outp', 'bias'}, {{'R', R0}});

    % Rgup
    cktnetlist = add_element(cktnetlist, resModSpec(), 'Rgup', ...
          {'vdd', 'g'}, {{'R', 330e3}});

    % Rgdown
    cktnetlist = add_element(cktnetlist, resModSpec(), 'Rgdown', ...
          {'g', 'gnd'}, {{'R', 220e3}});

    % Rbiasup
    cktnetlist = add_element(cktnetlist, resModSpec(), 'Rbiasup', ...
          {'vdd', 'bias'}, {{'R', 1e3}});

    % Rbiasdown
    cktnetlist = add_element(cktnetlist, resModSpec(), 'Rbiasdown', ...
          {'bias', 'gnd'}, {{'R', 1e3}});

    % Vin1
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin1', ...
          {'in1', 'gnd'}, {}, {{'E', {'DC', 1.5}}});

    % Vin2
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin2', ...
          {'in2', 'gnd'}, {}, {{'E', {'DC', 1.5}}});

    % Vin3
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin3', ...
          {'in3', 'gnd'}, {}, {{'E', {'DC', 1.5}}});
end
