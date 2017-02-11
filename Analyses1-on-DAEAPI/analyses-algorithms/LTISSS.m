function LTISSSobj = LTISSS(DAE, QSSsol, QSSu, dont_check_uLTISSS)
%function LTISSSobj = LTISSS(DAE, QSSsol, QSSu)
%Sets up an LTISSS (Linear Time Invariant Sinusoidal Steady State, aka AC)
%analysis structure/object. The object comes equipped with direct and adjoint
%frequency domain solution methods for linear(ized) DAE systems and can be
%used for stationary noise analysis computations as well.
%
%Arguments:
%  DAE:       A DAEAPI structure/object. See help DAEAPI.
%
%  QSSsol: state value around which to linearize the DAE. Should be a vector
%       with number of entries (rows) equal to feval(DAE.nunks, DAE).
%          This should be the solution of a QSS (aka DC) analysis, obtained via
%              QSSsol = feval(QSSobj.getsolution, QSSobj);
%          after a successful QSS analysis (see help QSS, help op).
%
%  QSSu:   (needed only if DAE.f_takes_inputs == 1) The QSS (DC) inputs to the
%          DAE that led to QSSsol. These can be obtained from the DAE via:
%              QSSu = feval(DAE.uQSS, DAE);
%
%Output:
%  LTISSSobj: an LTISSS structure/object, containing the following fields:
%          .solve (function handle). Runs a frequency sweep LTISSS/AC 
%              analysis by calling LTISSS::LTISSSsolve(). 
%              help LTISSS::LTISSSsolve for more information and usage
%              details.
%
%          .getSolution (function handle). (LTISSS.getsolution is
%                 identical). 
%                 Returns the solution obtained by a successful run of 
%              LTISSSobj.solve(). Use: 
%                    [freqs, vals] = feval(LTISSSobj.getSolution, LTISSSobj);
%                 LTISSSobj.[Gg]etsolution are simply handles to
%                 LTISSS::LTISSSgetSolution(...).
%              help LTISSS::LTISSSgetSolution for further details.
%
%          .plot (function handle). Plots results of LTISSS.solve() as
%                magnitude/phase vs frequency. Basic usage examples: 
%                  feval(LTISSS.plot, LTISSSobj);
%              or
%                  feval(LTISSS.plot, LTISSSobj, StateOutputs(DAE));
%              plot is simply a handle to LTISSS::LTISSSplot();
%              there are several other useful ways of calling it.
%              help LTISSS::LTISSSplot for further details and usage
%              information.
%
%          .print (function handle). Prints results from LTISSS.solve() as a
%              table. Basic usage examples: 
%                  feval(LTISSS.print, LTISSSobj);
%              or
%                  feval(LTISSS.print, LTISSSobj, StateOutputs(DAE));
%              print is a handle to LTISSS::LTISSSprint();
%              help LTISSS::LTISSSprint for further details and usage
%              information.
%
%
%LTI Sinusoidal Steady State analysis aka 'AC' Analysis: the theory
%------------------------------------------------------------------
%
%the DAE (with noise inputs n(t)) is:
% if the flag DAE.f_takes_inputs == 0:
%
%     qdot(x, p) + f(x, p) + B*u(t) + m(x, n(t), p) = 0
%    y = C*x + D*u(t)
%
% if the flag DAE.f_takes_inputs == 1:
%
%     qdot(x, p) + f(x, u(t), p) + m(x, n(t), p) = 0
%    y = C*x + D*u(t)
%
%For LTI SSS analysis, we assume n(t)==0. Linearizing about any operating
%point (typically obtained via QSS), we have (x and y below now represent
%delta x and delta y, and u(t) represents the small-signal input):
% if the flag DAE.f_takes_inputs == 0:
%
%     d/dt(Cq*x) + Gf*x + dm_dx(xDC,n=0)*x + B*u(t) = 0
%    y = C*x + D*u(t)
%
% if the flag DAE.f_takes_inputs == 1:
%
%     d/dt(Cq*x) + Gf*x + dm_dx(xDC,n=0)*x + df_du(xDC,uQSS)*u(t) = 0
%    y = C*x + D*u(t)
%
%denoting Gm = dm_dx(xDC,n=0), M = dm_du(xDC,n=0), (and B = df_du(xDC,uQSS) if
%DAE.f_takes_inputs == 1), when we have the linearization:
%
%     d/dt(Cq*x) + (Gf+Gm)*x + B*u(t) = 0
%    y = C*x + D*u(t)
%
%The freq. domain transfer function is:
%    X(s) = - (s*Cq + Gf+Gm)^{-1}*B*U(s)  ---  (LTISSS eqn 1)
%    Y(s) = C*X(s) + D*U(s).              ---  (LTISSS eqn 2)
%
%LTISSS.solve computes and stores X(s=j*2*pi*f) for a range of supplied f.
%DAE.uLTISSS provides U(s=j*2*pi*f). 
%
%
%Examples
%--------
%
% %%%%% set up DAE and state outputs
% nsegs = 5; R = 1e3; C = 1e-6;
% DAE =  RClineDAEAPIv6('', nsegs, R, C);
% stateoutputs = StateOutputs(DAE);
% 
% %%%%% compute QSS (DC) solution
% uDC = 1; DAE = feval(DAE.set_uQSS, uDC, DAE);
% qss = QSS(DAE);
% initguess = feval(DAE.QSSinitGuess, uDC, DAE);
% qss = feval(qss.solve, initguess, qss);
% qssSol = feval(qss.getSolution, qss);
% % feval(qss.print, stateoutputs, qss);
%
% % set AC analysis input as a function of frequency
% Ufargs.string = 'no args used';; % 
% Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
% DAE = feval(DAE.set_uLTISSS, Uffunc, Ufargs, DAE);
% 
% % AC analysis @ DC operating point
% acobj = LTISSS(DAE, qssSol, uDC);
% sweeptype = 'DEC'; fstart=1; fstop=1e3; nsteps=10;
% acobj = feval(acobj.solve, fstart, fstop, nsteps, sweeptype, acobj);
% %
% % plot frequency sweeps of system outputs (overlay all on 1 plot)
% feval(acobj.plot, acobj); % by default, plots log10(mag)
% feval(acobj.plot, acobj, 'magplottype', 'lin'); % plot mag (no log)
% % plot frequency sweeps of state variable outputs (overlay on 1 plot)
% feval(acobj.plot, acobj, stateoutputs); % plots log10(mag) by default
% % plot all state variable outputs' magnitude as power dB (10*log10(mag))
% feval(acobj.plot, acobj, 'stateoutputs', stateoutputs, ...
%                                                   'magplottype', '10log10');
% % plot all state variable outputs' magnitude in voltage dB (20*log10(mag))
% feval(acobj.plot, acobj, 'stateoutputs', stateoutputs, ...
%                                                   'magplottype', '20log10');
%
%
%See also
%--------
%
% ac, set_uLTISSS, u_LTISSS, freqDomainMagPhasePlot, QSS,
% LMS, LTISSS::LTISSSsolve, LTISSS::LTISSSplot, LTISSS::LTISSSprint,
% LTISSS::LTISSSgetSolution
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Changelog:
%---------
%2014/01/30: Tianshi Wang <tianshi@berkeley.edu>: restored backward
%            compatibility with DAEAPIv6
%2013/09/15: Tianshi Wang <tianshi@berkeley.edu>: added init/limiting
%sometime ago: Jaijeet Roychowdhury <jr@berkeley.edu>






