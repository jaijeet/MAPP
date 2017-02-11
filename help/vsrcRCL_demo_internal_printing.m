%%------------------------------------------------------------------------------
%%Create a DAE for the ckt and run analyses (cut/paste these commands yourself)
%%-----------------------------------------------------------------------------
%
%%1. Convert the circuit into a Differential Algebraic Equation (DAE):
%    DAE = MNA_EqnEngine(cktnetlist);
%
%%2. Calculate the DC operating point of the circuit:
%      dcop = op(DAE);
%      % Print operating point information:
%      feval(dcop.print, dcop); % shows DC values for the defined outputs
%
%%3. Run a transient simulation starting from a zero initial condition:
%%   (recall that V1 has no time-changing input defined, only a DC input):
%      xinit = zeros(feval(DAE.nunks, DAE), 1); % zero-state step response
%      tstart = 0; tstep = 1e-7; tstop = 1.5e-5;                
%      TRANobj = transient(DAE, xinit, tstart, tstep, tstop);
%      % Plot transient simulation results:
%      feval(TRANobj.plot, TRANobj); % plots the defined outputs
%
%%4. Change the voltage source's input to a sine wave and re-run transient
%%   using the DC operating point calculated above as the initial condition:
%      % Display DAE's inputs:
%        feval(DAE.inputnames, DAE) % shows only one input, V1:::E
%      % Define a transient input function tranfunc() for V1:::E:
%        tranfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
%        tranfuncargs.A = 1; tranfuncargs.f = 1e5; tranfuncargs.phi = 0;
%      % Set up V1:::E's transient input to be tranfunc(). Once a transient
%      % input is set, the DC input will not be used in transient simulation
%        DAE = feval(DAE.set_utransient, 'V1:::E', tranfunc, tranfuncargs, DAE);
%      % Set the initial condition to the DC op point above
%        xinit = feval(dcop.getsolution, dcop);
%      % rerun transient simulation and plot the cktnetlist-defined outputs:
%        TRANobj = transient(DAE, xinit, tstart, tstep, tstop);
%        feval(TRANobj.plot, TRANobj);
%      % plot every circuit unknown (ie, its state vector) in another figure 
%        souts = StateOutputs(DAE);
%        feval(TRANobj.plot, TRANobj, souts);
%
%%5. Get back to MAPPquickstart_cktdemos
%    help MAPPquickstart_cktdemos;
%
%See also
%--------
% add_element, MAPPcktnetlists, MAPPanalyses, DAE_concepts, op, 
% transient, MAPPquickstart_cktdemos

%Changelog:
%2015/01/22: JR: updates to better explain what we are doing here; use of
%            StateOutputs; 2nd transient starting from DC op pt.
%Original author: Tianshi Wang (who did not bother to note this fact, nor the
%                 date, here)
