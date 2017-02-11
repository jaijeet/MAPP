%Differential-Algebraic Equations in MAPP
%----------------------------------------
%
%In MAPP, differential-algebraic equations (DAEs) are written in the following
%general form:
%
%       d/dt [q(x(t))] + f(x(t), u(t)) = 0,
%       y(t) = C*x(t) + D*u(t).
%
%Here, x(t) is a column vector of the system's n unknowns, u(t) is a column
%vector of its n_u inputs, f(.,.) and q(.) are (in general nonlinear)
%functions that return column vectors of size n. y(t) is a vector of n_o
%outputs, while C and D are matrices of size n_o x n and n_o x n_u,
%respectively.
%
%DAEAPI wrapper is a convenient high-level wrapper that MAPP provides (on top
%of its lower-level DAEAPI API) for describing such DAEs. This wrapper hides
%low-level details of DAEAPI from you, giving you instead three simple
%functions (init_DAE, add_to_DAE, and end_DAE), with a simple and intuitive
%calling syntax, that do all the low-level work for you. TODO: To learn more,
%please see the help for these functions (particularly add_to_DAE) [TODO:
%write proper help for these functions.], or simply copy and modify the
%example(s) below].
%
%To write a DAE using DAEAPI wrapper:
%
%1. Start with
%	    DAE = init_DAE();
%2. Then put in several
%	    DAE = add_to_DAE(DAE, 'field_name', field_value);
%   statements to augment the skeleton structure.
%3. Finally, end with
%	    DAE = end_DAE(DAE);
%
%Once the DAE is set up, you can run MAPP's analyses (help MAPPanalyses) on
%it.
%
%Examples
%--------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A van der Pol like oscillator DAE (see also help van_del_Pol_ish_DAEwrapper)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   % The DAE (actually, ODE) system is:
%   % d/dt z = y
%   % d/dt y = ((1 - z^2) * y - z) * spikiness
%   %
%   % Defining x = [z; y], this can be written in MAPP's vector DAE form as:
%   % d/dt (-[z; y]) + [y; ((1 - z^2) * y - z) * spikiness] = 0
%   %       ^^^^^^^    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%   %         q(x)   +                f(x)                  = 0
%   
%   DAE = init_DAE();
%   
%   DAE = add_to_DAE(DAE, 'nameStr', 'van der Pol-like oscillator');
%   DAE = add_to_DAE(DAE, 'unkname(s)', {'z', 'y'});
%   DAE=add_to_DAE(DAE, 'eqnname(s)', {'-xdotPlusf1(z,y)', '-ydotPlusf2(z,y)'});
%   %DAE = add_to_DAE(DAE, 'inputname(s)', {}); % no inputs
%   %DAE = add_to_DAE(DAE, 'outputname(s)', {}); % no outputs defined => all
%                                                % unknowns are outputs
%   
%   DAE = add_to_DAE(DAE, 'parm(s)', {'spikiness', 10});
%   DAE = add_to_DAE(DAE, 'f_takes_inputs', 1);
%   
%   % d/dt q(x) + f(x, inputs) = 0; this is f(x, inputs)
%   f = @(S) [S.y; ((1-S.z^2)*S.y - S.z)*S.spikiness];
%   DAE = add_to_DAE(DAE, 'f', f);
%   
%   % d/dt q(x) + f(x, inputs) = 0; this is q(x)
%   q = @(S) [-S.z; -S.y];
%   DAE = add_to_DAE(DAE, 'q', q);
%   
%   C = @(DAEarg) eye(2);
%   DAE = add_to_DAE(DAE, 'C', C);
%   
%   D = @(DAEarg) sparse(2,0);
%   DAE = add_to_DAE(DAE, 'D', D);
%   
%   DAE = finish_DAE(DAE);
%   
%   check_DAE(DAE); % runs basic checks on the DAE
%
%%The van der Pol-like DAE is now defined. You can now run various analyses on
%%it (help van_der_Pol_ish_DAEwrapper). For example:
%   tr = transient(DAE, [2;0], 0, 5e-2, 20); feval(tr.plot, tr);
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% An idealized 3-stage ring oscillator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   % This is the size-3 ODE
%   %
%   %   d/dt (tau*x1(t)) = g(x3(t)) - x1(t)
%   %   d/dt (tau*x2(t)) = g(x1(t)) - x2(t)
%   %   d/dt (tau*x3(t)) = g(x2(t)) - x3(t)
%   % 
%   % where g(y) = tanh(k*y), with k < -1 for oscillation. tau and k are
%   % parameters of the DAE.
%   %
%   % In MAPP's DAE format, we have
%   %   x = [x1; x2; x3], q(x) = -tau*x, f(x) = [g(x3); g(x1); g(x2)] - x;
%   
%   % For more information on this ring oscillator, see S. Srivastava and
%   % J. Roychowdhury, “Analytical Equations for Nonlinear Phase Errors and
%   % Jitter in Ring Oscillators”, IEEE Trans. Circuits and Systems I:
%   % Fundamental Theory and Applications, Vol. 54, Issue 10, pages
%   % 2321–2329, October 2007. Downloadable from
%   % http://potol.eecs.berkeley.edu/~jr/research/PDFs/2007-10-TCAS-Srivastava-Roychowdhury-RingOscPPV.pdf
%   %
%
%   DAE = init_DAE();
%   
%   DAE = add_to_DAE(DAE, 'nameStr', 'idealized tanh ring oscillator');
%   DAE = add_to_DAE(DAE, 'unkname(s)', {'x1', 'x2', 'x3'});
%   DAE=add_to_DAE(DAE, 'eqnname(s)', {'eqn1', 'eqn2', 'eqn3'});
%   %DAE = add_to_DAE(DAE, 'inputname(s)', {}); % no inputs
%   %DAE = add_to_DAE(DAE, 'outputname(s)', {}); % no outputs defined => all
%                                                % unknowns are outputs
%   
%   DAE = add_to_DAE(DAE, 'parm(s)', {'k', -5, 'tau', 1e-3});
%   DAE = add_to_DAE(DAE, 'f_takes_inputs', 1);
%   
%   % d/dt q(x) + f(x, inputs) = 0; this is f(x, inputs)
%   f = @(S) [tanh(S.k*S.x3)-S.x1; tanh(S.k*S.x1)-S.x2; tanh(S.k*S.x2)-S.x3];
%   DAE = add_to_DAE(DAE, 'f', f);
%   
%   % d/dt q(x) + f(x, inputs) = 0; this is q(x)
%   q = @(S) -S.tau*[S.x1; S.x2; S.x3];
%   DAE = add_to_DAE(DAE, 'q', q);
%   
%   C = @(DAEarg) eye(3);
%   DAE = add_to_DAE(DAE, 'C', C);
%   
%   D = @(DAEarg) sparse(2,0);
%   DAE = add_to_DAE(DAE, 'D', D);
%   
%   DAE = finish_DAE(DAE);
%   
%   check_DAE(DAE); % runs basic checks on the DAE
%
%   % Transient simulation on this DAE
%   tr = transient(DAE, [0;0.1;0], 0, 1e-4, 20e-3); feval(tr.plot, tr);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   An LCR + nonlinear negative resistance oscillator, with injection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   % The DAE (actually, ODE) system is:
%   % C d/dt v + i + v/R + f(v) + inj(t) = 0,
%   % L d/dt i - v = 0,
%   % where f(v) = tanh(k*v), with L,C,R > 0 and k < - 1/R for oscillation;
%   % inj(t) is a current input.
%   %
%   % Defining x = [v; i], this can be written in MAPP's vector DAE form as:
%   % d/dt ([C*v; L*i]) + [i + v/R + f(v) + inj(t); -v] = 0
%   %       ^^^^^^^^^^    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%   %         q(x)   +                f(x,inputs)     = 0
%
%   DAE = init_DAE();
%
%   DAE = add_to_DAE(DAE, 'nameStr', 'LCRnegres oscillator');
%   DAE = add_to_DAE(DAE, 'unkname(s)', {'v', 'i'});
%   DAE=add_to_DAE(DAE, 'eqnname(s)', {'KCL@v', 'LBCR'});
%   DAE = add_to_DAE(DAE, 'inputname(s)', {'inj'}); % current added to node v
%
%   DAE = add_to_DAE(DAE, 'parm(s)', {'L',1e-9,'C',1e-6,'R',1e2,'k',-1.2e-2});
%   % L=1e-9, C=1e-6 => resonant frequency  = 1/(2*pi*sqrt(L*C)) = about 5MHz
%   DAE = add_to_DAE(DAE, 'f_takes_inputs', 1);
%
%   % d/dt q(x) + f(x, inputs) = 0; this is f(x, inputs)
%   f = @(S) [S.i + S.v/S.R + tanh(S.k*S.v) + S.inj; -S.v];
%   DAE = add_to_DAE(DAE, 'f', f);
%
%   % d/dt q(x) + f(x, inputs) = 0; this is q(x)
%   q = @(S) [S.C*S.v; S.L*S.i];
%   DAE = add_to_DAE(DAE, 'q', q);
%
%   DAE = add_to_DAE(DAE, 'outputname(s)', {'v'});
%   C = @(DAEarg) [1 0]; % just show the voltage
%   DAE = add_to_DAE(DAE, 'C', C);
%
%   D = @(DAEarg) sparse(2,0);
%   DAE = add_to_DAE(DAE, 'D', D);
%
%   DAE = finish_DAE(DAE);
%
%   check_DAE(DAE); % runs basic checks on the DAE
%
%   % The DAE is now defined. You can now run analyses on it. For example:
%   % first set the input transient (help set_utransient for details)
%   DAE = feval(DAE.set_utransient, 'inj', @(t, args) ...
%                       (t>10e-7).*(t<20e-7).*10.*sin(2*pi*5.2e6*t), [], DAE);
%   % run a transient analysis using the Trapezoidal method (TRAP is good for
%   % oscillator ODEs that are not too stiff)
%   tr = run_transient_TRAP(DAE, [75;0], 0, 0.02e-7, 1e-5); feval(tr.plot, tr);
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other examples of DAEAPI wrapper
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%See (type or edit):
%   BJTdiffpair_wrapper, BJTdiffpair_wrapper_with_fq, parallelRLC_wrapper,
%   damped_pendulum_DAEwrapper, nonlinear_pendulum_DAEwrapper, RCline_wrapper,
%   RLCdiode_pnjlim_wrapper, RLCdiode_pnjlim_wrapper, vsrcRC_DAEwrapper,
%   TwoReactionChainDAEAPI_wrapper, van_der_Pol_ish_DAEwrapper,
%   test_BJTdiffpair_wrapper, test_BJTdiffpair_wrapper_with_fq,
%   test_parallelRLCdiode_pnjlim_wrapper, test_parallelRLCdiode_wrapper,
%   test_parallelRLC_wrapper, test_RCline_wrapper,
%   test_tworeactionchain_wrapper_transient.
%
%
%See also
%--------
%  init_DAE, add_to_DAE, finish_DAE, check_DAE, DAEAPI_wrapper, DAEAPI.
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Author: J. Roychowdhury, 2015/07                                            %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%%               reserved.                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