%TODO: more detailed programmer-level documentation
%In particular, the following things can be updated after a constructor call
%(eg, for use by noise analysis):
%
%LTIobj.B
%LTIobj.C
%LTIobj.D
%LTIobj.U_of_f - function handle U(f,args) - can be a vector or matrix function of f. Does NOT need to be vectorized wrt f.
%LTIobj.U_of_f_args - args for U(f, args)
%LTIobj.DAEname - used in plot/print names
%LTIobj.analysistitle - used in plot/print names
%
%
    LTISSSobj.analysistitle = 'LTISSS analysis'; % used in plot and 
                             % for messages.
    if ((nargin > 4) || (nargin < 2)) || ((0 == DAE.f_takes_inputs) && (nargin > 3))
        fprintf(2, sprintf('%s: error: too many or too few arguments.\n', LTISSSobj.analysistitle));
        help('LTISSS');
        return;
    end

    if (nargin < 4)
        dont_check_uLTISSS = 0;
    end

    if ((0 == DAE.f_takes_inputs) && (nargin == 3))
        dont_check_uLTISSS = QSSu;
    end

    if ((1 == DAE.f_takes_inputs) && (nargin < 3))
        fprintf(2, sprintf('%s: error: (1==DAE.f_takes_inputs) => third arg QSSu is mandatory.\n', ...
            LTISSSobj.analysistitle));
        help('LTISSS');
        return;
    end


    % usage and name strings
    LTISSSobj.Usage = help('LTISSS'); 
    LTISSSobj.name = 'LTI Sinusoidal Steady State solver for DAEAPIv6.2';
    %
    % precomputation and data setup
    
    LTISSSobj.Cmat = feval(DAE.dq_dx, QSSsol, DAE);
    %
    if 0 == DAE.f_takes_inputs
        LTISSSobj.B = feval(DAE.B, DAE);
        LTISSSobj.Gmat = feval(DAE.df_dx, QSSsol, DAE);
    else
        LTISSSobj.B = feval(DAE.df_du, QSSsol, QSSu, DAE);
        LTISSSobj.Gmat = feval(DAE.df_dx, QSSsol, QSSu, DAE);
    end
    if isfield(DAE, 'm') & isa(DAE.m, 'function_handle')
        nn = feval(DAE.nNoiseSources, DAE);
        LTISSSobj.Gmat = LTISSSobj.Gmat + feval(DAE.dm_dx, QSSsol, zeros(nn,1) , DAE);
    end
    LTISSSobj.C = feval(DAE.C, DAE);
    LTISSSobj.D = feval(DAE.D, DAE);

    LTISSSobj.dont_check_uLTISSS = dont_check_uLTISSS;
    if 0 == dont_check_uLTISSS
        check_zero_LTISSSinputs_and_warn(DAE); 
    end
    LTISSSobj.U_of_f = DAE.uLTISSS; % called as u_of_f(freqs, args)
    LTISSSobj.U_of_f_args = DAE;
    LTISSSobj.DAEname = feval(DAE.daename, DAE); % used in plot

    % more set up
    LTISSSobj.solution = [];
    LTISSSobj.solvalid = 0;
    LTISSSobj.DAE = DAE;
    LTISSSobj.QSSsol = QSSsol;
    if 3 == nargin
        LTISSSobj.QSSu = QSSu;
    end

    % externally callable functions
    LTISSSobj.solve = @LTISSSsolve; % (fstart, fstop, npts, ['LIN'/'DEC'])
    LTISSSobj.getSolution = @LTISSSgetSolution;
    LTISSSobj.getsolution = @LTISSSgetSolution;
    LTISSSobj.print = @LTISSSprint; % (outputsObj, LTISSSobj)
    LTISSSobj.plot = @LTISSSplot; % (outputsObj, LTISSSobj)
    LTISSSobj.updateDAE = @LTISSSupdateDAE; 

