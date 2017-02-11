%ModSpec_demo is a script in MAPPquickstart_ModSpec.
%It creates an example ModSpec object for a tunnel diode model, plots its I/V,
%G/V curves by calling its ModSpec API functions, builds a simple circuit with
%it and runs DC and transient analyses on it.
%
%Please run:
%
%   >> ModSpec_demo 
%
clear;
echo on

%Step 1: write tunnel diode's equations
%--------------------------------------

    % The first step of device modelling in MAPP is usually studying the
    % device's behaviour and formulating its equations.
    %
    % A tunnel diode model has two terminals, namely p and n. Associated with
    % these two terminals are two electrical IO properties: vpn and ipn. We can
    % then write down equations to describe the relationship between them.

echo off 

try input('Press Enter/Return to display the equations of the model...'); catch, end 

echo on

showimage(which('tunnel_diode_eqns.jpg'));

echo off 

try input('Press Enter/Return for the next step...'); clc; close all; catch, end 

echo on

%Step 2: code the model in ModSpec format
%----------------------------------------

    % After determining the model's terminals, explicit output, f/q terms of
    % its equations, we can then code it in ModSpec format.

echo off 

try input('Press Enter/Return to display the code of the model...'); catch, end 

echo on

    type tunnelDiode_ModSpec_wrapper.m;

echo off 

try input('Press Enter/Return for the next step...'); clc; catch, end 

echo on
%Step 3: test the model standalone
%---------------------------------
    % Instantiate a ModSpec object for the tunnel diode model:
    MOD = tunnelDiode_ModSpec_wrapper;

    % Evaluate ipn at vpn = 0.1V:
    S = ee_model_parm2struct(MOD);
    S.vpn = 0.1;
    ipn = MOD.fe_of_S(S)

    % Write a for loop to evaluate ipn at vpn = -0.05:0.001:0.4:
    % implemented in plotIV_tunnelDiode_ModSpec_wrapper.m

echo off 

try input('Press Enter/Return to run plotIV_tunnelDiode_ModSpec_wrapper...'); catch, end 

echo on

    plotIV_tunnelDiode_ModSpec_wrapper;

    % Write a for loop to evaluate d(ipn)/d(vpn) at vpn = -0.05:0.001:0.4:
    % implemented in plotGV_tunnelDiode_ModSpec_wrapper.m

echo off 

try input('Press Enter/Return to run plotGV_tunnelDiode_ModSpec_wrapper...'); catch, end 

echo on

    plotGV_tunnelDiode_ModSpec_wrapper;

    % From the G/V plot we observe that with the default parameters, the tunnel
    % diode exhibits negative resistance property when vpn is from 0.1V to
    % 0.32V. This is one of the major characteristics of these tunnel diodes.

echo off 

try input('Press Enter/Return for the next step...'); clc; close all; catch, end 

echo on
%Step 4: build a simple circuit with the model
%---------------------------------------------

    % To better examine the tunnel diode model, especially to observe its
    % negative resistance property, we build a simple circuit as shown in the 
    % figure. Circuit parameters are designed such that the tunnel diode will
    % operate within its negative resistance range.

    showimage(which('tunnelDiode_osc.jpg'));

    clear cktnetlist;
    % ckt name
    cktnetlist.cktname = 'tunnelDiode LC oscillator';
    % nodes (names)
    cktnetlist.nodenames = {'n1', 'n2'}; % non-ground nodes
    cktnetlist.groundnodename = 'gnd';

    vM = vsrcModSpec();
        DCval = 0.2;
    cktnetlist = add_element(cktnetlist, vM, 'vsrc1', {'n1', 'gnd'}, {}, {{'E', {'dc', DCval}}});

    cktnetlist = add_element(cktnetlist, tunnelDiode_ModSpec_wrapper(), 'd1', {'n2', 'gnd'});
    cktnetlist = add_element(cktnetlist, resModSpec(), 'r1', {'n2', 'gnd'}, 1e9);
    cktnetlist = add_element(cktnetlist, indModSpec(), 'l1', {'n1', 'n2'}, 2e-6);
    cktnetlist = add_element(cktnetlist, capModSpec(), 'c1', {'n2', 'gnd'}, 0.5e-12);

echo off 

try input('Press Enter/Return for the next step...'); clc; close all; catch, end 


echo on
%Step 5: run DC/TRAN on the circuit
%-------------------------------------

    % Now the circuit's data is in cktnetlist, we set up a DAE using it:
    DAE = MNA_EqnEngine(tunnelDiode_osc_ckt());
   
    % DC analysis
    dcop = op(DAE);
    feval(dcop.print, dcop);

    % DC analysis confirms that at the DC operation point, the tunnel diode is
    % within its negative resistance range.
   
    % run transient and plot
    xinit = zeros(DAE.nunks(DAE), 1);
    xinit(2) = 0.3;
    tstart = 0; tstep = 0.1e-9; tstop = 100e-9;
    LMSobj = transient(DAE, xinit, tstart, tstep, tstop);
    feval(LMSobj.plot, LMSobj);

echo off 

try input('Press Enter/Return to close the plot and exit the demo...'); close all; catch, end 


%{
    % set AC analysis input as a function of frequency
    qssSol = feval(dcop.getSolution, dcop);
    Ufargs.string = 'no args used';; % 
    Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
    DAE = feval(DAE.set_uLTISSS, Uffunc, Ufargs, DAE);
    % run the AC analysis
    sweeptype = 'DEC'; fstart=1e7; fstop=1e10; nsteps=50;
    uDC = DAE.uQSS(DAE);
    acobj = ac(DAE, qssSol, uDC, fstart, fstop, nsteps, sweeptype);
    feval(acobj.plot, acobj);
%}
