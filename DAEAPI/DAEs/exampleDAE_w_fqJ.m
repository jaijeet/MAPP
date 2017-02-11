function DAE = exampleDAE_w_fqJ() 
%function DAE = exampleDAE_w_fqJ()
%This is an example to illustrate how to set up a DAE using fqJ.
% - using a vsrc-RLC-diode circuit.
% - help DAEAPI describes the various functions defined in this file.
% - Read the code within (ie, UTSL).
%
%Return values:
% - DAE: the DAE.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit:
%
% unknowns are: vC, v2, v1, iL, iE
% MNA equations are:
%
%    C dvC/dt - diode(-vC) + (vC-v2)/R = 0
%    iL + (v2-vC)/R = 0
%    -iL + iE = 0
%     L diL/dt = v2-v1
%    v1 - E = 0
%
% E is the input (QSS only defined). The entire state vector x is the output.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%DAE information
%-----------------
%
% - DAE unknown(s):
%   - {'vC', 'v2', 'v1', 'iL', 'iE'}
%
% - DAE input(s):
%   - {'E'}
%
% - DAE equation(s)
%   - d/dt q(x) + f(x, u) = 0
%   - f: [- feval(diod.f, -vC, Is, Vt) + (vC-v2)/R; % nC KCL
%         iL - (vC-v2)/R;    % n2 KCL
%         -iL + iE;          % n1 KCL
%         v1 - v2;           % L BCR
%         v1 - E]            % E BCR, f component
%   - q: [C*vC; 0; 0; L*iL; 0]
%
% - parameters and their default values:
%   - 'R': 1
%   - 'C': 1e-06
%   - 'L': 1e-09
%   - 'Is': 1e-12
%   - 'Vt': 0.025
%
%Example
%-------
%
% DAE = exampleDAE_w_fqJ();
% check_DAE(DAE);
%
% % DC analysis
% DAE = feval(DAE.set_uQSS, -1, DAE);
% OP = op(DAE);
% feval(OP.print, OP);
%
% % AC analysis at DC operating point
% dcsol = feval(OP.getsolution, OP);
% uDC = feval(DAE.uQSS, DAE);
% DAE = feval(DAE.set_uLTISSS, @(f,args) 1, [], DAE); % set AC value for input
% AC = ac(DAE, dcsol, uDC, 1, 1e4, 10, 'DEC');
% feval(AC.plot, AC);
%
% % transient analysis starting from DC op pt
% tranfunc = @(t, args) -1 + pulse(t/0.1, 0, 0.1, 0.5, 0.6);
% DAE = feval(DAE.set_utransient, tranfunc, [], DAE); % set transient input
% TR = transient(DAE, dcsol, 0, 0.001, 0.3);
% feval(TR.plot, TR);
%
%See also
%--------
% 
% DAEAPI
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Changelog:
%---------

%
%
%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
    DAE = DAEAPI_common_skeleton();
% version, help string: 
    DAE.Usage = help('exampleDAE_w_fqJ');
    %

    % setting the QSS/DC input value (for the voltage source E, in this case)
    DAE.uQSSvec = -15; % DC value of input is set here. Can be updated during runtime with set_uQSS.

% sizes: 
    DAE.nunks = @nunks;
    DAE.neqns = @neqns;
    DAE.ninputs = @ninputs;
    DAE.noutputs = @noutputs;
    %
% f, q: 
    DAE.f_takes_inputs = 1;
    DAE.f = @f;
    DAE.q = @q;
    DAE.fq = @fq;
    %
% df, dq
    DAE.df_dx = @df_dx;
    DAE.dq_dx = @dq_dx;
    DAE.df_du = @df_du;
    DAE.fqJ = @fqJ;
    %
% input-related functions
    %
    DAE.B = @B;
    %
% output-related functions
    DAE.C = @C;
    DAE.D = @D;
    %
% names
    DAE.daename   = @daename;
    DAE.unknames  = @unknames;
    DAE.eqnnames  = @eqnnames;
    DAE.inputnames  = @inputnames;
    DAE.outputnames  = @outputnames;
    %
    %
% parameter support - see also input- and output-related function sections
    DAE.nparms = @nparms;
    DAE.parmdefaults  = @parmdefaults;
    DAE.parmnames = @parmnames;
    % first derivatives with respect to parameters - for sensitivities
    %DAE.df_dp  = @df_dp;
    %DAE.dq_dp  = @dq_dp;
    %