end % LTISSS "constructor"

function LTISSSout = LTISSSupdateDAE(DAE, QSSsol, LTISSSobj)
%function LTISSSout = LTISSSupdateDAE(DAE, QSSsol, LTISSSobj)
%THIS IS WRONG - TAKES A NEW QSSsol but not a new QSSu
%NEEDS FIXING. DO NOT USE.
    error('do not use LTISSSupdateDAE - there are bugs in it');
    if 2 == nargin 
        LTISSSobj = QSSsol;
        QSSsol = LTISSSobj.QSSsol;
    end
    if 2 == nargin 
        LTISSSobj = QSSsol;
        QSSsol = LTISSSobj.QSSsol;
    end
    LTISSSobj.Cmat = feval(DAE.dq_dx, QSSsol, DAE);
    %
    if 0 == DAE.f_takes_inputs
        LTISSSobj.B = feval(DAE.B, DAE);
        LTISSSobj.Gmat = feval(DAE.df_dx, QSSsol, DAE);
    else
        LTISSSobj.B = feval(DAE.df_du, QSSsol, QSSu, DAE);
        LTISSSobj.Gmat = feval(DAE.df_dx, QSSsol, QSSu, DAE);
    end
    if isfield(DAE, 'm') & isa(DAE.m, 'function_handle')
        nn = feval(DAE.nNoiseSources, DAE);
        LTISSSobj.Gmat = LTISSSobj.Gmat + feval(DAE.dm_dx, QSSsol, zeros(nn,1) , DAE);
    end
    LTISSSobj.C = feval(DAE.C, DAE);
    LTISSSobj.D = feval(DAE.D, DAE);

    LTISSSobj.U_of_f = DAE.uLTISSS; % called as u_of_f(freqs, args)
    LTISSSobj.U_of_f_args = DAE;
    LTISSSobj.DAEname = feval(DAE.daename, DAE); % used in plot
    LTISSSobj.DAE = DAE;
    LTISSSobj.QSSsol = QSSsol;

    LTISSSout = LTISSSobj;
end
% end of LTISSSupdateDAE

function ObjOut = LTISSSsolve(fstart, fstop, nsteps, sweeptype, adjoint, ...
                                                               LTISSSobj)
