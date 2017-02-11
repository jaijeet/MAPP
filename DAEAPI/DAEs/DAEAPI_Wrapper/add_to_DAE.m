function out = add_to_DAE(DAE, field_name, field_value)
%function DAE = add_to_DAE(DAE, field_name, field_value)
%
%This function is used to populate the skeleton DAE returned by init_DAE().
%The following field_name and field_value arguments are accepted:
%
%field_name                  field_value
%----------                  -----------
%
%'name'/'nameStr':           a string with DAE name (for printing/plotting).
%
%'unkname'/'unknames'/'unkname(s)': cell array of strings. No default;
%                            must be defined. The names and order of the
%                            variables in the DAE's unknown vector x are
%                            defined by unknames.
%
%'eqnname'/'eqnnames'/'eqnname(s)': cell array of strings. No default; must 
%                            be defined. The names and order of 
%                            the equations of the DAE (as computed by f, 
%                            q, etc.) are defined by eqnnames.
%                            
%'inputname'/'inputnames'/'inputname(s)': cell array of strings. Default:
%                            empty. Defines the names and order of the
%                            inputs u(t).
%
%'outputname'/'outputnames'/'outputname(s)': cell array of strings. Default:
%                            all entries in unknames (TODO: CHECK). The
%                            names of the outputs defined through the
%                            matrices C and D (see below).
%
%'f_takes_inputs':           1 or 0; default = 1. If 0, f does not take u
%                            as an argument; if 1, it does. help DAEAPI for
%                            further details.
%
%'f':                        a handle to a function f(S), where S is a
%                            structure containing as fields the names of
%                            all unknowns, inputs and parameter. You can
%                            convert these into variables in f's local
%                            namespace using v2struct(S). f should return
%                            a column vector of size length(DAE.eqnnames).
%                            help DAEAPI for more information about what 
%                            f means. Overrides any prior definition
%                            of f or f_x.
%
%'f_x':                      a handle to a function f that obeys the same
%                            calling syntax as DAE.f, typically f(x, xlim,
%                            u, DAE) - help DAEAPI for details. Overrides
%                            any prior definition of f or f_x.
%
%'q':                        a handle to the q function of the  DAE. Syntax
%                            similar to f; help DAEAPI for details.
%                            Overrides any prior definition of q or q_x.
%
%'q_x':                      a handle to a function q that obeys the same
%                            calling syntax as DAE.q, typically q(x, xlim,
%                            DAE) - help DAEAPI for details. Overrides
%                            any prior definition of q or q_x.
%
%'fq':                       handle to a function fq that contains both
%                            f and q and returns [fout, qout]. Syntax similar
%                            to f; help DAEAPI for details. Overrides any
%                            prior definition of fq or fq_x. If fq is set,
%                            set values of f/f_x/q/q_x are not used.
%
%'fq_x':                     a handle to a function fq that obeys the same
%                            calling syntax as DAE.fq, typically fq(x, xlim,
%                            u, DAE) - help DAEAPI for details. Overrides
%                            any prior definition of fq or fq_x.
%
%'B':                        used only if f_takes_inputs = 0. In which
%                            case, should be the handle of a function B(DAE),
%                            return the input-to-DAE coupling matrix B. help
%                            DAEAPI for details.
%
%'C':                        handle to a function C(DAE), which should return
%                            the C state-to-output coupling matrix (help
%                            DAEAPI for details). Default =
%                            eye(length(unknames)), assuming outputnames
%                            is not set. If outputnames is set, should be
%                            a matrix of size length(outputnames) x
%                            length(unknames).
%
%'D':                        handle to a function D(DAE), which should return
%                            the D input-to-output coupling matrix (help
%                            DAEAPI for details). Default =
%                            zeros(length(unknames), length(inputnames)).
%                            assuming outputnames is not set. If outputnames
%                            is set, should be a matrix of size
%                            length(outputnames) x length(inputnames).
%
%'parm'/'parms'/'parm(s)'/'param'/'params': cell array of parameter names
%                            and default values: {'name1', value1, 'name2',
%                            value2, ...}.  Defines the names, order and
%                            default values of the DAE's parameters. help
%                            DAEAPI for details.
%
%'limitedvarname'/'limitedvarnames': cell array of strings (TODO: Tianshi, 
%                            please document)
%
%'limited_var_matrix'/'limited_matrix: a matrix (TODO: Tianshi, please
%                            document)
%
%
%Examples
%--------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A van der Pol like oscillator DAE (see also help van_del_Pol_ish_DAEwrapper)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   % The DAE (actually, ODE) system is:
%   % d/dt z = y
%   % d/dt y = ((1 - z^2) * y - z) * spikiness
%   %
%   % Defining x = [z; y], this can be written in MAPP's vector DAE form as:
%   % d/dt (-[z; y]) + [y; ((1 - z^2) * y - z) * spikiness] = 0
%   %       ^^^^^^^    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%   %         q(x)   +                f(x)                  = 0
%   
%   DAE = init_DAE();
%   
%   DAE = add_to_DAE(DAE, 'nameStr', 'van der Pol-like oscillator');
%   DAE = add_to_DAE(DAE, 'unkname(s)', {'z', 'y'});
%   DAE=add_to_DAE(DAE, 'eqnname(s)', {'-xdotPlusf1(z,y)', '-ydotPlusf2(z,y)'});
%   %DAE = add_to_DAE(DAE, 'inputname(s)', {}); % no inputs
%   %DAE = add_to_DAE(DAE, 'outputname(s)', {}); % no outputs defined => all
%                                                % unknowns are outputs
%   
%   DAE = add_to_DAE(DAE, 'parm(s)', {'spikiness', 10});
%   DAE = add_to_DAE(DAE, 'f_takes_inputs', 1);
%   
%   % d/dt q(x) + f(x, inputs) = 0; this is f(x, inputs)
%   f = @(S) [S.y; ((1-S.z^2)*S.y - S.z)*S.spikiness];
%   DAE = add_to_DAE(DAE, 'f', f);
%   
%   % d/dt q(x) + f(x, inputs) = 0; this is q(x)
%   q = @(S) [-S.z; -S.y];
%   DAE = add_to_DAE(DAE, 'q', q);
%   
%   C = @(DAEarg) eye(2);
%   DAE = add_to_DAE(DAE, 'C', C);
%   
%   D = @(DAEarg) sparse(2,0);
%   DAE = add_to_DAE(DAE, 'D', D);
%   
%   DAE = finish_DAE(DAE);
%   
%   check_DAE(DAE); % runs basic checks on the DAE
%
%%The van der Pol-like DAE is now defined. You can now run various analyses on
%%it (help van_der_Pol_ish_DAEwrapper). For example:
%   tr = transient(DAE, [2;0], 0, 5e-2, 20); feval(tr.plot, tr);
% 
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% An idealized 3-stage ring oscillator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   % This is the size-3 ODE
%   %
%   %   d/dt (tau*x1(t)) = g(x3(t)) - x1(t)
%   %   d/dt (tau*x2(t)) = g(x1(t)) - x2(t)
%   %   d/dt (tau*x3(t)) = g(x2(t)) - x3(t)
%   % 
%   % where g(y) = tanh(k*y), with k < -1 for oscillation. tau and k are
%   % parameters of the DAE.
%   %
%   % In MAPP's DAE format, we have
%   %   x = [x1; x2; x3], q(x) = -tau*x, f(x) = [g(x3); g(x1); g(x2)] - x;
%   
%   % For more information on this ring oscillator, see S. Srivastava and
%   % J. Roychowdhury, “Analytical Equations for Nonlinear Phase Errors and
%   % Jitter in Ring Oscillators”, IEEE Trans. Circuits and Systems I:
%   % Fundamental Theory and Applications, Vol. 54, Issue 10, pages
%   % 2321–2329, October 2007. Downloadable from
%   % http://potol.eecs.berkeley.edu/~jr/research/PDFs/2007-10-TCAS-Srivastava-Roychowdhury-RingOscPPV.pdf
%   %
%
%   DAE = init_DAE();
%   
%   DAE = add_to_DAE(DAE, 'nameStr', 'idealized tanh ring oscillator');
%   DAE = add_to_DAE(DAE, 'unkname(s)', {'x1', 'x2', 'x3'});
%   DAE=add_to_DAE(DAE, 'eqnname(s)', {'eqn1', 'eqn2', 'eqn3'});
%   %DAE = add_to_DAE(DAE, 'inputname(s)', {}); % no inputs
%   %DAE = add_to_DAE(DAE, 'outputname(s)', {}); % no outputs defined => all
%                                                % unknowns are outputs
%   
%   DAE = add_to_DAE(DAE, 'parm(s)', {'k', -5, 'tau', 1e-3});
%   DAE = add_to_DAE(DAE, 'f_takes_inputs', 1);
%   
%   % d/dt q(x) + f(x, inputs) = 0; this is f(x, inputs)
%   f = @(S) [tanh(S.k*S.x3)-S.x1; tanh(S.k*S.x1)-S.x2; tanh(S.k*S.x2)-S.x3];
%   DAE = add_to_DAE(DAE, 'f', f);
%   
%   % d/dt q(x) + f(x, inputs) = 0; this is q(x)
%   q = @(S) -S.tau*[S.x1; S.x2; S.x3];
%   DAE = add_to_DAE(DAE, 'q', q);
%   
%   C = @(DAEarg) eye(3);
%   DAE = add_to_DAE(DAE, 'C', C);
%   
%   D = @(DAEarg) sparse(2,0);
%   DAE = add_to_DAE(DAE, 'D', D);
%   
%   DAE = finish_DAE(DAE);
%   
%   check_DAE(DAE); % runs basic checks on the DAE
%
%   % Transient simulation on this DAE
%   tr = transient(DAE, [0;0.1;0], 0, 1e-4, 20e-3); feval(tr.plot, tr);
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   An LCR + nonlinear negative resistance oscillator, with injection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   % The DAE (actually, ODE) system is:
%   % C d/dt v + i + v/R + f(v) + inj(t) = 0,
%   % L d/dt i - v = 0,
%   % where f(v) = tanh(k*v), with L,C,R > 0 and k < - 1/R for oscillation;
%   % inj(t) is a current input.
%   %
%   % Defining x = [v; i], this can be written in MAPP's vector DAE form as:
%   % d/dt ([C*v; L*i]) + [i + v/R + f(v) + inj(t); -v] = 0
%   %       ^^^^^^^^^^    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%   %         q(x)   +                f(x,inputs)     = 0
%
%   DAE = init_DAE();
%
%   DAE = add_to_DAE(DAE, 'nameStr', 'LCRnegres oscillator');
%   DAE = add_to_DAE(DAE, 'unkname(s)', {'v', 'i'});
%   DAE=add_to_DAE(DAE, 'eqnname(s)', {'KCL@v', 'LBCR'});
%   DAE = add_to_DAE(DAE, 'inputname(s)', {'inj'}); % current added to node v
%
%   DAE = add_to_DAE(DAE, 'parm(s)', {'L',1e-9,'C',1e-6,'R',1e2,'k',-1.2e-2});
%   % L=1e-9, C=1e-6 => resonant frequency  = 1/(2*pi*sqrt(L*C)) = about 5MHz
%   DAE = add_to_DAE(DAE, 'f_takes_inputs', 1);
%
%   % d/dt q(x) + f(x, inputs) = 0; this is f(x, inputs)
%   f = @(S) [S.i + S.v/S.R + tanh(S.k*S.v) + S.inj; -S.v];
%   DAE = add_to_DAE(DAE, 'f', f);
%
%   % d/dt q(x) + f(x, inputs) = 0; this is q(x)
%   q = @(S) [S.C*S.v; S.L*S.i];
%   DAE = add_to_DAE(DAE, 'q', q);
%
%   DAE = add_to_DAE(DAE, 'outputname(s)', {'v'});
%   C = @(DAEarg) [1 0]; % just show the voltage
%   DAE = add_to_DAE(DAE, 'C', C);
%
%   D = @(DAEarg) sparse(2,0);
%   DAE = add_to_DAE(DAE, 'D', D);
%
%   DAE = finish_DAE(DAE);
%
%   check_DAE(DAE); % runs basic checks on the DAE
%
%   % The DAE is now defined. You can now run analyses on it. For example:
%   % first set the input transient (help set_utransient for details)
%   DAE = feval(DAE.set_utransient, 'inj', @(t, args) ...
%                       (t>10e-7).*(t<20e-7).*10.*sin(2*pi*5.2e6*t), [], DAE);
%   % run a transient analysis using the Trapezoidal method (TRAP is good for
%   % oscillator ODEs that are not too stiff)
%   tr = run_transient_TRAP(DAE, [75;0], 0, 0.02e-7, 1e-5); feval(tr.plot, tr);
%
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A simple linear ODE: xdot = A*x + B*u, y = C*x + D*u (illustrating f_x/q_x)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   % The ODE is:
%   %   d/dt x = A*x + B*u,
%   %   y = C*x + D*u,
%   % where x is a vector of unknowns, u a vector of inputs, y a vector of
%   % outputs, and A, B, C and D are appropriately-sized matrices.
%   %
%   % We take: 
%   %   x = [x1; x2]; 
%   %   u(t) is a scalar; 
%   %   Lambda = diag(-1, -3); 
%   %   P = [1, 1; 1 -1]; 
%   %   A = P*Lambda*inv(P);
%   %   B = [1; -1];
%   %   C = eye(2); and
%   %   D = zeros(2,1).
%
%   % set up the matrices
%   Lambda = diag([-1, -3]); P = [1 1; 1 -1]; A = P*Lambda*inv(P);
%   B = [1; -1]; C = eye(2); D = zeros(2,1);
%
%   lDAE = init_DAE();
%   % store the matrices in lDAE
%   lDAE.Gmat = A; lDAE.Bmat = B; lDAE.Cmat = C; lDAE.Dmat = D;
%   lDAE = add_to_DAE(lDAE, 'name', 'xdot=Ax+Bu, y=Cx+Du');
%   lDAE = add_to_DAE(lDAE, 'unkname(s)', {'x1', 'x2'});
%   lDAE = add_to_DAE(lDAE, 'eqnname(s)', {'eqn1', 'eqn2'});
%   lDAE = add_to_DAE(lDAE, 'inputname(s)', {'u'});
%
%   C = @(DAEobj) DAEobj.Cmat;
%   lDAE = add_to_DAE(lDAE, 'C', C);
%   D = @(DAEobj) DAEobj.Dmat;
%   lDAE = add_to_DAE(lDAE, 'D', D);
%
%   q = @(x, xlim, DAEobj) -x;
%   lDAE = add_to_DAE(lDAE, 'q_x', q);
%
%   % you need to define f_x as a separate named function f_x_for_DAE.m; 
%   % copy and paste the following:
%   %
%   %   function out = f_x_for_DAE(x, xlim, u, DAE)
%   %       if nargin < 4
%   %           DAE = u;
%   %           u = xlim;
%   %       end
%   %       if DAE.ninputs(DAE) > 0 % needed for Octave
%   %           out = DAE.Gmat*x + DAE.Bmat*u;
%   %       else
%   %           out = DAE.Gmat*x;
%   %       end
%   %   end % f_x_for_DAE 
%
%   lDAE = add_to_DAE(lDAE, 'f_x', @f_x_for_DAE);
%   lDAE = finish_DAE(lDAE);
%
%   check_DAE(lDAE);
%   
%   lDAE = lDAE.set_utransient(@(t, args) pulse(4*t), [], lDAE);
%   TR = transient(lDAE, [1; -1], 0, 0.01, 5); TR.plot(TR);
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%For other examples of DAEAPI wrapper, see (type or edit):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   BJTdiffpair_wrapper, BJTdiffpair_wrapper_with_fq, parallelRLC_wrapper,
%   damped_pendulum_DAEwrapper, nonlinear_pendulum_DAEwrapper, RCline_wrapper,
%   RLCdiode_pnjlim_wrapper, RLCdiode_pnjlim_wrapper, vsrcRC_DAEwrapper,
%   TwoReactionChainDAEAPI_wrapper, van_der_Pol_ish_DAEwrapper,
%   test_BJTdiffpair_wrapper, test_BJTdiffpair_wrapper_with_fq,
%   test_parallelRLCdiode_pnjlim_wrapper, test_parallelRLCdiode_wrapper,
%   test_parallelRLC_wrapper, test_RCline_wrapper,
%   test_tworeactionchain_wrapper_transient.
%
%
%
%See also
%--------
%
%init_DAE, finish_DAE, check_DAE, DAEAPI, DAEAPI_wrapper, MAPPdaes.
%

