function DAE = example_initlimiting_DAE(uniqIDstr)  % DAEAPIv7
%function DAE = example_initlimiting_DAE(uniqIDstr)  % DAEAPIv7
%This function creates an example DAE object model
% - the example describes a vsrc-RLC-diode circuit
% - DAE.support_initlimiting = 1
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'DAE1'
%
%Return values:
% - DAE:    an example DAE object
%   See DAEAPIv7_doc.m for documentation on the DAEAPIv7 functions.
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
%   DAE limited variable(s):
%   - {'vClim'}
%
% - DAE input(s):
%   - {'E'}
%
% - DAE equation(s)
%   - d/dt q(x) + f(x, u) = 0
%   - f: [- feval(diod.f, -vClim, Is, Vt) + (vC-v2)/R; % nC KCL
%         iL - (vC-v2)/R;    % n2 KCL
%         -iL + iE;          % n1 KCL
%         v1 - v2;           % L BCR
%         v1]                % E BCR, f component
%   - q: [C*vC; 0; 0; L*iL; 0]
%
% - parameters and their default values:
%   - 'R': 1
%   - 'C': 1e-06
%   - 'L': 1e-09
%   - 'Is': 1e-12
%   - 'Vt': 0.025
%
%Examples
%--------
%
% TODO 
%
%See also
%--------
% 
% DAEAPI, DAE
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Changelog:
%---------
%2014/07/27: Tianshi Wang <tianshi@berkeley.edu>: moved to be
%            example_initlimiting_DAE
%2011/09/19: Jaijeet Roychowdhury <jr@berkeley.edu>: created as vsrcRLCdiode_dae

%
%
%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
    DAE = DAEAPI_common_skeleton();
% version, help string: 
    DAE.version = 'DAEAPIv7';
    DAE.Usage = help('exampleDAE');
    if nargin < 1
        DAE.uniqIDstr = '';
    else
        DAE.uniqIDstr = uniqIDstr;
    end
    %
%data: store problem parameters, set inputs, precompute stuff
    DAE.unknameList = setup_unknames(DAE);
    DAE.eqnnameList = setup_eqnnames(DAE);
    DAE.parmnameList = setup_parmnames(DAE);
    % data: current values of parameters, can be changed by setparms
    DAE.parms = parmdefaults(DAE);

    %
    % The following 'unassigned' assignments prevent the appropriate analyses from running unless the inputs
    % are set up right. You should always keep these, and update later as appropriate.
    DAE.uQSSvec = 'unassigned'; % needed for QSS (DC analysis). Should become a real scalar/vector.
    DAE.utfunc = 'unassigned'; % needed for transient analysis. Should become a function call.
    DAE.utargs = 'unassigned'; % needed for transient analysis. Should become a structure.
    DAE.Uffunc = 'unassigned'; % needed for AC/SSS analysis. Should become a function call.
    DAE.Ufargs = 'unassigned'; % needed for AC/SSS analysis. Should become a structure

    % setting the QSS/DC input value (for the voltage source E, in this case)
    DAE.uQSSvec = -15; % DC value of input is set here. Can be updated during runtime with set_uQSS.

    % setting a transient input function (for the current source I)
    %mycos = @(t,args) cos(2*pi*args.f*t);
    %args.f = 1000;
    %DAE = set_utransient(mycos, args, DAE);
% sizes: 
    DAE.nunks = @nunks;
    DAE.neqns = @neqns;
    DAE.ninputs = @ninputs;
    DAE.noutputs = @noutputs;
    %
% f, q: 
    DAE.f_takes_inputs = 0;
    DAE.f = @f;
    DAE.q = @q;
    %
% df, dq
    DAE.df_dx = @df_dx;
    DAE.dq_dx = @dq_dx;
    %DAE.df_du = @df_du;
    %
% input-related functions
    %
    DAE.B = @B;
    %DAE.dB_dx = @dB_dx; no support yet
    %DAE.dB_dp = @dB_dp; no support yet
    %
