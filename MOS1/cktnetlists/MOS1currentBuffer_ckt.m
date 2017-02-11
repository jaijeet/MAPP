function cktnetlist = MOS1currentBuffer_ckt()
%function cktnetlist = MOS1currentBuffer_ckt()
% This function returns a cktnetlist structure for a current buffer
% (essentially a vccs) made of MOS1 MOSFETs
% 
%The circuit
%   current buffer made of MOS level 1 devices.
%
%To see the schematic of this circuit, run:
%
% showimage('MOS1currentBuffer.png');
%
%Examples
%--------
%
% %%%%% set up DAE
% DAE = MNA_EqnEngine(MOS1currentBuffer_ckt);
% 
% %%%%% compute QSS (DC) solution
% % print input names of DAE
% DAE.inputnames(DAE)  % 'Vdd:::E' 'Vin:::E' 'Vload:::E'
% uDC = [3;1;1.5]; % 'Vdd:::E' 'Vin:::E' 'Vload:::E'
% qss = dot_op(DAE);
% feval(qss.print, qss);
% qssSol = feval(qss.getSolution, qss);
%
% %%%%% DC sweep
% swp = dot_dcsweep(DAE, [], 'Vin:::E', 0, 3, 40);
% [Vins, DCsol] = swp.getsolution(swp);
% idx = DAE.unkidx('Vload:::ipn', DAE);
% figure; plot(Vins, DCsol(idx, :));
% title('DC sweep result: I_{out} vs Vin');
% xlabel('Vin'); ylabel('I_{out}');
% 
% % set AC analysis input as a function of frequency
% Ufargs.string = 'no args used';; % 
% Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
% DAE = feval(DAE.set_uLTISSS, 'Vload:::E', Uffunc, Ufargs, DAE);
%
%TODO: example below is obsolete
% % run the AC analysis
% sweeptype = 'DEC'; fstart=1e3; fstop=1e9; nsteps=10;
% acobj = dot_ac(DAE, qssSol, uDC, fstart, fstop, nsteps, sweeptype);
%
% % plot frequency sweeps of system outputs (overlay all on 1 plot)
% feval(acobj.plot, acobj);
%
% % set transient input to the DAE
% utargs.A = 0.1; utargs.f=10e3; utargs.phi=0;
% utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
% DAE = feval(DAE.set_utransient, 'Vin:::E', utfunc, utargs, DAE);
% 
% % set up transient parameters
% tstart = 0; tstep = 0.02e-4; tstop = 3e-4;
%
% % set up and run the transient analysis
% LMSobj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
%
% % plot transient results
% feval(LMSobj.plot, LMSobj);



    % MOS1_Model = MOS1ModSpec_v3_wrapper;
    % MOS1_Model = MOS1ModSpec_v4_wrapper;
    MOS1_Model = MOS1ModSpec_v6_wrapper;

    % ckt name
    cktnetlist.cktname = 'MOS level 1 current buffer';

    % nodes (names)
    cktnetlist.nodenames = {'vdd', 'in', 'out', '1', '2', 'g', 'ampout', 'ampfb'};
    cktnetlist.groundnodename = 'gnd';

    VddDC = 3;
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
          {'ampout', '1', 'vdd', 'vdd'}, ALD1107parms);

    % MN1
    cktnetlist = add_element(cktnetlist, MOS1_Model, 'MN1', ...
          {'1', 'in', '2', 'gnd'}, ALD1106parms);

    % MN2
    cktnetlist = add_element(cktnetlist, MOS1_Model, 'MN2', ...
          {'ampout', 'ampfb', '2', 'gnd'}, ALD1106parms);

    % MN3
    cktnetlist = add_element(cktnetlist, MOS1_Model, 'MN3', ...
          {'2', 'g', 'gnd', 'gnd'}, ALD1106parms);

    % MN4
    cktnetlist = add_element(cktnetlist, MOS1_Model, 'MN4', ...
          {'out', 'ampout', 'ampfb', 'gnd'}, ALD1106parms);

    % MN5
    cktnetlist = add_element(cktnetlist, MOS1_Model, 'MN5', ...
          {'in', 'in', 'gnd', 'gnd'}, ALD1106parms);

    % R1
    cktnetlist = add_element(cktnetlist, resModSpec(), 'R1', ...
          {'ampfb', 'gnd'}, {{'R', 10e3}});

    % R2
    cktnetlist = add_element(cktnetlist, resModSpec(), 'R2', ...
          {'vdd', 'in'}, {{'R', 2e3}});

    % Rgup
    cktnetlist = add_element(cktnetlist, resModSpec(), 'Rgup', ...
          {'vdd', 'g'}, {{'R', 330e3}});

    % Rgdown
    cktnetlist = add_element(cktnetlist, resModSpec(), 'Rgdown', ...
          {'g', 'gnd'}, {{'R', 220e3}});

    % Vin
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin', ...
          {'in', 'gnd'}, {}, {{'E', {'DC', 1}}});

    % Vload
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vload', ...
          {'out', 'gnd'}, {}, {{'E', {'DC', 1.5}}});
end