% these are probably obsolete
%   internalfunc:               a function handle (TODO: yet to be documented).
%   
%   limiting:                               function handle (obsolete?)
%   initguess:                              function handle (obsolete?)
%   
%   

% documentation: JR 2017/02/09
% updates to allow f(x,u,DAE), q(x, DAE): JR 2016/10/03
% Author: Bichen Wu <bichen@berkeley.edu> 2014/02/03
    if strcmp(field_name, 'f_takes_inputs')
        DAE.f_takes_inputs = field_value;
    
    elseif strcmp(field_name, 'f')
        if DAE.f_takes_inputs == 1
            DAE.f_of_S = field_value;
            DAE.f = @DAE_f;
        elseif DAE.f_takes_inputs == 0
            DAE.f_of_S = field_value;
            DAE.f = @DAE_f_no_u;
        else
            error (['ERROR in add_to_DAE(): Please define .f_takes_inputs before .f ']);
        end
        DAE.f_of_S = field_value;
        DAE.f_has_been_specified = 1;
    
    elseif strcmp(field_name, 'f_x') % field value should be handle to f(x, xlim, u, DAE) or f(x,xlim,  DAE), depending on .f_takes_inputs
        DAE.f = field_value;
        DAE.f_has_been_specified = 2;

    elseif strcmp(field_name, 'q')
        DAE.q_of_S = field_value;
        DAE.q = @DAE_q;
        DAE.q_has_been_specified = 1;
    
    elseif strcmp(field_name, 'q_x')% field value should be handle to q(x, xlim, DAE)
        DAE.q = field_value;
        DAE.q_has_been_specified = 2;
    
    elseif strcmp(field_name, 'fq')
        if DAE.f_takes_inputs == 1
            DAE.fq_of_S = field_value;
            DAE.fq = @DAE_fq;
        elseif DAE.f_takes_inputs == 0
            DAE.fq_of_S = field_value;
            DAE.fq = @DAE_fq_no_u;
        else
            error (['ERROR in add_to_DAE(): Please define .f_takes_inputs before .fq ']);
        end
        DAE.f_has_been_specified = 1;
        DAE.q_has_been_specified = 1;

    elseif strcmp(field_name, 'fq_x')% field value should be handle to fq(x, xlim, (u), DAE)
        DAE.fq = field_value;
        DAE.f_has_been_specified = 2;
        DAE.q_has_been_specified = 2;
    
    elseif strcmp(field_name, 'B')
        DAE.B = @(DAE)(feval(field_value,DAE_Bstruct(DAE)));
        DAE.B_of_S = field_value;

    elseif strcmp(field_name ,'C')
        DAE.C = field_value;
    
    elseif strcmp(field_name ,'D')
        DAE.D = field_value;
    
    elseif strcmp (field_name, 'limiting')
        DAE.NRlimiting = @(x, xlimOld, u, DAE)(feval(field_value,DAE_fstruct(x, xlimOld, u, DAE)));
        DAE.NRlimiting_of_S = field_value;

    elseif strcmp (field_name, 'initguess')
        DAE.NRinitGuess = @(u, DAE)(feval(field_value,DAE_ustruct(u, DAE)));
        DAE.NRinitGuess_of_S = field_value;

    elseif strcmp(field_name ,'internalfunc')
        DAE.internalfuncs = @(X, XLim, U, DAE)(feval(field_value, DAE_fstruct(X, U, DAE)));
        DAE.internalfuncs_of_S = field_value;
    
    elseif strcmp(field_name ,'uniqIDstr')
        DAE.uniqIDstr = field_value;

    elseif strcmp(field_name ,'nameStr') || strcmp(field_name ,'name')
        DAE.nameStr = field_value;
    
    elseif strcmp(field_name, 'unkname(s)') || strcmp(field_name, 'unkname') ...
                                            || strcmp(field_name, 'unknames')
        for i=1:length(field_value)
            % JR, 2015/07/16: weird errors occur for unknowns named 'i', 'v1',
            % v2, v3, etc.. exists returns 7 (directory), but cannot find
            % such directories in MAPP or even in the MATLAB installation.
            % Ignoring for the moment.
            % field_value{i}
            % exist(field_value{i})
            % who(field_value{i})
            if exist(field_value{i}) ~= 0
                warning(['Potential name conflict with unknown named ', field_value{i}, ' detected']);
            end
            % JR, 2015/07/16: found no check against unknameList, fixing...
            if sum(strcmp(field_value{i}, DAE.unknameList)) > 0
                error('unknown %s already exists in DAE', field_value{i});
            else
                DAE.unknameList{end+1} = field_value{i};
            end
        end

    elseif strcmp(field_name,'eqnname(s)') || strcmp(field_name, 'eqnname')...
                                            || strcmp(field_name, 'eqnnames')
        for i=1:length(field_value)
            % JR, 2015/07/16: found no check against eqnnameList, fixing...
            if sum(strcmp(field_value{i}, DAE.eqnnameList)) > 0
                error('eqn name %s already exists in DAE', field_value{i});
            else
                DAE.eqnnameList{end+1} = field_value{i};
            end
        end
    elseif strcmp(field_name, 'inputname(s)') ...
           || strcmp(field_name,'inputname') || strcmp(field_name,'inputnames')
        for i=1:length(field_value)
            if exist(field_value{i}) ~= 0
                warning(['Potential name conflict with input named ', field_value{i}, ' detected']);
            end
            % JR, 2015/07/16: found no check against inputnameList, fixing...
            if sum(strcmp(field_value{i}, DAE.inputnameList)) > 0
                error('input %s already exists in DAE', field_value{i});
            else
                DAE.inputnameList{end+1} = field_value{i};
            end
        end

    elseif strcmp(field_name ,'outputname(s)') ...
           || strcmp(field_name,'outputname') ...
           || strcmp(field_name,'outputnames')
        for i=1:length(field_value)
            % JR, 2015/07/16: found no check against outputnameList, fixing...
            if sum(strcmp(field_value{i}, DAE.outputnameList)) > 0
                error('output %s already exists in DAE', field_value{i});
            else
                DAE.outputnameList{end+1} = field_value{i};
            end
        end

    elseif strcmp(field_name ,'parm(s)') || strcmp(field_name ,'parm') ...
            || strcmp(field_name ,'parms') || strcmp(field_name ,'param') ...
            || strcmp(field_name ,'params')
        for i=1:2:length(field_value)
            if exist(field_value{i}) ~= 0
                warning(['Potential name conflict with parameter name ', field_value{i}, ' detected']);
            end
        end
        for idx = 1 : 1 : (length(field_value)/2)
            % JR, 2015/07/16: found no check against parmnames, fixing...
            pname = field_value{2*idx-1};
            if sum(strcmp(field_value{i}, DAE.parmnameList)) > 0
                error('parameter %s already exists in DAE', field_value{i});
            else
                DAE.parmnameList{end+1} = pname;
                DAE.parm_defaults{end+1} = field_value{2*idx};
                DAE.parms{end+1} = field_value{2*idx};
            end
        end

    elseif strcmp(field_name ,'limitedvarname(s)') ...
            || strcmp(field_name ,'limitedvarname') ...
            || strcmp(field_name ,'limitedvarnames')
        for i=1:length(field_value)
            if exist(field_value{i}) ~= 0
                warning(['Potential name conflict with limited variable name ', field_value{i}, ' detected']);
            end
            % JR, 2015/07/16: found no check against parmnames, fixing...
            if sum(strcmp(field_value{i}, DAE.limitedvarnameList)) > 0
                error('limited var %s already exists in DAE', field_value{i});
            else
                DAE.limitedvarnameList{end+1} = field_value{i};
            end
        end

    elseif strcmp(field_name ,'limited_matrix') || ...
                                    strcmp(field_name ,'limited_var_matrix')
        DAE.x_to_xlim_matrix = field_value;
    else
        error (['ERROR in add_to_DAE(): Unrecognized field ', field_name]);
    end

    out = DAE;
