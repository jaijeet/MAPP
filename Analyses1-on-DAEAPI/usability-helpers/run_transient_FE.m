function TransObjFE = run_transient_FE(DAE, xinit, tstart, tstep, tstop, ...
                                doStepControl)
%function LMSobj = run_transient_FE(DAE, xinit, tstart, tstep, ...
%                                                    tstop, doStepControl)
%
%Runs a transient analysis using the Forward Euler (FE, aka explicit Euler)
%method. Note: FE is a terrible method for general (esp. stiff) systems - it
%can become unstable, and does not work at all for DAEs with purely algebraic
%equations. Not recommended for general use - use run_transient_GEAR2,
%instead.
%
%See help dot_transient for usage instructions and examples.
%
%See also
%--------
%
% dot_transient, run_transient_GEAR2, run_transient_TRAP, run_transient_BE,
% LMS, defaultTranParms, LMSmethods.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@FErkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    TransObjBE = LMS(DAE);              % default method is BE, 
    LMStranparms = TransObjBE.tranparms; % has, eg, tranparms.NRparms
    TRmethods = LMSmethods();          % defines FE, BE, FE, and FE so far
    if (nargin > 5) && 0 == doStepControl 
      LMStranparms.stepControlParms.doStepControl = 0; % uniform timesteps only.
    end
    TransObjFE = LMS(DAE, TRmethods.FE, LMStranparms);

    if size(xinit, 1) ~= feval(DAE.nunks, DAE)
        error('dot_transient: size of xinit (=%d) not equal to the number of DAE unknowns (=%d)\n', size(xinit,1), feval(DAE.nunks, DAE));
    end
    if size(xinit, 2) ~= 1
        error('dot_transient: xinit is not a column vector; it should be.\n');
    end

    TransObjFE = feval(TransObjFE.solve, TransObjFE, xinit, tstart, ...
                                                            tstep, tstop);
end