% output-related functions
    % what makes sense here for transient, LTISSS, etc.?
    DAE.C = @C;
    %DAE.dC_dx = @dC_dx; no support yet
    %DAE.dC_dp = @dC_dp; no support yet
    DAE.D = @D;
    %DAE.dD_dx = @dD_dx; no support yet
    %DAE.dD_dp = @dD_dp; no support yet
    %
% names
    DAE.uniqID   = @uniqID;
    DAE.daename   = @daename;
    DAE.unknames  = @unknames_DAEAPI;
    DAE.eqnnames  = @eqnnames_DAEAPI;
    DAE.inputnames  = @inputnames;
    DAE.outputnames  = @outputnames;
    DAE.renameUnks = @renameUnks_DAEAPI;
    DAE.renameEqns = @renameEqns_DAEAPI;
    DAE.renameParms = @renameParms_DAEAPI;
    %
    %
% parameter support - see also input- and output-related function sections
    DAE.nparms = @nparms;
    DAE.parmdefaults  = @parmdefaults;
    DAE.parmnames = @parmnames_DAEAPI;
    DAE.getparms  = @default_getparms_DAE;
    DAE.getparms  = @default_getparms_DAE;
    DAE.setparms  = @default_setparms_DAE;
    % first derivatives with respect to parameters - for sensitivities
    %DAE.df_dp  = @df_dp;
    %DAE.dq_dp  = @dq_dp;
    %

% init and limiting support
    DAE.support_initlimiting = 1;
    DAE.limitedvarnames  = @(DAE) {'vClim'};
    DAE.NRinitGuess = @(x, u, DAE) -0.7; % size of limitedvarnames
    DAE.NRlimiting = @(x, xlimOLD, u, DAE) -pnjlim(-xlimOLD, -x(1), ...
                                   0.026, 0.6145);
    DAE.x_to_xlim_matrix = eye(1, feval(DAE.nunks,DAE));

% helper functions exposed by DAE
    DAE.internalfuncs = @internalfuncs;
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
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
    out = 5;
% end nunks(...)

function out = neqns(DAE)
    out = 5;
% end neqns(...)

function out = ninputs(DAE)
    out = 1; % E
% end ninputs(...)

function out = noutputs(DAE)
    out = nunks(DAE); % all x is the output
% end noutputs(...)

function out = nparms(DAE)
    out = 5; % {'R', 'C', 'L', 'Is', 'Vt'};
% end nparms(...)

function out = nNoiseSources(DAE)
    out = 0; % noise is not considered for this example
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
    out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
    out = sprintf('RLC tank with diode');
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
    %unknowns are: vC, v2, v1, iL, iE - in this order
    out = {'vC', 'v2', 'v1', 'iL', 'iE'};
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
    out = {'nC-KCL', 'n2-KCL', 'n1-KCL', 'L-BCR', 'E-BCR'};
% end eqnnames()

function out = inputnames(DAE)
    out = {'E'};
% end inputnames()

function out = outputnames(DAE)
    out = unknames_DAEAPI(DAE);
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
    out = {'R', 'C', 'L', 'Is', 'Vt'};
% end parmnames()

function out = NoiseSourceNames(DAE)
    out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
    parmvals = {1, 1e-6, 1e-9, 1e-12, 0.025};
    % order: {'R', 'C', 'L', 'Is', 'Vt'};
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, xlim, DAE)
    if 2 == nargin 
        DAE = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end

    vC = x(1); v2 = x(2); v1 = x(3); iL = x(4); iE = x(5);
    vClim = xlim(1);
    %oof = struct2cell(parms); % fieldnames, orderfields can be useful
    [R, C, L, Is, Vt] = deal(DAE.parms{:});

    diod = diode;

    fout(1,1) = - feval(diod.f, -vClim, Is, Vt) + (vC-v2)/R; % nC KCL
    fout(2,1) = iL - (vC-v2)/R;            % n2 KCL
    fout(3,1) = -iL + iE;                % n1 KCL
    fout(4,1) = v1 - v2;                % L BCR
    fout(5,1) = v1;                    % E BCR, f component
% end f(...)