% init and limiting functions

% helper functions exposed by DAE
    %
% functions for supporting noise
    % 
    DAE.nNoiseSources = @nNoiseSources;
    DAE.NoiseSourceNames = @NoiseSourceNames;
    DAE.NoiseStationaryComponentPSDmatrix = 'undefined'; % @NoiseStationaryComponentPSDmatrix;
    DAE.m = 'undefined'; % @m;
    DAE.dm_dx = 'undefined'; % @dm_dx;
    DAE.dm_dn = 'undefined'; % @dm_dn;
%
end % DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
    out = 5;
end % nunks(...)

function out = neqns(DAE)
    out = 5;
end % neqns(...)

function out = ninputs(DAE)
    out = 1; % E
end % ninputs(...)

function out = noutputs(DAE)
    out = nunks(DAE); % all x is the output
end % noutputs(...)

function out = nparms(DAE)
    out = 5; % {'R', 'C', 'L', 'Is', 'Vt'};
end % nparms(...)

function out = nNoiseSources(DAE)
    out = 0; % noise is not considered for this example
end % nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
    out = DAE.uniqIDstr;
end % uniqID()

function out = daename(DAE)
    out = sprintf('RLC tank with diode');
end % daename()

function out = unknames(DAE)
    %unknowns are: vC, v2, v1, iL, iE - in this order
    out = {'vC', 'v2', 'v1', 'iL', 'iE'};
end % unknames()

function out = eqnnames(DAE)
    out = {'nC-KCL', 'n2-KCL', 'n1-KCL', 'L-BCR', 'E-BCR'};
end % eqnnames()

function out = inputnames(DAE)
    out = {'E'};
end % inputnames()

function out = outputnames(DAE)
    out = unknames(DAE);
end % outputnames()

function out = parmnames(DAE)
    out = {'R', 'C', 'L', 'Is', 'Vt'};
end % parmnames()

function out = NoiseSourceNames(DAE)
    out = {};
end % NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
    parmvals = {1, 1e-6, 1e-9, 1e-12, 0.025};
    % order: {'R', 'C', 'L', 'Is', 'Vt'};
end % parmdefaults(...)

%%%%%%%%%%%%% CORE FUNCTIONS AND DERIVATIVES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fqJout = fqJ(x, u, flags, DAE)
    % flags will have (0 or 1): .f, .q, .dfdx, .dqdx, .dfdu
    % fqJout should set:        .f, .q, .dfdx, .dqdx, .dfdu
    %
    vC = x(1); v2 = x(2); v1 = x(3); iL = x(4); iE = x(5);
    parms = parmdefaults(DAE);
    [R, C, L, Is, Vt] = deal(parms{:});

    diod = diode();

    if 1 == flags.f || 1 == flags.dfdx
        [Id, dId] = feval(diod.f, -vC, Is, Vt);
    end
    
    % f
    if 1 == flags.f
        E = u(1);
        fqJout.f(1,1) = - Id + (vC-v2)/R; % nC KCL
        fqJout.f(2,1) = iL - (vC-v2)/R;            % n2 KCL
        fqJout.f(3,1) = -iL + iE;                % n1 KCL
        fqJout.f(4,1) = v1 - v2;                % L BCR
        fqJout.f(5,1) = v1 - E;                 % E BCR, f component
    end 

    % q

    if 1 == flags.q
        fqJout.q(1,1) = C*vC;
        fqJout.q(2,1) = 0;
        fqJout.q(3,1) = 0;
        fqJout.q(4,1) = L*iL;
        fqJout.q(5,1) = 0;
    end

    % dfdx
    if 1 == flags.dfdx
        fqJout.dfdx = zeros(5,5);
        % x = {'vC', 'v2', 'v1', 'iL', 'iE'};
        %       1      2    3     4      5

        %fout(1,1) = -diode(-vC) + (vC-v2)/R;    % vC KCL
        fqJout.dfdx(1,1) = dId + 1/R;
        fqJout.dfdx(1,2) = -1/R;

        %fout(2,1) = iL - (vC-v2)/R;        % n2 KCL
        fqJout.dfdx(2,1) = -1/R;
        fqJout.dfdx(2,2) = 1/R;
        fqJout.dfdx(2,4) = 1;

        %fout(3,1) = -iL + iE;            % n1 KCL
        fqJout.dfdx(3,4) = -1;
        fqJout.dfdx(3,5) = 1;

        %fout(4,1) = v1 - v2;            % L BCR
        fqJout.dfdx(4,2) = -1;
        fqJout.dfdx(4,3) = 1;

        %fout(5,1) = v1 - E;            % E BCR
        fqJout.dfdx(5,3) = 1;
    end

    if 1 == flags.dqdx
        % Jq
        fqJout.dqdx = zeros(5,5);

        % qout(1,1) = C*vC;
        fqJout.dqdx(1,1) = C;

        % qout(4,1) = L*iL;
        fqJout.dqdx(4,4) = L;
    end

    if 1 == flags.dfdu
        fqJout.dfdu = zeros(5,1);
        fqJout.dfdu(5,1) = -1;
    end
