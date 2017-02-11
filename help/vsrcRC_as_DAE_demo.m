%vsrcRC_as_DAE is a demo in the help topic of MAPPquickstart_DAEs.
%
%It creates a DAE object describing the dynamics of a simple electrical circuit
%with a series connection of a voltage source, a resistor and a capacitor, then
%runs DC, AC, transient analyses on it.
%
%Please run:
%
%   >> vsrcRC_as_DAE_demo 
%
clear;
echo on

%======================
% vsrc-R-C circuit demo
%======================
%
%Step 1: study the circuit, write its equations
%----------------------------------------------
%
    % First we draw the circuit, identify circuit unknown(s) and hand derive
    % the circuit equation(s).
    %
    % The vsrc-R-C circuit is a series connection of a voltage source, a
    % resistor and a capacitor.

echo off 

try input('Press Enter/Return to display the circuit and its equation(s)...'); catch, end 

echo on

showimage(which('vsrcRC_eqns.jpg'));

echo off 

try input('Press Enter/Return for the next step...'); clc; close all; catch, end 

echo on

%Step 2: code the circuit's DAE in DAEAPI wrapper
%------------------------------------------------
%
    % After writing down the circuit's DAE we can then code it in DAEAPI
    % format using DAEAPI wrapper in MAPP.

echo off 

try input('Press Enter/Return to display the code of the DAE...'); catch, end 

fprintf('    function DAE = vsrcRC_DAEwrapper()                         \n');
fprintf('        DAE = init_DAE();                                      \n');
fprintf('                                                               \n');
fprintf('        DAE = add_to_DAE(DAE, ''name'', ''vsrc-R-C'');         \n');
fprintf('        DAE = add_to_DAE(DAE, ''unkname(s)'', {''e_n1''});     \n');
fprintf('        DAE = add_to_DAE(DAE, ''eqnname(s)'', {''KCL_n1''});   \n');
fprintf('        DAE = add_to_DAE(DAE, ''inputname(s)'', {''E''});      \n');
fprintf('        DAE = add_to_DAE(DAE, ''outputname(s)'', {''e_n1''});  \n');
fprintf('                                                               \n');
fprintf('        DAE = add_to_DAE(DAE, ''parm(s)'', {''R'', 1e3, ''C'', 1e-6}); \n');
fprintf('                                                               \n');
fprintf('        DAE = add_to_DAE(DAE, ''f'', @f);                      \n');
fprintf('        DAE = add_to_DAE(DAE, ''q'', @q);                      \n');
fprintf('                                                               \n');
fprintf('        DAE = finish_DAE(DAE);                                 \n');
fprintf('    end                                                        \n');
fprintf('                                                               \n');
fprintf('    function fout = f(S)                                       \n');
fprintf('        %% d/dt(C * e_n1) + (e_n1 - E)/R = 0                   \n');
fprintf('        fout = (S.e_n1 - S.E)/S.R;                             \n');
fprintf('    end %% f(...)                                              \n');
fprintf('                                                               \n');
fprintf('    function qout = q(S)                                       \n');
fprintf('        %% d/dt(C * e_n1) + (e_n1 - E)/R = 0                   \n');
fprintf('        qout = S.C * S.e_n1;                                   \n');
fprintf('    end %% q(...)                                              \n');

try input('Press Enter/Return for the next step...'); clc; catch, end 

echo on
%Step 3: run DC/AC/TRAN analyses on the DAE
%------------------------------------------
%
    % set up DAE
    DAE = vsrcRC_DAEwrapper();

    % set QSS value of input 'E' to be 1, calculate the DC operating point:
    DAE = DAE.set_uQSS('E', 1, DAE);
    dcop = op(DAE);
    dcop.print(dcop);
    qssSol = dcop.getSolution(dcop);

echo off 

try input('Press Enter/Return to proceed to AC analysis...'); catch, end 

echo on
    % set AC analysis input as a function of frequency:
    Ufargs.string = 'no args used'; 
    Uffunc = @(f, args) 1; % constant U(j 2 pi f) = 1
    DAE = feval(DAE.set_uLTISSS, 'E', Uffunc, Ufargs, DAE);

    % run the AC analysis:
    sweeptype = 'DEC'; fstart=1e0; fstop=1e5; nsteps=10;
    uDC = feval(DAE.uQSS, DAE);
    ACobj = ac(DAE, qssSol, uDC, fstart, fstop, nsteps, sweeptype);
    % plot frequency sweeps of system output(s)
    feval(ACobj.plot, ACobj);

echo off 

try input('Press Enter/Return to proceed to transient analysis...'); catch, end 

echo on
    % run transient simulation:
    xinit = zeros(feval(DAE.nunks, DAE), 1); % zero-state step response
    tstart = 0; tstep = 2e-5; tstop = 5e-3;                
    TRANobj = transient(DAE, xinit, tstart, tstep, tstop);
    % plot transient simulation results:
    feval(TRANobj.plot, TRANobj);

echo off 

try input('Press Enter/Return to close the plots, exit the demo and get back to MAPPquickstart_DAEs...'); close all; catch, end 

help  MAPPquickstart_DAEs;
