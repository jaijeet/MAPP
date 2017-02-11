function  LMSobj=transient(DAE, xinit, tstart, tstep, tstop, varargin)
%function LMSobj = transient(DAE, xinit, tstart, tstep, tstop, ...
%    doStepControl, 'OptionName1', OptionVal1, 'OptionName2', OptionVal2, ...)
%
%Run a transient analysis on DAE. tr(), tran(), dot_tr(), dot_tran() and 
%dot_transient are all synonyms for transient().
%
%transient runs a transient analysis on DAE with the transient simulation
%parameters specified in the arguments.  The last argument doStepControl is
%not mandatory; set it to 0 to use uniform time steps (by default, time-step
%control is enabled). 
%
%By default, transient uses the GEAR2 method, but you can choose other methods
%using the 'method' option (see below).
%
%Arguments:
%
%  - DAE:           A DAEAPI structure/object (see help DAEAPI).
%
%  - xinit:         initial condition for the time-stepping solution. Should
%                   be a column vector of the size of the DAE unknowns, ie,
%                   of size n = feval(DAE.nunks, DAE). It can also have the
%                   following special forms:
%                   - [] or the scalar 0: zeros(feval(DAE.nunks, DAE), 1)
%                     will be used
%                   - 'DC' or 'QSS': dcop() will be run first on the circuit
%                      and the DC operating point used. Equivalent to:
%                       DC = dc(DAE); % run  a DC analysis
%                       xinit = feval(DC.getsolution, DC);
%                   - 'rand': random initial condition using rand()
%                   - 'randn': random initial condition using randn()
%
%  - tstart:        start time for the simulation.
%
%  - tstop:         stop time for the simulation. 
%
%  - tstep:         initial time-step for the simulation. Can change if timestep
%                   control is enabled (see defaultTranParms). Should be
%                   less than or equal to tstop.
%
%  - doStepControl: (optional) if 1 (default), then enable step control; 
%                   if 0, then take uniform time steps
%
%  - ('OptionName', OptionVal) pairs support any field name/value for a TRparms
%                   object - for example, 'trandbglvl', 'NRparms',
%                   'stepControlParms', etc..  help defaultTranParms shows all
%                   the possibilities.
%                   
%                   Example (to use uniform time steps):
%                       TRparms = defaultTranParms();
%                       stepcontrolParms = TRparms.stepControlParms;
%                       stepcontrolParms.doStepControl = 0;
%                       LMSobj = transient(DAE, xinit, tstart, tstep, ...
%                                tstop, 'stepControlParms', stepcontrolParms);
%                       % note that the last step wil not be identical to
%                       % the previous ones if (tstop-tstart) is not an exact 
%                       % integral multiple of tstep.
%
%                   In addition to TRparms fields, you can choose the
%                   integration method using the option name
%                   'method':
%                        - 'GEAR2': (default) Gear's 2nd order stiffly stable
%                                   integration method.
%                        - 'BE':    the Backward Euler method. Note: BE is
%                                   overstable and will artificially damp, eg,
%                                   oscillators. If this is of concern, try
%                                   TRAP or GEAR2.
%                        - 'TRAP':  the Trapezoidal method. Note: Trapezoidal
%                                   can have problems with DAEs, inconsistent
%                                   initial conditions, and large timesteps in
%                                   stiff systems. If you face these, try
%                                   BE or GEAR2.
%
%                   Example:
%                     LMSobj = transient(DAE, xinit, tstart, tstep, tstop, ...
%                                'method', 'BE', 'dbglvl', 2, 'doSpeedup', 0);
%
%Output:
%  - LMSobj: an LMS (transient) object containing the transient solution, if
%            successful. Use 
%               feval(LMSobj.plot, LMSobj) 
%            to plot results, or 
%               [tpts, vals] = feval(LMSobj.getsolution, LMSobj); 
%            to obtain the timepoints and values from transient solution.
%            See help LMS for more information about LMS objects.
%
%Progress indicators:
%   . indicates each NR iteration at a timestep.
%   * indicates a successful NR solve at a timestep.
%   / indicates an unsuccessful NR solve; the timestep is cut.
%   | indicates that the timestep is because the NR iteration, though
%     successful, took too many iterations.
%   \ indicates that the timestep has been increased because NR converged
%     in very few iterations.
%
%Examples
%--------
% % set up DAE
% nsegs = 3; R = 1e3; C = 1e-6;
% DAE =  RClineDAEAPIv6('', nsegs, R, C);
% 
% % set transient input to the DAE
% utargs.A = 1; utargs.f=1e3; utargs.phi=0;
% utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
% DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);
% 
% % set up transient simulation parameters
% xinit = zeros(feval(DAE.nunks, DAE),1); 
% tstart = 0; tstep = 10e-6; tstop = 5e-3;
%
% % run the transient analysis
% LMSobj = transient(DAE, xinit, tstart, tstep, tstop);
%
% % plot transient results (only the defined DAE outputs)
% feval(LMSobj.plot, LMSobj);
%
% % get transient simulation data
% [tpts, vals] = feval(LMSobj.getsolution, LMSobj)
%
%Additional transient plotting features
%--------------------------------------
%
%LMSobj.plot(LMSobj) or feval(LMSobj.plot, LMSobj) above can take additional
%arguments and also return multiple outputs. These features are useful for,
%eg, adding custom labels to plots or for overlaying plots from multiple
%simulations.
%
%For details on these additional arguments, see transientPlot. Note that the
%first 4 arguments to transientPlot are automatically there in calls to
%LMSobj.plot(LMSobj), so you should not provide them. You may provide the
%5th and higher arguments of transientPlot as (optional) arguments to 
%feval(LMSobj.plot, LMSobj). For example:
%
% % plot transient results (all DAE state variables)
% statevars = StateOutputs(DAE);
% feval(LMSobj.plot, LMSobj, statevars);
%
% % plot transient results (defined DAE outputs) using an custom legend
% % prefix 'AA:' and line type '.-', storing the figure handle, legends and
% % color index for later use:
% [figh, legends, clridx] = feval(LMSobj.plot, LMSobj, [], 'AA', '.-');
%
%For further information, see transient_skeleton::transient_plot and
%transientPlot.
%
%See also
%--------
%
%  set_utransient, transient_skeleton::transient_plot, transientPlot, LMS,
%  StateOutputs, run_transient_GEAR2, run_transient_BE, run_transient_TRAP,
%  LMS, DAEAPI, DAE.
%            




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Changelog: 
%---------
%2016/01/22: Jaijeet Roychowdhury <jr@berkeley.edu>: added 'method' support.
%2014/08/19: Tianshi Wang <tianshi@berkeley.edu>: added 'OptionName1',
%            OptionVal1, 'OptionName2', OptionVal2, ... as inputs.
%
    TRparms = defaultTranParms;
	if 5 == nargin
		doStepControl = 1;
	elseif 6 == nargin
		doStepControl = varargin{1};
	else % nargin > 1
        if ischar(varargin{1}) % is an option name, doStepControl not provided
			doStepControl = 1;
			parms = {varargin{1:end}};
		else % doStepControl provided in varargin{1}
			doStepControl = varargin{1};
			parms = {varargin{2:end}};
		end
        if 0 ~= mod(length(parms),2)
            error('transient: odd number of option name/value pairs given; should be even');
        end
		for c = 1:1:floor(length(parms)/2)
			eval(sprintf('TRparms.%s = parms{2*c};', parms{2*c-1}));
		end
	end
    if ischar(xinit)
        if strcmpi(xinit, 'DC') || strcmp(xinit, 'QSS')
            fprintf(2, 'transient: running DC analysis to find xinit...\n');
            us_at_0 = feval(DAE.utransient, 0, DAE);
            DAE = feval(DAE.set_uQSS, us_at_0, DAE);
            DC = op(DAE); xinit = feval(DC.getsolution, DC);
        elseif strcmpi(xinit, 'rand')
            fprintf(2, 'transient: using rand() for xinit...\n');
            xinit = rand(feval(DAE.nunks, DAE), 1);
        elseif strcmpi(xinit, 'randn')
            fprintf(2, 'transient: using randn() for xinit...\n');
            xinit = randn(feval(DAE.nunks, DAE), 1);
        else
            error('transient: xinit=%s not valid.\n', xinit);
        end
    end
    if isempty(xinit) || (1==length(xinit) && 0 == xinit)
        fprintf(2, 'transient: using zero initial condition...\n');
        xinit = zeros(feval(DAE.nunks, DAE), 1);
    end
    if size(xinit, 2) == feval(DAE.nunks, DAE) && size(xinit, 1) == 1
        warning('the xinit supplied is a row vector (should be a col vector)');
        xinit = reshape(xinit, [], 1);
    end
    if size(xinit, 1) ~= feval(DAE.nunks, DAE)
        error('transient: size of xinit (=%d) not equal to the number of DAE unknowns (=%d)\n', size(xinit,1), feval(DAE.nunks, DAE));
    end
    if size(xinit, 2) ~= 1
        error('transient: xinit is not a column vector; it should be.\n');
    end
    if abs(tstep) > abs(tstop-tstart)
        fprintf(2, 'transient: |tstep|(=%g) should be <= |tstop-tstart|(=%g). Aborting transient.\n', ...
                    abs(tstep), abs(tstop-tstart));
        LMSobj = [];
        return;
    end
    TRparms.stepControlParms.doStepControl = doStepControl; % otherwise
        % doStepControl arg overwritten
    if ~isfield(TRparms, 'method') || 1 == strcmpi(TRparms.method, 'GEAR2')
	    LMSobj=run_transient_GEAR2(DAE, xinit, tstart, tstep, tstop, ...
                                    doStepControl, TRparms);
    elseif 1 == strcmpi(TRparms.method, 'BE')
	    LMSobj=run_transient_BE(DAE, xinit, tstart, tstep, tstop, ...
                                    doStepControl, TRparms);
    elseif 1 == strcmpi(TRparms.method, 'TRAP')
	    LMSobj=run_transient_TRAP(DAE, xinit, tstart, tstep, tstop, ...
                                    doStepControl, TRparms);
    else
        error('transient: method %s not supported.', TRparms.method);
    end
end % transient
