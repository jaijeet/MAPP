function DAE = nonlinear_pendulum_DAEwrapper(damping, l, m, A, theta0, k1, k2, inputforcefunc, iffargs)
%function DAE = nonlinear_pendulum_DAEwrapper(damping, l, m, A, theta0, ...
%                                              k1, k2, inputforcefunc, iffargs)
%
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
%%ideal undamped nonlinear pendulum, no restoring force
%DAE = nonlinear_pendulum_DAEwrapper();
%TR = tr(DAE, [pi/4; 0], 0, 0.01, 10); feval(TR.plot, TR);
%
%%damped nonlinear pendulum, no restoring force
%DAE = nonlinear_pendulum_DAEwrapper(0.1);
%TR = tr(DAE, [pi/4; 0], 0, 0.01, 10); feval(TR.plot, TR);
%
%%self-sustaining oscillator (ie, damping + restoring force)
%DAE = nonlinear_pendulum_DAEwrapper(0.1, [], [], 0.04);
%TR = tr(DAE, [pi/10; 0], 0, 0.01, 10); feval(TR.plot, TR, StateOutputs(DAE));
%TR = tr(DAE, [pi/7; 0], 0, 0.01, 20); feval(TR.plot, TR, StateOutputs(DAE));
%
%

%
%Author: J. Roychowdhury <jr@berkeley.edu>, 2014/07/25.
%
    if nargin < 7
        help('nonlinear_pendulum_DAEwrapper');
    end

    if nargin < 1 || isempty(damping)
        fprintf(2, 'setting damping to 0 (ie, undamped)\n');
        fprintf(2, '  (a nice value for damping is 0.1).\n');
        damping = 0;
    end
    if nargin < 2 || isempty(l)
        fprintf(2, 'setting l (length) to 0.1m.\n');
        l = 0.1;
    end
    if nargin < 3 || isempty(m)
        fprintf(2, 'setting m (mass) to 0.1kg.\n');
        m = 0.1;
    end
    if nargin < 4 || isempty(A)
        fprintf(2, 'setting A (max restoring force amplitude) to 0.\n');
        fprintf(2, '  (a nice value for A is 2*damping*l).\n');
        A = 0;
    end
    if nargin < 5 || isempty(theta0)
        fprintf(2, 'setting theta0 (angle at which restoring force is applied) to 0.\n');
        fprintf(2, '  (a nice value for theta0 is 0).\n');
        theta0 = 0;
    end
    if nargin < 6 || isempty(k1)
        fprintf(2, 'setting k1 (restoring force impulsiveness) to 40\n');
        fprintf(2, '  (a nice value for k1 is 40).\n');
        k1 = 40;
    end
    if nargin < 7 || isempty(k2)
        fprintf(2, 'setting k2 (restoring force saturation) to 1.\n');
        fprintf(2, '  (a nice value for k2 is 1).\n');
        k2 = 1;
    end
    if nargin < 8 || isempty(inputforcefunc)
        fprintf(2, 'setting inputforcefunc to [].\n');
        inputforcefunc = @(t, args) 0;
    end
    if nargin < 9 || isempty(iffargs)
        fprintf(2, 'setting iffargs to [].\n');
        iffargs = [];
    end
    
	DAE = init_DAE();

	DAE = add_to_DAE(DAE, 'name', 'nonlinear pendulum');
	DAE = add_to_DAE(DAE, 'unkname(s)', {'theta', 'thetadot'});
	DAE = add_to_DAE(DAE, 'eqnname(s)', {'thetaddot', 'thetadotdefn'});
	DAE = add_to_DAE(DAE, 'inputname(s)', {'inputForce'});
	DAE = add_to_DAE(DAE, 'outputname(s)', {'theta'});
	DAE = add_to_DAE(DAE, 'parm(s)', {'l', l, 'g', 9.81, 'mass', m, ...
                                                    'damping', damping, ...
                                                    'A', A, ...
                                                    'theta0', theta0, ...
                                                    'k1', k1, ...
                                                    'k2', k2 });
	DAE = add_to_DAE(DAE, 'B', @B);
	DAE = add_to_DAE(DAE, 'C', @C);
	DAE = add_to_DAE(DAE, 'D', @D);

	DAE = add_to_DAE(DAE, 'f_takes_inputs', 1);
	DAE = add_to_DAE(DAE, 'f', @f);
	DAE = add_to_DAE(DAE, 'q', @q);
    
	DAE = finish_DAE(DAE);

    DAE = feval(DAE.set_utransient,'inputForce', inputforcefunc, iffargs, DAE);
end

function out = B(S)
	out = [];
end

function out = C(DAE)
	out = [1 0];
end

function out = D(DAE)
	out = [];
end

function fout = f(S)
	% d/dt(thetadot) = -g/l*sin(theta) - damping*l/m*thetadot +
    %      A/m*sqrt(k1/pi)*exp(-k1*(theta-theta0)^2)*tanh(k2*thetadot)
    % => d/dt(thetadot) + g/l*sin(theta) + damping*l/m*thetadot 
    %    - A/m*sqrt(k1/pi)*exp(-k1*(theta-theta0)^2)*tanh(k2*thetadot) = 0
	thetaddotterm = S.g/S.l*sin(S.theta) + S.damping*S.l/S.mass*S.thetadot - ...
                    S.A/S.mass*sqrt(S.k1/pi)*exp(-S.k1*(S.theta-S.theta0)^2) ...
                    *tanh(S.k2*S.thetadot) + S.inputForce/S.mass;

	% thetadot = d/dt(theta) => d/dt(theta) - thetadot = 0.
	thetadotdefnterm = -S.thetadot;
	fout = [thetaddotterm; thetadotdefnterm];
end % f(...)

function qout = q(S)
	% d/dt(thetadot) = -g/l * sin(theta) + k*l/m * thetadot + ...
    % => d/dt(thetadot) +g/l * sin(theta) - k*l/m * thetadot - ... = 0
	thetaddotterm = S.thetadot;

	% thetadot = d/dt(theta) => d/dt(theta) - thetadot = 0.
	thetadotdefnterm = S.theta;
	qout = [thetaddotterm; thetadotdefnterm];
end % q(...)
