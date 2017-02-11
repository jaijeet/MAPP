function DAE = vsrcRC_DAEwrapper()
%function DAE = vsrcRC_DAEwrapper()
%
%TODO: update descriptions:
%DAE for a self-sustaining nonlinear pendulum oscillator. Incorporates
%friction- and velocity-based linear damping, as well as a restoring force to
%make it self-sustaining. The restoring force model is inspired by the
%ratchet-based mechanism used in mechanical clocks.
%
%The system equations are:
% d^2 theta/dt^2 = -g/l*sin(theta) - damping*l/m*dtheta/dt +
%                  A/m*sqrt(k1/pi)*exp(-k1*(theta-theta0)^2)*tanh(k2*dtheta/dt)
%                  + inputforcefunc(t, iffargs)/m
% - damping: pendulum''s friction-based damping constant - a nice value is 0.1.
% - l: pendulum string length (in m) - a nice value is 0.1m.
% - m: mass of pendulum (in kg) - a nice value is 0.1kg.
% - A: max amplitude of the restoring force (Newtons) - a nice value is
%      2*damping*l.
% - theta0: angle at which the impulse-like restoring force is applied (radians)
%      - a nice value is 0.
% - k1: controls how impulsive the restoring force is around theta0
%       (1/radians^2) - the greater the value, the more impulsive. A nice
%       value is 40.
% - k2: controls how quickly the restoring force saturates wrt pendulum 
%       velocity (s/radians) - the greater the value, the more quickly. A nice
%       value is 6.
% - inputforcefunc: function handle specifying a time-varying force acting on the 
%       pendulum mass. Should be callable as feval(inputforcefunc, t, iffargs)
%       If not specified, no force is applied.
% - iffargs: any arguments (other than time) to inputforcefunc. Defaults to [].
%g = 9.81m/s^2 is the acceleration due to gravity at the Earth''s surface\n\n
%
%The above equations are expressed as a size-2; the unknowns are theta and
%thetadot.
%
%Examples
%--------
%
% DAE = vsrcRC_DAEwrapper();
% 
% % set QSS value of input 'E' to be 1, calculate a DC operating point:
% DAE = DAE.set_uQSS('E', 1, DAE);
% dcop = dot_op(DAE);
% dcop.print(dcop);
% qssSol = dcop.getSolution(dcop);
% 
% % set AC analysis input as a function of frequency:
% Ufargs.string = 'no args used';; % 
% Uffunc = @(f, args) 1; % constant U(j 2 pi f) = 1
% DAE = feval(DAE.set_uLTISSS, 'E', Uffunc, Ufargs, DAE);
% 
% % run the AC analysis:
% sweeptype = 'DEC'; fstart=1e0; fstop=1e5; nsteps=10;
% uDC = feval(DAE.uQSS, DAE);
% ACobj = dot_ac(DAE, qssSol, uDC, fstart, fstop, nsteps, sweeptype);
% % plot frequency sweeps of system outputs (overlay all on 1 plot)
% feval(ACobj.plot, ACobj);
%
% % run a transient simulation:
% xinit = zeros(feval(DAE.nunks, DAE), 1); % zero-state step response
% tstart = 0; tstep = 2e-5; tstop = 5e-3;                
% TRANobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
% % plot transient simulation results:
% feval(TRANobj.plot, TRANobj);
% 

%Author: Tianshi Wang <tianshi@berkeley.edu>, 2014/08/14.
%
    DAE = init_DAE();

    DAE = add_to_DAE(DAE, 'name', 'vsrc-R-C');
    DAE = add_to_DAE(DAE, 'unkname(s)', {'e_n1'});
    DAE = add_to_DAE(DAE, 'eqnname(s)', {'KCL_n1'});
    DAE = add_to_DAE(DAE, 'inputname(s)', {'E'});
    DAE = add_to_DAE(DAE, 'outputname(s)', {'e_n1'});

    DAE = add_to_DAE(DAE, 'parm(s)', {'R', 1e3, 'C', 1e-6});

    DAE = add_to_DAE(DAE, 'f', @f);
    DAE = add_to_DAE(DAE, 'q', @q);

    DAE = finish_DAE(DAE);
end

function fout = f(S)
    % d/dt(C * e_n1) + (e_n1 - E)/R = 0
    fout = (S.e_n1 - S.E)/S.R;
end % f(...)

function qout = q(S)
    % d/dt(C * e_n1) + (e_n1 - E)/R = 0
    qout = S.C * S.e_n1;
end % q(...)
