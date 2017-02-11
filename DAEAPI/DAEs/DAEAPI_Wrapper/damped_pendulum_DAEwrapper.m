function DAE = damped_pendulum_DAEwrapper()
%function DAE = damped_pendulum_DAEwrapper()
%
%TODO: update descriptions:
%DAE for a damped pendulum. Incorporates velocity-based linear damping.
%
%The system equations are:
% d/dt(theta) = - omega
% d/dt(omega) = g/l * sin(theta) - damping/mass * omega
%
% - damping: pendulum''s friction-based damping constant - a nice value is 0.1.
% - l: pendulum string length (in m)
% - mass: pendulum's mass (in kg)
%
%g = 9.81m/s^2 is the acceleration due to gravity at the Earth''s surface\n\n
%
%Examples
%--------
%
%DAE = damped_pendulum_DAEwrapper();
%TR = tr(DAE, [pi/8; 0], 0, 0.02, 20); feval(TR.plot, TR);
%

%Author: Tianshi Wang <tianshi@berkeley.edu>, 2014/08/13.
%
    DAE = init_DAE();

    DAE = add_to_DAE(DAE, 'name', 'pendulum');
    DAE = add_to_DAE(DAE, 'unkname(s)', {'theta', 'omega'});
    DAE = add_to_DAE(DAE, 'eqnname(s)', {'thetadot', 'omegadot'});
    DAE = add_to_DAE(DAE, 'outputname(s)', {'theta'});

    DAE = add_to_DAE(DAE, 'parm(s)', {'damping', 0.1, 'g', 9.81});
    DAE = add_to_DAE(DAE, 'parm(s)', {'l', 1, 'mass', 1});

    DAE = add_to_DAE(DAE, 'f', @f);
    DAE = add_to_DAE(DAE, 'q', @q);

    DAE = add_to_DAE(DAE, 'C', @C);
    DAE = add_to_DAE(DAE, 'D', @D);

    DAE = finish_DAE(DAE);
end

function out = C(DAE)
    out = [1 0];
end

function out = D(DAE)
    out = [];
end

function fout = f(S)
    % d/dt(theta) = - omega
    % d/dt(omega) = g/l * sin(theta) - damping/mass * omega
    thetadot = + S.omega;
    omegadot = - S.g/S.l * sin(S.theta) + S.damping/S.mass * S.omega;
    fout = [thetadot; omegadot];
end % f(...)

function qout = q(S)
    % d/dt(theta) = - omega
    % d/dt(omega) = g/l * sin(theta) - damping/mass * omega
    qout = [S.theta; S.omega];
end % q(...)
