function [fq, J] = dfq_dxxlimu_auto(x, xlim, u, DAE)
%function [fq, J] = dfq_dxxlimu_auto(x, xlim, u, DAE)
%This function computes the derivative of both f and q of a DAE with respect to
%x, xlim and u, using vecvalder.
%It also returns f and q's values.
%INPUT args:
%   x           - vector for unknowns
%   xlim        - vector for limited variables (optional)
%   u           - input vector (optional)
%   DAE         - a DAEAPI object/structure describing a DAE
%
%OUTPUT:
%   fq: struct, contains
%       fq.f
%       fq.q
%   J:  struct, contains
%       J.dfdx
%       J.dfdxlim
%       J.dfdu
%       J.dqdx
%       J.dqdxlim

%Author: Tianshi Wang <tianshi@berkeley.edu> 2014/08/21
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fq.f = [];
    fq.q = [];
    J.dfdx = [];
    J.dfdxlim = [];
    J.dfdu = [];
    J.dqdx = [];
    J.dqdxlim = [];
	  
    %{
    for Octave not to complain
    if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
        fprintf(2,'dfq_dxxlimu_auto: vecvalder (needed for computing dfq/dxxlimu) not found - aborting');
        return;
    end
    %}

    if 4 == nargin
        f_takes_xlim = 1;
        if 0 == DAE.f_takes_inputs
            error('dfq_dxxlimu_auto: 0 == DAE.f_takes_inputs and 4 arguments.');
            return;
        end
        if 0 == DAE.support_initlimiting
            error('dfq_dxxlimu_auto: 0 == DAE.support_initlimiting but xlim is among arguments.');
            return;
        end
    elseif 3 == nargin
        DAE = u;
        if 0 == DAE.f_takes_inputs
            f_takes_xlim = 1;
            if 0 == DAE.support_initlimiting
                error('dfq_dxxlimu_auto: 0 == DAE.support_initlimiting but xlim is among arguments.');
                return;
            end
        else
            u = xlim;
            f_takes_xlim = 0;
        end
    else
        DAE = xlim;
        f_takes_xlim = 0;
        if 1 == DAE.f_takes_inputs
            error('dfq_dxxlimu_auto: 1 == DAE.f_takes_inputs and only <=2 arguments.');
            return;
        end
    end

    nunks = feval(DAE.nunks, DAE);
    ninputs = feval(DAE.ninputs, DAE);
    if 1 == DAE.support_initlimiting
        nlimitedvars = feval(DAE.nlimitedvars, DAE);
    end

    neqns = feval(DAE.neqns, DAE);

    % determine whether xlim and u are parts of the independent variables indep
    % length_indep is the total number of independent variables
    length_indep = nunks;
    if 1 == f_takes_xlim
        length_indep = length_indep + nlimitedvars;
    end
    if 1 == DAE.f_takes_inputs
        length_indep = length_indep + ninputs;
    end

    if nunks > 0
        der = speye(nunks, length_indep); % eye at the right part
        vvx = vecvalder(x, der);
        occupied_length = nunks;
    else
        vvx = [];
        occupied_length = 0;
    end

    if 1 == f_takes_xlim
        if nlimitedvars > 0
            der = sparse(nlimitedvars, length_indep);
            der(:, occupied_length+1: occupied_length+nlimitedvars) = speye(nlimitedvars);
            vvxlim = vecvalder(xlim, der);
            occupied_length = occupied_length + nlimitedvars;
        else
            vvxlim = [];
            % occupied_length = occupied_length + 0;
        end
    else % 0 == f_takes_xlim
        if 1 == DAE.support_initlimiting
            vvxlim = DAE.xTOxlim(vvx, DAE);
        end
    end

    if 1 == DAE.f_takes_inputs
        if ninputs > 0
            der = sparse(ninputs, length_indep);
            der(:, occupied_length+1: occupied_length+ninputs) = speye(ninputs);
            % occupied_length = occupied_length + ninputs;
            vvu = vecvalder(u, der);
        else
            vvu = [];
            % occupied_length = occupied_length + 0;
        end
    end

    % now evaluate fq with x, xlim, u
    flag.f = 1; flag.q = 1;
    if 1 == DAE.f_takes_inputs
        if 1 == DAE.support_initlimiting
            [vvf, vvq] = feval(DAE.fq, vvx, vvxlim, vvu, flag, DAE);
        else % 0 == DAE.support_initlimiting
            [vvf, vvq] = feval(DAE.fq, vvx, vvu, flag, DAE);
        end
    else % 0 == DAE.f_takes_inputs
        if 1 == DAE.support_initlimiting
            [vvf, vvq] = feval(DAE.fq, vvx, vvxlim, flag, DAE);
        else % 0 == DAE.support_initlimiting
            [vvf, vvq] = feval(DAE.fq, vvx, flag, DAE);
        end
    end

    % assign outputs
    if isa(vvf, 'vecvalder')
        Jf = sparse(der2mat(vvf));
        fout = val2mat(vvf);
    else
        Jf = sparse(neqns, length_indep);
        if isempty(Jf)
            fout = sparse(neqns, 0);
        else
            fout = vvf;
        end
    end

    if isa(vvq, 'vecvalder')
        Jq = sparse(der2mat(vvq));
        qout = val2mat(vvq);
    else
        Jq = sparse(neqns, length_indep);
        if isempty(Jq)
            qout = sparse(neqns, 0);
        else
            qout = vvq;
        end
    end
    fq.f = fout;
    fq.q = qout;

    J.dfdx = Jf(:,1:nunks);
    J.dqdx = Jq(:,1:nunks);
    occupied_length = nunks;

    if 1 == f_takes_xlim
        J.dfdxlim = Jf(:,occupied_length+1:occupied_length+nlimitedvars);
        J.dqdxlim = Jq(:,occupied_length+1:occupied_length+nlimitedvars);
        occupied_length = occupied_length + nlimitedvars;
    else
        J.dfdxlim = [];
        J.dqdxlim = [];
    end

    if 1 == DAE.f_takes_inputs
        J.dfdu = Jf(:,occupied_length+1:occupied_length+ninputs);
    else
        J.dfdu = [];
    end
end % dfq_dxxlimu_auto