end %fqJ

function [fout, qout] = fq(x, u, flags, DAE)
    flags.f = 1; flags.q = 1; flags.dfdx = 0; flags.dqdx = 0; flags.dfdu = 0;
    fqJout = fqJ(x, u, flags, DAE);
    fout = fqJout.f;
    qout = fqJout.q;
end

function fout = f(x, u, DAE)
    flags.f = 1; flags.q = 0; flags.dfdx = 0; flags.dqdx = 0; flags.dfdu = 0;
    fqJout = fqJ(x, u, flags, DAE);
    fout = fqJout.f;
end % f(...)

function qout = q(x, DAE)
    flags.f = 0; flags.q = 1; flags.dfdx = 0; flags.dqdx = 0; flags.dfdu = 0;
    fqJout = fqJ(x, [], flags, DAE);
    qout = fqJout.q;
end % q(...)

function Jf = df_dx(x, u, DAE)
    flags.f = 0; flags.q = 0; flags.dfdx = 1; flags.dqdx = 0; flags.dfdu = 0;
    fqJout = fqJ(x, u, flags, DAE);
    Jf = fqJout.dfdx;
end % df_dx(...)

function Jq = dq_dx(x, DAE)
    flags.f = 0; flags.q = 0; flags.dfdx = 0; flags.dqdx = 1; flags.dfdu = 0;
    fqJout = fqJ(x, [], flags, DAE);
    Jq = fqJout.dqdx;
end % dq_dx(...)

function Jfu = df_du(x, u, DAE)
    flags.f = 0; flags.q = 0; flags.dfdx = 0; flags.dqdx = 0; flags.dfdu = 1;
    fqJout = fqJ(x, u, flags, DAE);
    Jfu = fqJout.dfdu;
end % df_du(...)


%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
    out = []; % should not be used since f_takes_inputs = 1
end % B(...)

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
    out = eye(nunks(DAE));;
end % C(...)

function out = D(DAE)
    out = zeros(5, 1);
end % D(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
    % in the same order as for NoiseSourceNames
    % returns a square PSD matrix of size nNoiseSources
    % NOTE: these should be one-sided PSDs
    m = nNoiseSources(DAE);
    out = speye(m);
    % unit PSDs; all the action is moved to m(x,n)
end %NoiseStationaryComponentPSDmatrix(f,DAE)

function out = m(x,n,DAE)
    % NOTE: m should be for one-sided PSDs
    % M is of size neqns. n is of size nNoiseSources
    %
    M = dm_dn(x,n,DAE);
    out = M*n;
end % m(x,n,DAE)

function Jm = dm_dx(x,n,DAE)
    n = nunks(DAE);
    Jm = sparse([]);
    Jm(n,n) = 0;
end % dm_dx(x,n,DAE)

function M = dm_dn(x,n,DAE)
    % M is of size neqns. n is of size nNoiseSources
    % NOTE: M should be for one-sided PSDs
    %
    k = 1.3806503e-23; % Boltzmann's const
    q = 1.60217646e-19; % electronic charge
    T = 300; % Kelvin; absolute temperature FIXME: this should be a parameter

    n = nunks(DAE);
    nn = nNoiseSources(DAE);
    M = sparse([]); M(nsegs,nsegs) = 0;
    M = M*sqrt(4*k*T/R);
end % dm_dn(x,n,DAE)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
function ifs = internalfuncs(DAE)
    ifs = 'No internal functions exposed by this DAE system.';
    %ifs.stoichmatfunc = @stoichmatfunc;
    %ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
end % internalfuncs

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
