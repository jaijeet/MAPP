function QSSobj = QSS(DAE, NRparms)
%QSSobj = QSS(DAEv6, NRparms)
%
%Arguments:
%    DAE: a DAEAPIv7 object/structure describing a DAE.
%    NRparms (optional): NRparms is a structure containing the
%           fields described in defaultNRparms(). By default, QSS uses the
%           following values for NRparms' fields:
%        NRparms.maxiter: 100
%        NRparms.abstol: 1e-9
%        NRparms.reltol: 1e-4
%        NRparms.residualtol: 1e-12
%        NRparms.init: 1
%        NRparms.limiting: 1
%        NRparms.dbglvl: 1
%        NRparms.method: 1
%Output:
%    QSSobj: a QSS object/structure (with function handles defined for QSS
%        analysis on a DAE).
%
%QSSobj is a structure with the following fields:
%
% QSSobj.AFobj (structure). Algebraic Function object.
%   For documentation of AFobj see:
%        help AlgebraicFunction
%
% QSSobj.solve (function handle). Runs Newton-Raphson on the DAE's QSS
%    equations. Use: 
%    - QSSout = feval(QSSobj.solve, QSSobj)
%      - use all zeros as NR's initial guess
%    - QSSout = feval(QSSobj.solve, initguess, QSSobj)
%      - uses the supplied initial guess
%
% QSSobj.getSolution (function handle). (QSSobj.getsolution is identical).
%    Returns the solution of a completed QSS analysis. Use: 
%    [sol, iters, success] = feval(QSSobj.getSolution, QSSobj)
%      - sol: the QSS solution (the state vector x of the DAE). Last NR
%           iterate if NR unsuccessful.
%      - iters: the number of NR iterations taken to converge, or to give up.
%      - success: 1 if NR succeeded, 0 if not.
%
% QSSobj.getDCinputs (function handle).
%    Returns a column vector of all DC inputs to the DAE.
%    It just calls QSSobj.DAE.uQSS(QSSobj.DAE). It is useful for AC analysis
%    setup. Use: 
%    uDC = feval(QSSobj.getDCinputs, QSSobj)
%    dcSol = feval(QSSobj.getSolution, QSSobj)
%    acobj = ac(DAE, dcSol, uDC, ...)     See help ac.
%
% QSSobj.getOutputs (function handle). Returns the DAE's defined outputs
%    (C*x+D*u). Use: 
%    - outputvals = feval(QSSobj.getOutputs, QSSobj)
%      - if the solution is not valid, returns outputs corresponding to the
%           last NR iteration
%    
% QSSobj.getNRparms (function handle). Returns the current value of NRparms.
%    Use:
%    - NRparms = feval(QSSobj.getNRparms, QSSobj);
%
% QSSobj.setNRparms (function handle). Sets the current value of NRparms. Use:
%    - QSSobj = feval(QSSobj.setNRparms, NRparms, QSSobj);
%
% QSSobj.print (function handle). Prints the solution. Use:
%    - feval(QSSobj.print, QSSobj)
%      - prints the DAE's defined outputs (C*x + D*u).
%    - feval(QSSobj.print, stateOutputsObj, QSSobj)
%      - prints the state outputs in stateOutputsObj (see StateOutputs.m)
%
% QSSobj.updateDAE (function handle). Update the DAE in the QSS object.
%    Useful, eg, if DAE parameters or inputs have been changed.
%    - QSSobj  = feval(QSSobj.updateDAE, DAE, QSSobj)
%      - prints the DAE's defined outputs (C*x + D*u).
%
%
%Note: the DAE (with noise inputs n(t)) is:
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
%For QSS, nothing is a function of time, and n(t)==0. The above simplify
%to a nonlinear algebraic system, which is solved by QSS using NR.
%
%Examples
%--------
%  % set up DAE %
%  DAE = vsrcRLCdiode_daeAPIv6;
%  feval(DAE.inputnames, DAE)
%  DAE = feval(DAE.set_uQSS, 'E', -1, DAE); % set DC value of E to -1V
%  
%  % set up the QSS (DC) analysis
%  qss = QSS(DAE);
%  % could call functions for setting Newton parameters, etc.
%  %  eg, NRparms = QSSgetNRparms(qss); change; qss=QSSsetNRparms(NRparms, qss);
%
%  % run NR to do the QSS analysis
%  qss = feval(qss.solve, qss); % or qss = feval(qss.solve, initguess, qss);
%
%  % access/print outputs
%  xQSS = feval(qss.getSolution, qss); % get the entire state vector x
%  outvals = feval(qss.getOutputs, qss); % get the DAE's defined outputs 
%                                        % (C * x + D * u)
%  feval(qss.print, qss); % print the DAE's defined outputs (C * x + D * u)
%
%  stateoutputs = StateOutputs(DAE)
%    %stateoutputs = feval(stateoutputs.DeleteAll, stateoutputs);
%    %stateoutputs = feval(stateoutputs.Add, {'vC', 'v2'}, stateoutputs); 
%  stateoutputs = feval(stateoutputs.Delete, {'v1', 'iL', 'iE'}, stateoutputs); 
%  feval(qss.print, stateoutputs, qss); % print the outputs specified in
%                                       % stateoutputs
%
%See also
%--------
% NR, defaultNRparms, op, DAE_concepts, DAEAPI, StateOutputs, LMS, LTISSS,
% AlgebraicFunction
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% data/setup/precomputation
    if (nargin >= 3) || (nargin < 1)
        fprintf(2,'QSS: error: too many or too few arguments\n');
    end

    QSSobj.version = 'QSS for DAEAPIv6';
    %
    QSSobj.name = 'Quiescent Steady State solver for DAEAPIv6';
    QSSobj.solvalid = 0;
    QSSobj.solution = [];

    % assign NRparms
    if nargin > 1
        NRparms = optget(NRparms, defaultNRparms);
    else
        NRparms = defaultNRparms;
    end

        if NRparms.dbglvl > 1
        fprintf(1,'QSS: default NR parms: maxiter=100, reltol=1e-4, abstol=1e-9, residualtol = 1e-12.\n');
        end

