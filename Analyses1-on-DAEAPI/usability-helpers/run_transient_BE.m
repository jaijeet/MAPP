function TransObjBE = run_transient_BE(DAE, xinit, tstart, tstep, tstop, ...
								doStepControl, TRparms)
%function LMSobj = run_transient_BE(DAE, xinit, tstart, tstep, ...
%							  tstop, doStepControl, TRparms)
%
%Runs a transient analysis using the Backward Euler (BE, aka Implicit Euler)
%method.
%
%See help transient for usage instructions and examples.
%
%See also
%--------
%
% transient, run_transient_GEAR2, run_transient_TRAP, LMS, defaultTranParms,
% LMSmethods, run_transient_FE.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TransObjBE = LMS(DAE);              % default method is BE,
    LMStranparms = TransObjBE.tranparms; % has, eg, tranparms.NRparms
    TRmethods = LMSmethods();          % defines FE, BE, TRAP, and GEAR2 so far
    if (nargin > 5)
        if isstruct(doStepControl)
            LMStranparms = doStepControl; % TRparms
        else
            LMStranparms.stepControlParms.doStepControl = doStepControl;
            if (nargin > 6)
                LMStranparms = TRparms;
            end
        end
    end
    %%%%%%%%%%%%%%% temp program for presentation, can be deleted
    %%%%%%%%%%%%%%% modified by jian
    if isfield(DAE,'doLTE')
        if DAE.doLTE==1
            LMStranparms.LTEstepControlParms.doStepControl = 1;
        else
            LMStranparms.LTEstepControlParms.doStepControl = 0;
        end
    end
    %%%%%%%%%%%%%%%%

	TransObjBE = LMS(DAE, TRmethods.BE, LMStranparms);

    if size(xinit, 1) ~= feval(DAE.nunks, DAE)
        error('run_transient_BE: size of xinit (=%d) not equal to the number of DAE unknowns (=%d)\n', size(xinit,1), feval(DAE.nunks, DAE));
    end
    if size(xinit, 2) ~= 1
        error('run_transient_BE: xinit is not a column vector; it should be.\n');
    end

	TransObjBE = feval(TransObjBE.solve, TransObjBE, ...
			                xinit, tstart, tstep, tstop);
end