function qout = q(x, xlim, DAE)
    if 2 == nargin 
        DAE = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end
    vC = x(1); v2 = x(2); v1 = x(3); iL = x(4); iE = x(5);
    %oof = struct2cell(parms); % fieldnames, orderfields can be useful
    [R, C, L, Is, Vt] = deal(DAE.parms{:});

    qout(1,1) = C*vC;
    qout(2,1) = 0;
    qout(3,1) = 0;
    qout(4,1) = L*iL;
    qout(5,1) = 0;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, xlim, DAE)
    if 2 == nargin 
        DAE = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end
    vC = x(1); v2 = x(2); v1 = x(3); iL = x(4); iE = x(5);
    vClim = xlim(1);
    %oof = struct2cell(DAE.parms); % fieldnames, orderfields can be useful
    [R, C, L, Is, Vt] = deal(DAE.parms{:});

    Jf = zeros(5,5);
    % x = {'vC', 'v2', 'v1', 'iL', 'iE'};
    %       1      2    3     4      5

    diod = diode;

    %fout(1,1) = -diode(-vC) + (vC-v2)/R;    % vC KCL
    [Id, Jf(1,1)] = feval(diod.f, -vClim, Is, Vt);
    Jf(1,1) = Jf(1,1) + 1/R;
    Jf(1,2) = -1/R;

    %fout(2,1) = iL - (vC-v2)/R;        % n2 KCL
    Jf(2,1) = -1/R;
    Jf(2,2) = 1/R;
    Jf(2,4) = 1;

    %fout(3,1) = -iL + iE;            % n1 KCL
    Jf(3,4) = -1;
    Jf(3,5) = 1;

    %fout(4,1) = v1 - v2;            % L BCR
    Jf(4,2) = -1;
    Jf(4,3) = 1;

    %fout(5,1) = v1 - E;            % E BCR
    Jf(5,3) = 1;
    if 2 == nargin
        Jf = Jf + ...
               feval(DAE.df_dxlim, x, xlim, DAE)...
               *feval(DAE.xTOxlimMatrix, DAE);
    end
% end df_dx(...)

function Jq = dq_dx(x, xlim, DAE)
    if 2 == nargin 
        DAE = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end
    %oof = struct2cell(parms); % fieldnames, orderfields can be useful
    [R, C, L, Is, Vt] = deal(DAE.parms{:});
    % x = {'vC', 'v2', 'v1', 'iL', 'iE'};
    %       1      2    3     4      5

    Jq = zeros(5,5);

    % qout(1,1) = C*vC;
    Jq(1,1) = C;

    % qout(4,1) = L*iL;
    Jq(4,4) = L;
    if 2 == nargin
        Jq = Jq + ...
               feval(DAE.dq_dxlim, x, xlim, DAE) ...
               *feval(DAE.xTOxlimMatrix, DAE);
    end
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
    if (nargin > 1)
       fprintf(2,'B(x, DAE) not supported yet (need tensor support first)\n');
       return;
    end
    out = zeros(neqns(DAE),ninputs(DAE));
    out(5,1) = -1; % E BCR: v1 - E = 0, E is the input u(t)
% end B(...)

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
    out = eye(nunks(DAE));;
% end C(...)

function out = D(DAE)
    out = zeros(5, 1);
% end D(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
    % in the same order as for NoiseSourceNames
    % returns a square PSD matrix of size nNoiseSources
    % NOTE: these should be one-sided PSDs
    m = nNoiseSources(DAE);
    out = speye(m);
    % unit PSDs; all the action is moved to m(x,n)
%end NoiseStationaryComponentPSDmatrix(f,DAE)

function out = m(x,n,DAE)
    % NOTE: m should be for one-sided PSDs
    % M is of size neqns. n is of size nNoiseSources
    %
    M = dm_dn(x,n,DAE);
    out = M*n;
% end m(x,n,DAE)

function Jm = dm_dx(x,n,DAE)
    n = nunks(DAE);
    Jm = sparse([]);
    Jm(n,n) = 0;
% end dm_dx(x,n,DAE)

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
% end dm_dn(x,n,DAE)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
function ifs = internalfuncs(DAE)
    ifs = 'No internal functions exposed by this DAE system.';
    %ifs.stoichmatfunc = @stoichmatfunc;
    %ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
% end internalfuncs

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