end

function out = DAE_f(x, xlim, u, DAE)
    if 3 == nargin
        DAE = u; u = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end
    out = feval(DAE.f_of_S, DAE_fstruct(x, xlim, u, DAE));
end % DAE_f

function out = DAE_f_no_u(x, xlim, DAE)
    if 2 == nargin
        DAE = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end
    out = feval(DAE.f_of_S, DAE_qstruct(x, xlim, DAE));
end % DAE_f_no_u

function out = DAE_q(x, xlim, DAE)
    if 2 == nargin
        DAE = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end
    out = feval(DAE.q_of_S, DAE_qstruct(x, xlim, DAE));
end % DAE_q

function [fout, qout] = DAE_fq(x, xlim, u, flag, DAE)
    if 4 == nargin
        DAE = flag; flag = u; u = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end
    S = DAE_fqstruct(x, xlim, u, DAE);
    S.flag = flag;
    [fout, qout] = feval(DAE.fq_of_S, S);
end % DAE_f

function [fout, qout] = DAE_fq_no_u(x, xlim, flag, DAE)
    if 3 == nargin
        DAE = flag; flag = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end
    S = DAE_qstruct(x, xlim, DAE);
    S.flag = flag;
    [fout, qout] = feval(DAE.fq_of_S, S);
end % DAE_f_no_u