%function ObjOut = LTISSSsolve(fstart, fstop, nsteps, sweeptype, adjoint, ...
%                                     LTISSSobj)
%(this is a private function of LTISSS but can be accessed as LTISSSobj.solve)
%LTISSSsolve runs a frequency-sweeping LTISSS analysis on LTISSSobj.
%
%Arguments:
%  - fstart:    start frequency for the LTISSS/AC sweep.
%  - fstop:     stop frequency for the LTISSS/AC sweep.
%  - nsteps:    number of frequency steps to take (per decade if 
%               sweeptype=='DEC'; if sweeptype=='LIN', then the total number
%               of steps).
%  - sweeptype: a string: 'LIN' (for a linear frequency sweep)
%               or 'DEC' (for logarithmically spaced frequency points). 'DEC'
%            is typically preferred for Bode plots.
%  - adjoint:   (optional) either 0 or 1 (default 0). If 1, performs adjoint
%               calculations; if 0, does direct calculations.
%               TODO: further documentation of what adjoint==1 does precisely.
%  - LTISSSobj: the LTISSS structure/object
%
%Outputs:
%  - ObjOut: updated LTISSS object containing the LTISSS/AC solution.
%        The solution can be accessed via ObjOut.getsolution(),
%        ObjOut.plot() and ObjOut.print(). See: LTISSS,
%        LTISSS::LTISSSplot, LTISSS::print, LTISSS::LTISSSgetSolution.
%
%Examples
%--------
% % assuming acobj already set up by calling LTISSS (see help LTISSS)
% sweeptype = 'DEC'; fstart=1; fstop=1e3; nsteps=10;
% acobj = feval(acobj.solve, fstart, fstop, nsteps, sweeptype, acobj);
% %
% % plot frequency sweeps of system outputs (overlay all on 1 plot)
% feval(acobj.plot, acobj);
% % plot frequency sweeps of state variable outputs (overlay on 1 plot)
% feval(acobj.plot, acobj, stateoutputs);
% %print the solution for the DAE's defined outputs (via C and D)
% feval(acobj.print, acobj);
% %get solution data
% [freqs, vals] = feval(acobj.getsolution, acobj);
%
%See also
%--------
%  LTISSS
%
%

    if nargin == 5
        LTISSSobj = adjoint;
        adjoint = 0;
    end

    if (0 == LTISSSobj.dont_check_uLTISSS)
        check_zero_LTISSSinputs_and_warn(LTISSSobj.DAE); 
    end
%    Set up frequency sampling points    
    if    strcmpi(sweeptype,'LIN');
        stepsize = (fstop-fstart)/(nsteps-1);
        freqs = (fstart+[0:nsteps-1]*stepsize); 
    elseif strcmpi(sweeptype,'DEC')
        nsteps = ceil((log10(fstop)-log10(fstart))*nsteps);
        stepsize = (log10(fstop)-log10(fstart))/nsteps;
        freqs = 10.^(log10(fstart) + (0:nsteps)*stepsize);
    else
        fprintf('error: sweeptype should be LIN or DEC.\n');
    end
    LTISSSobj.freqs    = freqs;
%    End setup frequency sampling points.

%        LTISSS direct solve is: (j 2 pi f C + G) Xac = - B * uLTISSS(f)
%         LTISSS adjoint solve is: (j 2 pi f C + G)^* Xac = C^*
    B = LTISSSobj.B;
    C = LTISSSobj.C;
    LTISSSobj.solution = [];
    for i=1:length(freqs)
        % note: the DAE supports the AC input being a function of f
        if 1 == adjoint % adjoint solve
            b = C';
        else % direct solve
            b = -B*feval(LTISSSobj.U_of_f, freqs(i), LTISSSobj.DAE);
        end
        j = 0+1i; % sqrt(-1)
        w = 2*pi*freqs(i);
        Amat = (j*w*LTISSSobj.Cmat + LTISSSobj.Gmat);
        if 1 == adjoint % adjoint solve
            Amat = Amat';
        end
        LTISSSobj.solution(:,:,i) = full(Amat\b); % (:,:,i) in case 
                % b is a matrix; this also works for vectors.
    end
    LTISSSobj.solvalid = 1;
    ObjOut = LTISSSobj;
end
% end LTISSSsolve

function [freqs, vals] = LTISSSgetSolution(LTISSSobj)
%function [freqs, vals] = LTISSSgetSolution(LTISSSobj)
%Obtains the solution of an LTISSS analysis:
%      freqs: a 1-d array containing the frequencies at which LTISSS analysis
%             was run
%      vals:  a 3-d array containing LTISSS analysis data:
%             vals(:,:,freq_idx) contains X(j*2*pi*freqs(freq_idx)),
%          X(s) is given by LTISSS eqn 1 (see the theory section of
%             help LTISSS), ie, X(s) = - (s*Cq + Gf+Gm)^{-1}*B*U(s).
%
%          Note: vals(:,:,freq_idx) will be a matrix if U(s) is a matrix
%             (this is useful for adjoint/noise applications); however, for
%          "normal" LTISSS/AC analysis, U(s) is a vector, hence
%          vals(:,:,freq_idx) will be a column vector of size
%          feval(DAE.nunks, DAE).
%Examples
%--------
% % set up and run an LTISSS analysis - see the examples in help LTISSS
% [freqs, vals] = LTISSSgetSolution(LTISSSobj)
% 
%           
    if 1 == LTISSSobj.solvalid
        freqs = LTISSSobj.freqs;
        vals = LTISSSobj.solution;
    else
        fprintf(2, sprintf('LTISSSgetSolution: run solve first!\n'));
    end
end
% end LTISSSgetSolution

