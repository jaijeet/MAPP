function  QSSobj = op(DAE, varargin)
%function  QSSobj = op(DAE, initguess, options)
%Runs a DC operating point analysis on the given DAE.
%
%DC operating point analysis (better termed Quiescent Steady State or QSS
%analysis) tries to find a constant (ie, not changing with time)
%solution of a circuit/system. The inputs to the system ("DC inputs") are set
%to be constant with respect to time prior to performing this analysis.
%
%op runs a QSS analysis on the given DAE by creating a QSS (Quiescent
%Steady State) object and calling its solve method. It returns the QSS object.
%
%Arguments:
% - DAE:       A DAEAPI object. See help DAEAPI.
%
% - initguess: (optional) initial guess for the Newton-Raphson (NR) method.
%              If not specified, the DAE's QSSinitGuess() function is used to
%              obtain an initial guess. If that is not set up properly, a
%              vector of zeros is used as a last resort (though this is
%              typically a very bad choice of initial guess for NR).
%
% - options contain NRparm names and their values
%   Available options:
%       maxiter: maximum iterations, default is 100
%       dbglvl: debug level, default is 1
%              -1  -> no output, not even errors
%               0  -> errors only 
%               1  -> minimal output, '.' per iteration
%               2  -> informative information
%       limiting: default is 1;
%       init: default is 1;
%   example for options:
%   dcop = op(DAE, 'maxiter', 100, 'dbglvl', 2);
% 
%Output:
% - QSSobj:    The QSS object created.
%
%Examples
%--------
%
% % DC on a hand-written DAE %
% DAE = vsrcRLCdiode_daeAPIv6();
% feval(DAE.inputnames, DAE)
% DAE = feval(DAE.set_uQSS, 'E', -1, DAE); % set DC value of E to -1V
% DC = op(DAE);
% % print DC operating point
% feval(DC.print, DC);
%
% % DC on a DAE derived from a circuit netlist
% DAE = MNA_EqnEngine(current_mirror_ckt());
% % DAE = feval(DAE.set_uQSS, ''I0:::I'', 2e-5, DAE); % change DC value of I0
% DC = op(DAE, 'dbglvl', 2);
% feval(DC.print, DC);
% % print all unks
% outs = StateOutputs(DAE); % help StateOutputs for full functionality
% feval(DC.print, outs, DC);
%
%
%See also
%--------
%
%  QSS, NR, dcsweep, homotopy, transient, ac




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    NRparms = defaultNRparms;
    NRparms.maxiter = 100;
    NRparms.reltol = 1e-5;
    NRparms.abstol = 1e-10;
    NRparms.residualtol = 1e-10;
    NRparms.limiting = 1;
    NRparms.init = 1;
    NRparms.dbglvl = 1; % minimal output
    NRparms.method = 1;

	%TODO: not robust, no informative error messages
	if 1 == nargin
		initguess = zeros(feval(DAE.nunks,DAE),1);
		fprintf(2,'op: warning: no initguess available for DC OP; using zero vector\n');
	elseif 2 == nargin
		initguess = varargin{1};
	else
		if strcmp('double', class(varargin{1}))
			initguess = varargin{1};
			parms = {varargin{2:end}};
		else
			initguess = zeros(feval(DAE.nunks,DAE),1);
			fprintf(2,'op: warning: no initguess available for DC OP; using zero vector\n');
			parms = varargin;
		end
		for c = 1:1:floor(length(parms)/2)
			eval(sprintf('NRparms.%s = %d;', parms{2*c-1}, parms{2*c}));
		end
	end 

	QSSobj = QSS(DAE, NRparms);
	QSSobj = feval(QSSobj.solve, initguess, QSSobj);
	[sol, iters, success] = feval(QSSobj.getSolution, QSSobj);
	if ((success <= 0) || sum(NaN == sol))
		fprintf(1, 'QSS failed on %s\nre-running with NR progress enabled\n', feval(DAE.daename, DAE));
		NRparms.dbglvl = 2;
		QSSobj = feval(QSSobj.setNRparms, NRparms, QSSobj);
		QSSobj = feval(QSSobj.solve,initguess,QSSobj);
		fprintf(1, '\naborting QSS sweep\n');
		return;
	else
		fprintf(1, '\nop (QSS) succeeded on %s\n', feval(DAE.daename, DAE));
		fprintf(1, '\nIf the returned object is QSSobj (ie, you ran QSSobj=op(...)):\n');
		fprintf(1, '- use [sol, iters, success] = feval(QSSobj.getsolution, QSSobj) to obtain the\n\t solution.\n');
		fprintf(1, '- use feval(QSSobj.print, QSSobj) to print the solution.\n');
	end
end
