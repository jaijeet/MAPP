function transobj = transient_skeleton(DAE) % DAE=DAEAPIv6.2
%function transobj = transient_skeleton(DAE)
%This function creates a basic transient skeleton object to be "inherited" by
%different transient analysis methods such as LMS, Heun, RK4, transient_ode15s,
%etc. (although currently, no method other than LMS is actually implemented).
%
%Arguments:
%   DAE      - DAEAPI structure/object
%
%Outputs:
%   transObj - transient skeleton structure/object with the following
%              fields (set to default, or empty, values)
%              .tranparms (= defaultTranParms())
%              .solvalid (= 0)
%              .tpts (= [])
%              .vals (= [])
%              .Cs (= {})
%              .Gs (= {})
%              .Gus (= {})
%              .DAE (= DAE)
%              .B (= DAE.B() if DAE.f_takes_u = 0)
%              .f_takes_u (= DAE.f_takes_u)
%              .getsolution = @transient_getsolution(...)
%              .plot = @transient_plot(...)
%              .jacobians = @jacobians(...)
%
%Examples
%--------
%See the code of the LMS.m constructor for an example of the use of 
%transient_skeleton
%
%See also
%--------
%
% LMS, transientPlot, DAE_concepts, DAEAPI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % data/precomputation
    transobj.version = '?';
    transobj.DAEversion = 'DAEAPIv6.2';
    %
    if 0 == DAE.f_takes_inputs
        transobj.B = feval(DAE.B, DAE);
    end
    %
    transobj.name = 'function handle (DEFINE THIS)';
    transobj.solve = 'function handle (DEFINE THIS)';
    transobj.getsolution = @transient_getsolution;
    transobj.getSolution = @transient_getsolution;
    transobj.plot = @transient_plot;
    transobj.jacobians = @jacobians;
    transobj.solvalid = 0;
    transobj.tpts = [];
    transobj.vals = [];
    transobj.Cs = {}; % these are set up only if store_Jacobians is 1 in
              % solve()
    transobj.Gs = {}; % these are set up only if store_Jacobians is 1 in
              % solve()
    transobj.Gus = {}; % these are set up only if store_Jacobians is 1 in
               % solve()
    transobj.DAE = DAE;
    transobj.f_takes_u = DAE.f_takes_inputs;
    transobj.tranparms = defaultTranParms();
end
% end of "constructor"

function [cee, gee, geeu] = jacobians(t, x, DAE)
%function [cee, gee, geeu] = jacobians(t, x, DAE)
%This function provides various Jacobian matrices for a given DAE
%The assumed form of DAE is:
%            d/dt q(x) + f(x, u(t)) = 0 (case 1),
%or
%            d/dt q(x) + f(x) + B*u(t) = 0 (case 2).
%INPUT args:
%   x           - DAE unknowns (vector)
%   t           - time
%   DAE         - circuit DAE
%OUTPUTS:
%   cee         - dq_dx(x)
%   gee         - df_dx(x,u) (case 1) or  df_dx(x) (case 2)
%   geeu        - df_du(x,u) (case 1) or B (case 2)
    cee = feval(DAE.dq_dx, x, DAE);

    ninputs = feval(DAE.ninputs, DAE);
    if ninputs > 0
        u = feval(DAE.utransient, t, DAE);
    else
        u = [];
    end
    if 1 == DAE.f_takes_inputs
        % DAE is d/dt q(x) + f(x, u(t)) = 0
        gee = feval(DAE.df_dx, x, u, DAE);
        geeu = feval(DAE.df_du, x, u, DAE);
    else
        % DAE is d/dt q(x) + f(x) + B*u(t) = 0
        gee = feval(DAE.df_dx, x, DAE);
        geeu = feval(DAE.B, DAE);
    end
end
% end of jacobians

function [tpts, vals, jacobians] = transient_getsolution(transobj)
%function [tpts, vals, jacobians] = transient_getsolution(transobj)
%This function provides solutions from a successful transient run.
%
%Arguments:
%   transobj    - LMS structure/object.
%
%Outputs:
%   tpts        - time steps (row vector of size number of time steps)
%   vals        - vals is a matrix of transient solution values. Each column
%                 is the solution at a timepoint. Eg, vals(:,i) returns the
%                 solution at the ith timepoint. The number of rows equals
%                 the number of DAE unknowns.
%   jacobians   - structure with the following fields (output meaningful 
%                 only if LMS::LMStimeStepping has been run with Jacobian
%                 storage options):
%         .Cs     - cell array containing dq_dx at each timepoint. 
%                   Ie, Cs{i} is a (sparse) matrix representing dq_dx @ x=x(t_i)
%         .Gs     - cell array containing df_dx at each timepoint.
%         .Gus    - cell array containing df_du at each timepoint.
%
    if transobj.solvalid < 1
        if isempty(transobj.tpts)
            fprintf(2,'transient_getsolution: run solve first!\n');
            tpts = []; vals = [];
        else
            fprintf(2,'transient_getsolution: WARNING: solution may not be valid!\n');
            tpts = transobj.tpts(1,:);
            vals = transobj.vals(:,:);
        end
    else
        tpts = transobj.tpts(1,1:transobj.timeptidx);
        vals = transobj.vals(:,1:transobj.timeptidx);
        if length(transobj.Gs) > 0
            jacobians.Cs = transobj.Cs;
            jacobians.Gs = transobj.Gs;
            jacobians.Gus = transobj.Gus;
        else
            jacobians = [];
        end
    end
end % transient_getsolution

function [figh, onames, colindex] = transient_plot(transobj, varargin)
%function [figh, legends, colindex] = transient_plot(transobj, ...)
%Plots the result of a transient simulation.
%
%Note: this function calls transientPlot(...) to do the real work. 
%help transientPlot for more information.
%
%Arguments:
% - transobj: structure/object conforming to transient_skeleton and with
%             valid data in transobj.tpts and transobj.vals to plot
% - ...:      (optional) arguments to be passed to transientPlot().
%             This routine calls transientPlot() as follows:
%               transientPlot(DAE, tpts, vals, time_units, ...),
%             where DAE, tpts, vals, and time_units are derived from transobj.
%             Any further arguments ... should be exactly as supported
%             by transientPlot - help transientPlot for more information.
%
%Outputs:
% - figh:     figure handle of the plot. Can be passed (optionally) to a
%             future call to transient_plot(). See help transientPlot.
% - legends:  cell array of strings, suitable for using as argument to
%             Matlab's legend() function. Can be passed (optionally) to a future
%             call to transient_plot(). See help transientPlot.
% - colindex: an integer representing the index of the last colour used in
%             the current plot. Mainly useful for passing (optionally) to a
%             future call to transient_plot(). See help transientPlot.
    DAE = transobj.DAE;
    tpts = transobj.tpts(1,1:transobj.timeptidx);
    vals = transobj.vals(:,1:transobj.timeptidx);
    time_units = DAE.time_units;
    [figh, onames, colindex] = transientPlot(DAE, tpts, vals, ...
                              time_units, varargin{:});
    title(escape_special_characters(sprintf('%s: transient using %s', ...
                           feval(transobj.DAE.daename,transobj.DAE), ...
                                  feval(transobj.name, transobj))));
end
% end of function transient_plot