function LTISSSprint(LTISSSobj, stateoutputs)
%function LTISSSprint(LTISSSobj, stateoutputs)
%
%Prints the LTISSS solution as a table. (This is a private function of LTISSS,
%but is accessible via LTISSSobj.print).
%
%Arguments:
% - LTISSSobj: the LTISSS object (help LTISSS). LTISSSobj.solve() should have
%              been run.
% - stateoutputs: (optional) should be a structure of the format returned
%                 by StateOutputs(DAE). If not specified, the DAE's defined
%                 outputs (via C and D) are printed.
%
%Examples
%--------
%
% feval(LTISSSobj.print, LTISSSobj);
% feval(LTISSSobj.print, LTISSSobj, StateOutputs(DAE));
%
    if (LTISSSobj.solvalid == 1)
        DAE = LTISSSobj.DAE;
        if (nargin < 2) % plot system outputs
            % set up C, D, onames
            C = feval(DAE.C, DAE);
            D = feval(DAE.D, DAE);
            onames = feval(DAE.outputnames, DAE);
        else % print state outputs specified in stateoutputs
            % set up C, D, onames
            ninps = feval(DAE.ninputs, DAE);
            nunks = feval(DAE.nunks, DAE);

            varidxs = feval(stateoutputs.OutputIndices, ...
                                stateoutputs);
            C = sparse([]); C(length(varidxs),nunks)=0;
            for i=1:length(varidxs)
                C(i,varidxs(i)) = 1; 
            end
            D = zeros(length(varidxs), ninps);
            onames = feval(stateoutputs.OutputNames, stateoutputs);
        end

        Nfreqs = length(LTISSSobj.freqs);
        noutputs = size(C,1); % ie, no of rows of C
        
        format short;
        
        fprintf('LTISSS solution (Magnitude):\n');
        fprintf('Frequency');
        for i=1:noutputs
            fprintf('\t\t%s', onames{i});
        end
        fprintf('\n');
    
        for i=1:Nfreqs
            f = LTISSSobj.freqs(i);
            fprintf('%f\t', f);
            for k=1:noutputs
                fprintf('\t%f', ...
                   abs( C(k,:)*LTISSSobj.solution(:,:,i) ...
                        + D(k,:)*feval(LTISSSobj.U_of_f, ...
                    f, LTISSSobj.U_of_f_args) ));
            end
            fprintf('\n');
        end
        fprintf('LTISSS solution (Phase):\n');
        fprintf('Frequency');
        for    i=1:noutputs
            fprintf('\t\t%s', onames{i});
        end
        fprintf('\n');
    
        for    i=1:Nfreqs
            fprintf('%f\t', LTISSSobj.freqs(i));
            for k=1:noutputs
                fprintf('\t%f', ...
                   phase( C(k,:)*LTISSSobj.solution(:,:,i) ...
                        + D(k,:)*feval(LTISSSobj.U_of_f, ...
                        f,LTISSSobj.U_of_f_args) ));
            end
            fprintf('\n');
        end

    else
        fprintf('LTISSS: you need to run solve() first.\n');
    end
end
% end LTISSS print

