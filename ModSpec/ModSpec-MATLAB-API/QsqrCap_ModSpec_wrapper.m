function MOD = QsqrCap_ModSpec_wrapper()
%function MOD = QsqrCap_ModSpec_wrapper()
%   ModSpec (wrapper) model for negative differential capacitor:
%       q(v) = C*(v-a)^2 + b,
%   providing a -ve differential capacitance for values of v < a. The diff cap
%   is C at v-a = 0.5, 0 at v=a.
%
%   The charge q is always positive if b > 0.
%
%Parameters
%----------
%   C (default value 1e-6);
%   a (default value 1);
%   b (default value 1e-6)
%
%Examples
%--------
%   % plot q vs v
%   MOD = QsqrCap_ModSpec_wrapper(); % use the default parameters
%   vs = ((0:100)/100)*4 - 2; % linspace between -2 and 2
%   for i=1:length(vs)
%       qs(i) = feval(MOD.qe, vs(i), [], MOD);
%   end
%   plot(vs, qs, '.-'), grid on, xlabel('voltage'), ylabel('charge');
%   title('q vs v of negative differential capacitor');
%
%   % make a little RC circuit with this element
%   netlist.cktname = 'parallel RC with -ve differential capacitance';
%   netlist.nodenames = {'n1'};
%   netlist.groundnodename = 'gnd';
%   % 1K resistor between n1 and gnd
%   netlist = add_element(netlist, resModSpec(), 'R', {'n1', 'gnd'}, 1e3);
%   % -ve diff res cap between n1 and gnd - use default parameters
%   netlist = add_element(netlist, MOD, 'C(v)', {'n1', 'gnd'});
%   % make a DAE out of the netlist
%   DAE = MNA_EqnEngine('RC(v) ckt', netlist); 
%
%   % run transient on the circuit's DAE for a short time
%   xinit = 0.5; % initial condition (voltage on n1)
%   tstart = 0; tstep = 1e-5; tstop = 3.5e-4; 
%   TR = dot_transient(DAE, xinit, tstart, tstep, tstop); % run transient
%   feval(TR.plot, TR); % plot transient results: the voltage increases
%                       % and goes towards a
%
%   %run transient on the circuit's DAE for a little longer
%   %tstart = 0; tstep = 1e-5; tstop = 4e-4; 
%   %TR = dot_transient(DAE, xinit, tstart, tstep, tstop); % run transient
%   %%transient faces difficulties: cuts the time-step and never seems to
%   %%complete. Why? Because this circuit is not well-posed. Indeed, we
%   %%can show analytically that no solution exists for t> some finite
%   %%time t_escape, using only high-school calculus. The differential 
%   %%equation of the circuit is:
%   %%
%   %% d/dt q(v(t)) + v(t)/R = 0, or
%   %% d/dt [C*(v(t)-a)^2+b] = - v/R, or
%   %% 2*C*(v(t)-a)*dv(t)/dt = - v/R, or
%   %%
%   %% dv/dt = - 1/R * v(t)/[2*C*(v(t)-a)]
%   %% the right-hand-side blows up to infinity as v(t) -> a, which is
%   %% what is happening in the above simulation. Moreover, there is a
%   %% "doubly infinite" discontinuity in the RHS as x crosses a.
%   %%
%   %% The analytical solution of dx/dt = -1/k*x/(x-a) is:
%   %%  (t-t0)/k = -(x-x0) + a*ln(|x/x0|), so x is not easily expressible
%   %% in terms of t (though it might be possible to express x in terms of
%   %% t using the inverse of the Lambert W function). However, we can easily
%   %% show that no solution exists
%   %% for t > some finite value - ie, this system has a so-called finite
%   %% escape time. We show this by proving that the RHS of the above has
%   %% a maximum wrt x:
%   %% Define f(x) = -(x-x0) + a*ln(|x/x0|), then f'(x) = -1 + a/x = 0 => x=a
%   %% is an extremum. f''(a) = -a/a^2 = -1/a; if a > 0, this is -ve, hence
%   %% x=a is a maximum (not a minimum). The maximum value of f(x) is therefore
%   %%  fmax = f(x=a) = -(a-x0) + a*ln(|a/x0|).
%   %% Therefore, the maximum value of t for which it is possible to
%   %% have a solution is t_escape = t0 + k*fmax.
%   %% For our example above, we have k = 2e-3, a=1, t0=0 and x0=0.5. So
%   %% fmax = -0.5 + ln(2) = 0.1931; and t_escape = 0.3863ms or 3.863e-4s.
%   %%
%   %% This is why the simulation above is having difficulty. The failure
%   %% mechanism is that the timesteps are being cut to smaller and
%   %% smaller values as the derivative becomes larger and larger, as t
%   %% approaches t_escape. The timestep-control mechanism of the simulator
%   %% should never let t reach t_escape; eventually, the simulation will
%   %% fail with a timestep-too-small error. (If any simulator does "step
%   %% over" t_escape, it is because it has poor/inaccurate timestep control
%   %% in its transient implementation; and it will be giving you completely
%   %% wrong results).
%   %%
%   %% More generally, the finite escape time problem above will happen if
%   %% a and x0 have the same sign. If they have opposite signs, the solution
%   %% will increase without bound - which is also unphysical - but the
%   %% transient simulation should not have any problems, as shown below.
%
% run transient on the circuit's DAE with x0 negative (and a positive)
%   xinit = -0.1; % initial condition (voltage on n1)
%   tstart = 0; tstep = 1e-5; tstop = 10e-3; 
%   TR = dot_transient(DAE, xinit, tstart, tstep, tstop); % transient
%   % works fine, but the voltage becomes more and more negative, without 
%   % bound as t increases.
%   feval(TR.plot, TR); % plot transient results
%
% %% The above illustrate the kinds of pitfalls that one can encounter
% %% with even simple and innocuous-looking non-monotonic charge models.
% %% It seems clear that any q = v^p type charge model, for p>1, will
% %% potentially run into finite escape time problems and resultant transient
% %% simulation failures. Certainly for p>2,
% %% the rate at which the derivative dv/dt rises as a function of v is
% %% faster than our quadratic example above; even without solving
% %% analytically, it is apparent that timestep-too-small errors will occur.
% %% More interesting is the case where 1 < p < 2, eg, p=4/3. An analytical
% %% expression for the differential equation, if possible, might provide
% %% insight.
% %%
%
%Author: Jaijeet Roychowdhury <jr@berkeley.edu>, 2014/05/21
%   
%

	MOD = ee_model();

    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
                            % this automatically declares the branch quantities
                            % vpn, ipn
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});
    MOD = add_to_ee_model(MOD, 'parms', {'C', 1e-6});
    MOD = add_to_ee_model(MOD, 'parms', {'a', 1});
    MOD = add_to_ee_model(MOD, 'parms', {'b', 1e-6});
    MOD = add_to_ee_model(MOD, 'q', @q);

    MOD = finish_ee_model(MOD);
end

function qout = q(S)
    v2struct(S);
    qout = C*(vpn-a).^2 + b;
end