% return function handles

    QSSobj.solve = @QSSsolve;
    QSSobj.getSolution = @QSSgetSolution; % kept for backward compatibiity
    QSSobj.getsolution = @QSSgetSolution;
    QSSobj.getNRparms = @QSSgetNRparms;
    QSSobj.setNRparms = @QSSsetNRparms;
    QSSobj.print = @QSSprintSolution; 
    QSSobj.updateDAE = @QSSupdateDAE; 
    QSSobj.NRparms = NRparms;
    QSSobj.DAE = DAE;
    QSSobj.getDCinputs = @(A) feval(A.DAE.uQSS, A.DAE);
    % AFobj
    QSSobj.AFobj = {};
end
% end of QSS "constructor"

function QSSout = QSSupdateDAE(DAE, QSSobj)
%function QSSout = QSSupdateDAE(DAE, QSSobj)
%This function updates the DAE field of a QSS object.
%INPUT args:
%   DAE         - input circuit DAE
%   QSSobj      - input QSS object
%OUTPUT:
%   QSSout      - output QSS object with new DAE field
    QSSobj.AFobj.DAE = DAE;
    QSSout = QSSobj;
end
% end of QSSupdateDAE

function QSSout = QSSsolve(firstarg, secondarg)
%function QSSout = QSSsolve(firstarg, secondarg)
%This function solves DAE's QSS equations using Newton Raphson.
%INPUT args:
%If nargin == 2
%   firstarg        - initial guess for NR
%   secondarg       - QSSObj
%If nargin == 1
%   firstarg        -QSSObj
%OUTPUT:
% QSSobj.solve (function handle). Runs Newton-Raphson on the DAE's QSS equations. Use: 
%    - QSSout = feval(QSSobj.solve, QSSobj)
%      - takes NR's initial guess from DAE.QSSinitGuess
%    - QSSout = feval(QSSobj.solve, initguess, QSSobj)
%      - uses the supplied initial guess.
    if 1 == nargin
        QSSobj = firstarg;
        initGuess = [];
    elseif 2 == nargin
        QSSobj = secondarg;
        initGuess = firstarg;
    end
    %
    if 0 == QSSobj.NRparms.method
        AFobj = AlgebraicFunction(@EE219A_f_df_rhs, QSSobj.DAE);
    else % if 1 == QSSobj.NRparms.method
        AFobj = AlgebraicFunction(@SPICE_f_df_rhs, QSSobj.DAE);
    end
    QSSobj.AFobj = AFobj;
    NRparms = QSSobj.NRparms;
    %
    [solution, iters, success] = NR(AFobj, NRparms, initGuess);
    %
    QSSobj.solution = solution;
    QSSobj.iters = iters;
    QSSobj.solvalid = success;
    if (success ~= 1)
        if NRparms.dbglvl > -1
            fprintf(2,'QSSsolve: failed after %d iterations\n', QSSobj.iters);
        end
    else
        if NRparms.dbglvl > 1
            fprintf(2,'QSSsolve: succeeded in %d iterations\n', QSSobj.iters);
        end
    end
    QSSout = QSSobj;
