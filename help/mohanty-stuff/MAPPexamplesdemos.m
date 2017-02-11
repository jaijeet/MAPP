%MAPP Analyses Examples and Demos: 
%--------------------------------- 
%<TODO> LONG.. NEED to arrange in possible subtopics </TODO>
%You can directly run the following examples/demos which demonstrate various
%analyses performed on different circuit DAEs in MAPP. For example, to do "AC
%analysis of a full wave rectifier circuit", type "run_fullWaveRectifier_AC"
%(without quotes) at MATLAB command line. If you want to get specific help on a
%particular example/demo script, use "help" function. For example, to get
%specific help on the script the "run_fullWaveRectifier_AC", type "help
%run_fullWaveRectifier_AC" (without quotes) at MATLAB command line.
%
%
%run_fullWaveRectifier_DCsweep       - DC sweep on a full wave rectifier circuit
%run_fullWaveRectifier_AC            - AC analysis of a full wave rectifier
%                                      circuit
%run_fullWaveRectifier_transient     - Transient analysis on a full wave
%                                      rectifier circuit
%run_inverter_DCsweep                - DC sweep on an inverter circuit using
%                                      Shichmann-Hodges (SH) model
%run_inverter_transient              - Transient analysis on an inverter circuit
%                                      using SH model 
%run_BJTdiffpair_DCsweep             - DC sweep on a differential pair using
%                                      Ebers-Moll (EM) BJTs
%run_BJTdiffpair_AC                  - Run AC analysis on a differential pair
%                                      using EM BJTs 
%run_BJTschmittTrigger_transient     - Run transient simulation on a BJT Schmitt
%                                      trigger circuit
%run_inverterchain_transient         - Transient simulation on an inverter chain
%                                      using SH CMOS model
%
%For complete list of available examples and demos, type " help
%analyses-test-scripts" (without quotes) at MATLAB command line.
%
%The following examples introduces some of the actual MAPP commands and
%syntaxes. After getting introduced to those commands and syntaxes, you can
%experiment with various analysis options. For example, you can try different
%LMS methods for doing the transient analysis.
%<TODO> MORE examples </TODO>
%
%EXAMPLE 1: Transient analysis on a BJT differential pair using Backward
%           Euler method
%
%  % Creates BJT differential pair circuit DAE in MATLAB workspace
%    DAE = BJTdiffpair_DAEAPIv6(); 
%
%  % Set transient input to the DAE 
%    utargs.A = 0.2; utargs.f=1e2; utargs.phi=0; 
%    utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
%    DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);
%
%  % Set up LMS object
%    TransObjBE = LMS(DAE); % default method is Backward Euler (BE), 
%                           % but it also defines TRAPparms (Trapeziodal)
%                           % Forward Euler(FEparms), GEAR2 (GEAR2Parms)
%  % Run transient and plot
%    xinit = [3; 3; -0.5];        % Initial condition
%    tstart = 0; tstop = 5e-2;    % Start and end time
%    tstep = 10e-5;               % Time step
%        
%  % Simulate TransObjBE object 
%    TransObjBE = feval(TransObjBE.solve, TransObjBE, xinit, tstart, ... 
%                        tstep, tstop);
%  % Plot simulation results
%    [thefig, legends] = feval(TransObjBE.plot, TransObjBE, [], 'BE');
%
%If we want to use a different LMS method for transient simulation (instead of
%default Backward Euler (BE)), a new LMS method can be selected as shown in the
%following example. 
%
%
%EXAMPLE 2: Transient analysis on a BJT differential pair using
%           Trapezoidal method
%
%  % Creates a BJT differential pair circuit DAE in MATLAB workspace
%    DAE = BJTdiffpair_DAEAPIv6(); 
%
%  % Set transient input to the DAE 
%    utargs.A = 0.2; utargs.f=1e2; utargs.phi=0; 
%    utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
%    DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);
%
%  % Set up LMS object
%    TransObjBE = LMS(DAE); % default method is Backward Euler (BE), 
%                           % but it also defines TRAPparms (Trapezoidal)
%                           % Forward Euler(FEparms), GEAR2 (GEAR2parms)
%
%  % Set up a different LMS object with TRAPparms method.
%  % TRAPparms contains the order, name (TRAP, in this case), alpha and 
%  % beta functions and differentiation approximation algorithm.
%    TransObjTRAP = LMS(DAE,TransObjBE.TRAPparms);
%
%  % Setting up GEAR2 method in the LMS object can be done as follows:
%  % TransObjGEAR2 = LMS(DAE,TransObjBE.GEAR2.parms)
%
%  % Simulate TransObjTRAP object 
%    TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, xinit, tstart, ...
%                        tstep, tstop);
%  % Plot simulation results
%    [thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, [], 'TRAP'); 
%
%
