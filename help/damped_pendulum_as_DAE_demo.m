%damped_pendulum_as_DAE_demo is a script in MAPPquickstart_DAEs.
%It creates a DAE object describing the dynamics of a nonlinear pendulum
%system, then runs transient analysis on it.
%
%Please run:
%
%   >> damped_pendulum_as_DAE_demo 
%
clear;
echo on

%=====================
% damped pendulum demo
%=====================

%Step 1: study this mechanical system, write its equations
%---------------------------------------------------------

    % First we draw this pendulum system and derive the DAEs by hand.

echo off 

try input('Press Enter/Return to display the system and its equation(s)...'); catch, end 

echo on

showimage(which('damped_pendulum_eqns.jpg')); % which is needed for Octave

echo off 

try input('Press Enter/Return for the next step...'); clc; close all; catch, end 

echo on

%Step 2: code the system's DAEs in DAEAPI wrapper
%------------------------------------------------

    % After writing down the system's DAEs we can then code them in DAEAPI
    % format using DAEAPI wrapper in MAPP.

echo off 

try input('Press Enter/Return to display the code of the DAE...'); catch, end 

fprintf('function DAE = damped_pendulum_DAEwrapper()                       \n');
fprintf('    DAE = init_DAE();                                             \n');
fprintf('                                                                  \n');
fprintf('    DAE = add_to_DAE(DAE, ''name'', ''pendulum'');                \n');
fprintf('    DAE = add_to_DAE(DAE, ''unkname(s)'', {''theta'', ''omega''});\n');
fprintf('    DAE = add_to_DAE(DAE, ''eqnname(s)'', {''thetadot'', ''omegadot''}); \n');
fprintf('    DAE = add_to_DAE(DAE, ''outputname(s)'', {''theta''});        \n');
fprintf('                                                                  \n');
fprintf('    DAE = add_to_DAE(DAE, ''parm(s)'', {''damping'', 0.1, ''g'', 9.81}); \n');
fprintf('    DAE = add_to_DAE(DAE, ''parm(s)'', {''l'', 1, ''mass'', 1});  \n');
fprintf('                                                                  \n');
fprintf('    DAE = add_to_DAE(DAE, ''f'', @f);                             \n');
fprintf('    DAE = add_to_DAE(DAE, ''q'', @q);                             \n');
fprintf('                                                                  \n');
fprintf('    DAE = add_to_DAE(DAE, ''C'', @C);                             \n');
fprintf('    DAE = add_to_DAE(DAE, ''D'', @D);                             \n');
fprintf('                                                                  \n');
fprintf('    DAE = finish_DAE(DAE);                                        \n');
fprintf('end                                                               \n');
fprintf('                                                                  \n');
fprintf('function out = C(DAE)                                             \n');
fprintf('    out = [1 0];                                                  \n');
fprintf('end                                                               \n');
fprintf('                                                                  \n');
fprintf('function out = D(DAE)                                             \n');
fprintf('    out = [];                                                     \n');
fprintf('end                                                               \n');
fprintf('                                                                  \n');
fprintf('function fout = f(S)                                              \n');
fprintf('    %% d/dt(theta) = - omega                                        \n');
fprintf('    %% d/dt(omega) = g/l * sin(theta) - damping/mass * omega      \n');
fprintf('    thetadot = + S.omega;                                         \n');
fprintf('    omegadot = - S.g/S.l * sin(S.theta) + S.damping/S.mass * S.omega;\n');
fprintf('    fout = [thetadot; omegadot];                                  \n');
fprintf('end %% f(...)                                                     \n');
fprintf('                                                                  \n');
fprintf('function qout = q(S)                                              \n');
fprintf('    %% d/dt(theta) = - omega                                        \n');
fprintf('    %% d/dt(omega) = g/l * sin(theta) - damping/mass * omega      \n');
fprintf('    qout = [S.theta; S.omega];                                    \n');
fprintf('end %% q(...)                                                     \n');

try input('Press Enter/Return for the next step...'); clc; catch, end 

echo on
%Step 3: run TRAN analysis on the DAE
%------------------------------------

    % set up DAE
    DAE = damped_pendulum_DAEwrapper();

    % run transient simulation:
    TR = tr(DAE, [pi/8; 0], 0, 0.02, 20); feval(TR.plot, TR);

echo off 

try input('Press Enter/Return to close the plot, exit the demo and get back to MAPPquickstart_DAEs...'); close all; catch, end 

help  MAPPquickstart_DAEs;