end
% end of QSSsolve

%%%%%%%%%%%%%%%%%%%%%
function [sol, iters, success] = QSSgetSolution(QSSobj)
%function [sol, iters, success] = QSSgetSolution(QSSobj)
%This function returns the solution of a completed QSS analysis.
%INPUT args:
%   QSSobj          - QSS object with complete QSS analysis solution
%
%OUTPUT:
%   sol             - the QSS solution (the state vector x of the DAE). Last NR
%                     iterate if NR unsuccessful.
%   iters           - the number of NR iterations taken to converge (or to give up).
%   success         - 1 if NR succeeded, 0 if not.
    sol = QSSobj.solution;
    iters = QSSobj.iters;
    success = QSSobj.solvalid;
    if (QSSobj.solvalid == 0)
        if QSSobj.NRparms.dbglvl > -1
            fprintf(2,'QSSgetSolution: Warning: solution not valid.\n');
        end
    end
end
% end of QSSgetSolution

%%%%%%%%%%%%%%%%%%%%%
function outputvals = QSSgetOutputs(QSSobj)
%function outputvals = QSSgetOutputs(QSSobj)
%This function returns the DAE's defined outputs (C*x+D*u). 
%INPUT args:
%   QSSobj          - QSS object with complete QSS analysis solution
%OUTPUT:
%   outputvals      - C*QSSobj.solution + D*uQSS 
%                      if the solution is not valid, returns outputs
%                      corresponding to the last NR iterate.
    DAE = QSSobj.AFobj.DAE;
    C = feval(DAE.C, DAE);
    D = feval(DAE.D, DAE);
    uQSS = feval(DAE.uQSS,DAE);
    outputvals = C*QSSobj.solution + D*uQSS;
    if (QSSobj.solvalid == 0)
        if QSSobj.NRparms.dbglvl > -1
            fprintf(2,'QSSgetOutputs: Warning: solution not valid.\n');
        end
    end
end
% end of QSSgetOutputs

%%%%%%%%%%%%%%%%%%%%%
function NRparms = QSSgetNRparms(QSSobj)
%function NRparms = QSSgetNRparms(QSSobj)
%This function returns the current value of NRparms.
%INPUT args:
%   QSSobj          - QSS object 
%OUTPUT:
%  NRparms          - QSSobj.NRparms 
    NRparms = QSSobj.NRparms;
end
% end of QSSgetNRparms

%%%%%%%%%%%%%%%%%%%%%
function QSSout = QSSsetNRparms(NRparms, QSSobj)
%function QSSout = QSSsetNRparms(NRparms, QSSobj)
%This function sets the current value of NRparms.
%INPUT args:
%   QSSobj          - QSS object 
%   NRparms         - new NRparms object 
%OUTPUT:
%   QSSout          - QSSobj with new NRprams
    QSSobj.NRparms = NRparms;
    QSSout = QSSobj;
end
% end of QSSsetNRparms

