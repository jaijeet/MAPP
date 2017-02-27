function NRparms = defaultNRparms()
%function NRparms = defaultNRparms()
%Returns default parameters for the Newton Raphson algorithm:
%   NRparms.maxiter (default 50)
%   NRparms.reltol (default 1e-6)
%   NRparms.abstol (default 1e-12)
%   NRparms.residualtol (default 1e-12)
%   NRparms.MPPINR_use_pinv (default 0 => always use mldivide (\); 
%       can be 1 => use pinv if Jacobian non-square)
%   NRparms.init (default 1; can be 0)
%       1: do NR initialization using DAE.NRinitGuess
%   NRparms.limiting (default 1; can be 0)
%       1: do NR limiting via DAE.NRlimiting()
%   NRparms.terminating_newline (default 1; can be 0)
%       1: print a newline after the final * if NR succeeds
%       0: don't print a newline (useful for, eg, LMS)
%   NRparms.dbglvl (default 1; can be -1, 0, 1 and 2)
%       -1: print nothing (not even errors)
%       0: only print errors.
%       1: print . per NR iteration to indicate progress
%       2: print x, dx, g, etc. at each NR iteration
%   NRparms.method (default 1; can be 0)
%       0: df(x) dx = -f(x)
%       1: df(x) x  = RHS(x)  SPICE-like
%   NRparms.xscaling (default 1)
%       - a scalar number, or a vector of the size of x.
%         norm(x./xscaling) is used for evaluating convergence.
%   NRparms.residualscaling (default 1)
%       - a scalar number, or a vector of the size of f(x).
%         norm(f(x)./residualscaling) is used for evaluating convergence.
%
%Examples
%--------
%
%NRparms = defaultNRparms();
%NRparms.reltol=1e-3;
%NRparms.abstol=1e-7;
%NRparms.dbglvl=2;
%
%ghandle = @(x, args) x^2-4;
%dghandle = @(x, args) 2*x;
%[sol, iters, success] = NR(ghandle, dghandle, 3, [], NRparms);
%
%
%See also
%--------
%
%   NR, defaultTranParms
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    NRparms.maxiter=50;
    NRparms.reltol=1e-6;
    NRparms.abstol=1e-12;
    NRparms.residualtol=1e-12;
    NRparms.MPPINR_use_pinv=0; % ie, use mldivide
    NRparms.init = 1;
    NRparms.limiting = 1;
    NRparms.terminating_newline = 1;
    NRparms.dbglvl=1;
    NRparms.method=1;
    NRparms.xscaling=1;
    NRparms.residualscaling=1;
end