function [figh, onames, colindex] = LTISSSplot(LTISSSobj, varargin)
%function [ofigh, olegends, oclrindex] = LTISSSplot(LTISSSobj, stateoutputs, ...
%                lgndprefix, linetype, figh, legends, clrindex)
%    or
%function [ofigh, olegends, oclrindex] = LTISSSplot(LTISSSobj, ...
%                'optionName1', optionVal1, 'optionName2', optionVal2, ...)
%
%produces AC analysis plots by calling freqDomainMagPhasePlot(...) after 
%argument processing. (This is a private function of LTISSS, but is accessible
%via LTISSSobj.plot.)
%
%Arguments:
% - LTISSSobj:    An LTISSS object. See help LTISSS.
%
% In the first calling syntax:
%
% - stateoutputs: (optional) a structure/object with the format of 
%                 StateOutputs(DAE) - see help StateOutputs. If not specified,
%                 or set to [], the DAE's defined outputs (y = C*x + D*u) are
%                 plotted. If specified, the selected state variables of the
%                 DAE are plotted. To plot all state variables, set it to
%                 StateOutputs(DAE).
%
% - lgndprefix:   (optional) a (typically short) string that is pre-pended
%                 to all legends. defaults to '' if unspecified or set to [].
%                 Useful when overlaying different data for the same DAE
%                 waveform.
%
% - linetype:     (optional) string indicating the line type for MATLAB's plot
%                 command - see help plot. Defaults to '.-' if not specified or
%                 set to [].
%
% - figh:         (optional) figure handle for a plot to be used. If not
%                 specified, a new plot is created. Typical use is with ofigh
%                 returned by a previous call to transientPlot.
%
% - legends:      (optional) a cell array of strings to be used as legends
%                 for existing waveforms on a previous plot with figure handle
%                 figh. Typical use is to set to olegends from a previous call
%                 of transientPlot. Should be specified if figh is specified,
%                 otherwise the legends on the plot will be wrong.
%
% - clrindex:     (optional) an integer representing the index of the colour
%                 of the first waveform. Defaults to 0 if not specified or set
%                 to [].  Used as argument to getcolorfromindex() to cycle
%                 through different colors for different waveforms. Typical use
%                 is to set to oclrindex from a previous call of transientPlot.
%
% - magplottype:  (optional) a (case-insensitive) string that determines how 
%                 the magnitude will be plotted:
%                 - 'log10': plot log10(magnitude). This is the default.
%                 - 'linear' or 'lin': plot just the magnitude.
%                 - '10log10' or 'pwrdB' or 'pdB': plot 10*log10(magnitude)
%                   - 'dB' implies '10log10'; a warning will be printed
%                 - '20log10' or 'magdB' or 'vdB': plot 20*log10(magnitude)
%    
% In the second calling syntax:
%
% Optional comma-separated pairs of optionName-optionVal arguments:
%
% - optionName: string, must be specified inside single quotes (' ').
%       Available optionNames (case-insensitive):
%          'stateoutputs'
%          'lgndprefix' or 'prefix'
%          'linetype' or 'linestyle'
%          'figh' or 'fighandle'
%          'legends'
%          'clrindex'
%          'magplottype'
% - optionVal: corresponding value for optionName, see the first calling syntax
%              for the description of available values for each optionName.
%
% You can specify several name and value pair arguments in
% any order as optionName1, optionVal1, ..., optionNameN, optionValN.
%
% Example: 'linetype', '-o', 'stateoutputs', StateOutput
%
%
%Outputs:
% - ofigh:     figure handle of the plot. Can be passed (optionally) to a
%              future call to transientPlot().
%
% - olegends:  cell array of strings, suitable for using as argument to
%              Matlab's legend() function. Can be passed (optionally) to a
%              future call to transientPlot().
%
% - oclrindex: an integer representing the index of the last colour used in
%           the current plot. Mainly useful for passing (optionally) to a
%           future call to transientPlot.
%
%Examples
%--------
%
% %%%%% set up two DAEs: 1-segment and 3-segment RC lines
% R = 1e3; C = 1e-6;
% DAE1 =  RClineDAEAPIv6('', 1, R, C);
% DAE3 =  RClineDAEAPIv6('', 3, R, C);
% 
% %%%%% compute QSS (DC) solutions
% uDC = 1; 
% DAE1 = feval(DAE1.set_uQSS, uDC, DAE1);
% DAE3 = feval(DAE3.set_uQSS, uDC, DAE3);
% qss1 = QSS(DAE1); qss1 = feval(qss1.solve, qss1);
% qss3 = QSS(DAE3); qss3 = feval(qss3.solve, qss3);
% qss1Sol = feval(qss1.getSolution, qss1);
% qss3Sol = feval(qss3.getSolution, qss3);
%
% % set AC analysis input as a function of frequency
% Ufargs.string = 'no args used';; % 
% Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
% DAE1 = feval(DAE1.set_uLTISSS, Uffunc, Ufargs, DAE1);
% DAE3 = feval(DAE3.set_uLTISSS, Uffunc, Ufargs, DAE3);
% 
% % AC analyses
% acobj1 = LTISSS(DAE1, qss1Sol, uDC);
% acobj3 = LTISSS(DAE3, qss3Sol, uDC);
% sweeptype = 'DEC'; fstart=1; fstop=1e3; nsteps=10;
% acobj1 = feval(acobj1.solve, fstart, fstop, nsteps, sweeptype, acobj1);
% acobj3 = feval(acobj3.solve, fstart, fstop, nsteps, sweeptype, acobj3);
% %
% % plot frequency sweep for acobj1 - DAE-defined outputs
% [figh, legends, clrindex] = feval(acobj1.plot, acobj1, [], ...
%                '1-segment RC', 'o-');
% % overlay frequency sweep for acobj3 - DAE-defined outputs
% [figh, legends, clrindex] = feval(acobj3.plot, acobj3, [], ...
%                '3-segment RC', '.-', figh, legends, clrindex);
% % overlay frequency sweep for acobj1 - all state variables
% sos3 = StateOutputs(DAE3);
% [figh, legends, clrindex] = feval(acobj3.plot, acobj3, sos3, ...
%                '3-segment RC', 'x-', figh, legends, clrindex);
%
% % plot again using the second calling syntax, in "voltage dB" (20*log10(mag))
% % plot frequency sweep for acobj1 - DAE-defined outputs
% [figh, legends, clrindex] = feval(acobj1.plot, acobj1, ...
%                'magplottype', 'vdb', 'lgndprefix', '1-segment RC', ...
%                'linetype', 'o-');
% % overlay frequency sweep for acobj3 - DAE-defined outputs
% [figh, legends, clrindex] = feval(acobj3.plot, acobj3, ...
%                'magplottype', 'vdb', ...
%                'lgndprefix', '3-segment RC', 'linetype', '.-', ...
%                'figh', figh, 'legends', legends, 'clrindex', clrindex);
% % overlay frequency sweep for acobj1 - all state variables
% sos3 = StateOutputs(DAE3);
% [figh, legends, clrindex] = feval(acobj3.plot, acobj3, ... 
%                'magplottype', 'vdb', ...
%                'stateoutputs', sos3, ...
%                'lgndprefix', '3-segment RC', 'linetype', 'x-', ...
%                'figh', figh, 'legends', legends, 'clrindex', clrindex);
%
%See also
%--------
%
% freqDomainMagPhasePlot, LTISSS
%
    analysistitle = LTISSSobj.analysistitle;
    
    if LTISSSobj.solvalid ~= 1
        fprintf(2, sprintf('%s: run solve first!\n', analysistitle));
        return;
    end

    DAE = LTISSSobj.DAE;

    if nargin >= 2 && ischar(varargin{1}) % second calling syntax with 'optionName'
	    % defaults
		stateoutputs = [];
		lgndprefix = '';
		linetype = '.-';
		figh = [];
		legends = {};;
		colindex = 0;
        magplottype = 'log10';

	    % assign options
		for c = 1:floor(length(varargin)/2)
			optionName = lower(varargin{2*c-1}); % make it case-insensitive
			optionVal = varargin{2*c};
			if strcmp(optionName, 'stateoutputs')
				stateoutputs = optionVal;
			elseif strcmp(optionName, 'lgndprefix') || strcmp(optionName, 'prefix')
				lgndprefix = optionVal;
			elseif strcmp(optionName, 'linetype') || strcmp(optionName, 'linestyle')
				linetype = optionVal;
			elseif strcmp(optionName, 'figh') || strcmp(optionName, 'fighandle')
				figh = optionVal;
			elseif strcmp(optionName, 'legends')
				legends = optionVal;
			elseif strcmp(optionName, 'colindex')
				colindex = optionVal;
			elseif strcmp(optionName, 'magplottype')
				magplottype = optionVal;
			end
		end


		% post-process stateoutputs to get onames
        if nargin < 2 || 0 == sum(size(stateoutputs))
            % plot DAE outputs
            C = LTISSSobj.C;
            D = LTISSSobj.D;
            onames = feval(DAE.outputnames, DAE);
        else % plot state outputs specified in stateoutputs
            % set up C, D, onames
            ninps = feval(DAE.ninputs, DAE);
            nunks = feval(DAE.nunks, DAE);
            varidxs = feval(stateoutputs.OutputIndices, stateoutputs);

            D = zeros(length(varidxs), ninps);
            C = sparse([]); C(length(varidxs), nunks)=0;
            for i=1:length(varidxs)
                C(i,varidxs(i)) = 1; 
            end
            onames = feval(stateoutputs.OutputNames, stateoutputs);
        end
    else % first syntax
        if nargin >= 2
            stateoutputs = varargin{1};
        end
        if nargin < 2 || 0 == sum(size(stateoutputs))
            % plot DAE outputs
            C = LTISSSobj.C;
            D = LTISSSobj.D;
            onames = feval(DAE.outputnames, DAE);
        else % plot state outputs specified in stateoutputs
            % set up C, D, onames
            ninps = feval(DAE.ninputs, DAE);
            nunks = feval(DAE.nunks, DAE);
            varidxs = feval(stateoutputs.OutputIndices, stateoutputs);

            D = zeros(length(varidxs), ninps);
            C = sparse([]); C(length(varidxs), nunks)=0;
            for i=1:length(varidxs)
                C(i,varidxs(i)) = 1; 
            end
            onames = feval(stateoutputs.OutputNames, stateoutputs);
        end

        if nargin >= 3
            lgndprefix = varargin{2};
        end
        if nargin < 3 || 0 == sum(size(lgndprefix))
            lgndprefix = '';
        end

        if nargin >= 4
            linetype = varargin{3};
        end
        if nargin < 4 || 0 == sum(size(linetype));
            linetype = '.-';
        end

        if nargin >= 5
            figh = varargin{4};
        end
        if nargin < 5 || 0 == sum(size(figh))
            figh = [];
        end

        if nargin >= 6
            legends = varargin{5};
        end
        if nargin < 6 || 0 == sum(size(legends))
            legends = {};;
        end

        if nargin >= 7
            colindex = varargin{6};
        end
        if nargin < 7 || 0 == sum(size(colindex))
            colindex = 0;
        end

        if nargin >= 8
            magplottype = varargin{7};
        end
        if nargin < 8 || isempty(magplottype)
            magplottype = 'log10';
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (0 == strcmp('', lgndprefix))
        for i=1:length(onames)
            onames{i} = sprintf('%s: %s', lgndprefix, onames{i});
        end
    end

    if length(legends) > 0
        onames = {legends{:}, onames{:}};
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Nfreqs = length(LTISSSobj.freqs);
    noutputs = size(C,1); % ie, no of rows of C

    for i=1:Nfreqs
        f = LTISSSobj.freqs(i);
        Ufs(:,i) = feval(LTISSSobj.U_of_f, f, LTISSSobj.U_of_f_args);
    end
    if (length( size(LTISSSobj.solution) == 3) && ...
                    size(LTISSSobj.solution,2) == 1) 
        oof = squeeze(LTISSSobj.solution);
        if 1 == size(oof, 2) 
            oof = oof.';
        end
        allHs = C*oof + D*Ufs; 
    elseif length( size(LTISSSobj.solution) == 2)
        allHs = C*LTISSSobj.solution + D*Ufs; 
    else
        fprintf(2,...
            sprintf('%s: plotting unsupported for 3-D solution array with non-singleton second dim.\n', analysistitle));
        return;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % plot loop requires: allHs; LTISSSobj.freqs; onames; analysistitle; 
    % LTISSSobj.DAEname;
    freqs = LTISSSobj.freqs;
    daename = LTISSSobj.DAEname;
    nophaseplots = 0;
    [figh, colindex] = freqDomainMagPhasePlot(freqs, allHs, ...
        onames, analysistitle, daename, nophaseplots, figh, ...
        linetype, colindex, magplottype);
    %freqDomainMagPhasePlot(freqs, allHs, onames, analysistitle, daename);