%%%%%%%%%%%%%%%%%%%%%
function QSSprintSolution(firstarg, secondarg)
%function QSSprintSolution(firstarg, secondarg)
%This function prints the QSS solution. 
%EXAMPLE:
%         - feval(QSSobj.print, QSSobj)
%            - prints the DAE's defined outputs (C*x + D*u).
%         - feval(QSSobj.print, stateOutputsObj, QSSobj)
%            - prints the state outputs in stateOutputsObj (see StateOutputs.m)
    if 1 == nargin
        QSSobj = firstarg;
        sysoutnames = feval(QSSobj.AFobj.DAE.outputnames, QSSobj.AFobj.DAE);
        C = feval(QSSobj.AFobj.DAE.C, QSSobj.AFobj.DAE);
        D = feval(QSSobj.AFobj.DAE.D, QSSobj.AFobj.DAE);
        uQSS = feval(QSSobj.AFobj.DAE.uQSS,QSSobj.AFobj.DAE);
                fprintf('QSS solution (DAE-defined outputs):\n');
        if (QSSobj.solvalid == 0)
            if QSSobj.NRparms.dbglvl > -1
                fprintf(2,'QSSprintSolution: solution not valid, not printing.\n');
            end
            return;
        end
        sol = QSSobj.solution;
        y = C*sol + D*uQSS;
                for i=1:length(sysoutnames)
                    fprintf('\t%s:\t\t%s\n', sysoutnames{i}, ...
                            num2str(y(i),'%g'));
                end
    elseif 2 == nargin
        QSSobj = secondarg;
        StateOutputsObj = firstarg;
                varidxs = feval(StateOutputsObj.OutputIndices,StateOutputsObj);
                varnames = feval(StateOutputsObj.OutputNames,StateOutputsObj);
                fprintf('QSS solution (selected state variable outputs):\n');
        if (QSSobj.solvalid == 0)
            if QSSobj.NRparms.dbglvl > -1
                fprintf(2,'QSSprintSolution: solution not valid, not printing.\n');
            end
            return;
        end
        sol = QSSobj.solution;
                for i=1:length(varidxs)
                    fprintf('\t%s:\t\t%s\n', varnames{i}, ...
                        num2str(sol(varidxs(i)), '%g'));
                end
    end
end
% end function print of class QSS

% ==================================================================================
%                        local functions
% ==================================================================================
function [out_f, out_df, out_rhs, xlimOld, success] = SPICE_f_df_rhs(x, funcparms)
%function [out_f, out_df, out_rhs, xlimOld, success] = SPICE_f_df_rhs(x, funcparms)
% TODO: placeholder for tianshi to put in description
    do_init = funcparms.do_init;
    do_limit = funcparms.do_limit;
    xlimOld = funcparms.xlimOld;
    DAE = funcparms.DAE;
    if feval(DAE.ninputs,DAE) > 0
        u = feval(DAE.uQSS, DAE);
    else
        u = [];
    end
    if 1 == DAE.support_initlimiting
        if do_init
            xlim = feval(funcparms.DAE.NRinitGuess, u, funcparms.DAE);
        elseif do_limit
            xlim = feval(funcparms.DAE.NRlimiting, x, funcparms.xlimOld, u, funcparms.DAE);
        else
            xlim = feval(funcparms.DAE.xTOxlim, x, funcparms.DAE);
        end

        if 1 == funcparms.DAE.f_takes_inputs
            fx = feval(funcparms.DAE.f, x, xlim, u, funcparms.DAE);
            dfdx = feval(funcparms.DAE.df_dx, x, xlim, u, funcparms.DAE);
            dfdxlim = feval(funcparms.DAE.df_dxlim, x, xlim, u, funcparms.DAE);
        else
            fx = feval(funcparms.DAE.f, x, xlim, funcparms.DAE);
            if feval(funcparms.DAE.ninputs, funcparms.DAE) > 0
                fx = fx + feval(funcparms.DAE.B, funcparms.DAE) * u;
            end
            dfdx = feval(funcparms.DAE.df_dx, x, xlim, funcparms.DAE);
            dfdxlim = feval(funcparms.DAE.df_dxlim, x, xlim, funcparms.DAE);
        end
        % nn = feval(QSSobj.DAE.nNoiseSources, QSSobj.DAE);
        % if nn > 0
        %     out = out + feval(QSSobj.DAE.m, x, zeros(nn,1), QSSobj.DAE);
        % end

        dxlimdx = feval(funcparms.DAE.xTOxlimMatrix, funcparms.DAE);
        out_f = fx;
        out_df = dfdx + dfdxlim * dxlimdx;
        out_rhs = [dfdx, dfdxlim] * [x; xlim] - fx;
        xlimOld = xlim;
    else
        if do_init || do_limit
            % maybe print warning/error that DAE doesn't support initlimiting
        end

        if 1 == funcparms.DAE.f_takes_inputs
            fx = feval(funcparms.DAE.f, x, u, funcparms.DAE);
            dfdx = feval(funcparms.DAE.df_dx, x, u, funcparms.DAE);
        else
            fx = feval(funcparms.DAE.f, x, funcparms.DAE);
            if feval(funcparms.DAE.ninputs, funcparms.DAE) > 0
                fx = fx + feval(funcparms.DAE.B, funcparms.DAE) * u;
            end
            dfdx = feval(funcparms.DAE.df_dx, x, funcparms.DAE);
        end
        % nn = feval(QSSobj.DAE.nNoiseSources, QSSobj.DAE);
        % if nn > 0
        %     out = out + feval(QSSobj.DAE.m, x, zeros(nn,1), QSSobj.DAE);
        % end

        out_f = fx;
        out_df = dfdx;
        out_rhs = dfdx * x - fx;
        xlimOld = [];
    end
    success = 1;
end  % end of SPICE_f_df_rhs


function [out_f, out_df, out_rhs, xlimOld, success] = EE219A_f_df_rhs(x, funcparms)
%function [out_f, out_df, out_rhs, xlimOld, success] = EE219A_f_df_rhs(x, funcparms)
% TODO: placeholder for tianshi to put in description
    do_init = funcparms.do_init;
    do_limit = funcparms.do_limit;
    xlimOld = funcparms.xlimOld;
    DAE = funcparms.DAE;
    if feval(DAE.ninputs,DAE) > 0
        u = feval(DAE.uQSS, DAE);
    else
        u = [];
    end
    if 1 == DAE.support_initlimiting
        if do_init
            xlim = feval(funcparms.DAE.NRinitGuess, u, funcparms.DAE);
        elseif do_limit
            xlim = feval(funcparms.DAE.NRlimiting, x, funcparms.xlimOld, u, funcparms.DAE);
        else
            xlim = feval(funcparms.DAE.xTOxlim, x, funcparms.DAE);
        end

        if 1 == funcparms.DAE.f_takes_inputs
            fx = feval(funcparms.DAE.f, x, xlim, u, funcparms.DAE);
            dfdx = feval(funcparms.DAE.df_dx, x, xlim, u, funcparms.DAE);
            dfdxlim = feval(funcparms.DAE.df_dxlim, x, xlim, u, funcparms.DAE);
        else
            fx = feval(funcparms.DAE.f, x, xlim, funcparms.DAE);
            if feval(funcparms.DAE.ninputs, funcparms.DAE) > 0
                fx = fx + feval(funcparms.DAE.B, funcparms.DAE) * u;
            end
            dfdx = feval(funcparms.DAE.df_dx, x, xlim, funcparms.DAE);
            dfdxlim = feval(funcparms.DAE.df_dxilm, x, xlim, funcparms.DAE);
        end
        % nn = feval(QSSobj.DAE.nNoiseSources, QSSobj.DAE);
        % if nn > 0
        %     out = out + feval(QSSobj.DAE.m, x, zeros(nn,1), QSSobj.DAE);
        % end

        if do_init
            dxlimdx = feval(funcparms.DAE.xTOxlimMatrix, funcparms.DAE);
        elseif do_limit
            if 1 == funcparms.DAE.f_takes_inputs
                dxlimdx = feval(funcparms.DAE.dNRlimiting_dx, x, xlimOld, u, funcparms.DAE);
            else
                dxlimdx = feval(funcparms.DAE.dNRlimiting_dx, x, xlimOld, funcparms.DAE);
            end
        else
            dxlimdx = feval(funcparms.DAE.xTOxlimMatrix, funcparms.DAE);
        end
        out_f = fx;
        out_df = dfdx + dfdxlim * dxlimdx;
        out_rhs = [];
        xlimOld = xlim;
    else
        if do_init || do_limit
            % maybe print warning/error that DAE doesn't support initlimiting
        end

        if 1 == funcparms.DAE.f_takes_inputs
            fx = feval(funcparms.DAE.f, x, u, funcparms.DAE);
            dfdx = feval(funcparms.DAE.df_dx, x, u, funcparms.DAE);
        else
            fx = feval(funcparms.DAE.f, x, funcparms.DAE);
            if feval(funcparms.DAE.ninputs, funcparms.DAE) > 0
                fx = fx + feval(funcparms.DAE.B, funcparms.DAE) * u;
            end
            dfdx = feval(funcparms.DAE.df_dx, x, funcparms.DAE);
        end
        % nn = feval(QSSobj.DAE.nNoiseSources, QSSobj.DAE);
        % if nn > 0
        %     out = out + feval(QSSobj.DAE.m, x, zeros(nn,1), QSSobj.DAE);
        % end

        out_f = fx;
        out_df = dfdx;
        out_rhs = [];
        xlimOld = [];
    end
    success = 1;
end  % end of 219A_f_df_rhs