end % of LTISSSplot


function onames = LTISSSplotOld(LTISSSobj, stateoutputs)
%    Plot the AC solutions
    analysistitle = LTISSSobj.analysistitle;
    if (LTISSSobj.solvalid == 1)
        DAE = LTISSSobj.DAE;
        if (nargin < 2) % plot system outputs
            % set up C, D, onames
            C = feval(DAE.C, DAE);
            D = feval(DAE.D, DAE);
            onames = feval(DAE.outputnames, DAE);
        else % plot state outputs specified in stateoutputs
            % set up C, D, onames
            ninps = feval(DAE.ninputs, DAE);
            nunks = feval(DAE.nunks, DAE);
            D = zeros(nunks, ninps);

            varidxs = feval(stateoutputs.OutputIndices, ...
                    stateoutputs);
            C = sparse([]); C(length(varidxs), nunks)=0;
            for i=1:length(varidxs)
                C(i,varidxs(i)) = 1; 
            end
            onames = feval(stateoutputs.OutputNames, ...
                stateoutputs);
        end

        Nfreqs = length(LTISSSobj.freqs);
        noutputs = size(C,1); % ie, no of rows of C

        for i=1:Nfreqs
            f = LTISSSobj.freqs(i);
            Ufs(:,i) = feval(LTISSSobj.U_of_f, f, ...
                            LTISSSobj.U_of_f_args);
        end
        if (length( size(LTISSSobj.solution) == 3) && ...
                         size(LTISSSobj.solution,2) == 1) 
            oof = squeeze(LTISSSobj.solution);
            if 1 == size(oof, 2) 
                oof = oof.';
            end
            allHs = C*oof + D*Ufs; 
        elseif length( size(LTISSSobj.solution) == 2)
            allHs = C*LTISSSobj.solution + D*Ufs; 
        else
            fprintf(2,...
                sprintf('%s: plotting unsupported for 3-D solution array with non-singleton second dim.\n',...
                analysistitle));
            return;
        end

        plotallinone = 1; % not sure what happens if you make this zero
        % plot loop requires: allHs; LTISSSobj.freqs; onames; 
        % analysistitle; plotallinone; LTISSSobj.DAEname;
        freqs = LTISSSobj.freqs;
        daename = LTISSSobj.DAEname;
        freqDomainMagPhasePlot(freqs, allHs, onames, analysistitle, ...
                                        daename, plotallinone);
    else
        fprintf(2, sprintf('%s: run solve first!\n', analysistitle));
    end
end % LTISSS plotold

function check_zero_LTISSSinputs_and_warn(DAE)
    % probabilistic check that there are non-zero AC inputs defined
    check_freqs = [1, 10, 100, 1000, 10000, 1e5, 1e6, 1e7];
    Uoff = abs(feval(DAE.uLTISSS, 0, DAE));
    for freq = check_freqs
        Uoff = Uoff + abs(feval(DAE.uLTISSS, freq, DAE));
    end
    if 0 == sum(sum(Uoff))
        fprintf(2, '\nWarning: you seem not to have defined any DAE inputs for LTISSS.\n');
        
        fprintf(2, '  Use set_uLTISSS() to set some non-zero LTISSS inputs. Otherwise,\n');
        fprintf(2, '  LTISSS analysis will produce all-zero results.\n');
         
    end
end % check_zero_LTISSSinputs_and_warn
