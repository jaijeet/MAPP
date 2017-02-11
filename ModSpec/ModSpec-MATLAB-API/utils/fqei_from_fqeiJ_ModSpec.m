
function [fe_out, qe_out, fi_out, qi_out] = fqei_from_fqeiJ_ModSpec(varargin)
    MOD = varargin{end}; flag = varargin{end-1}; flag.J = 0;
    [fqei_out, J_out] = feval(MOD.fqeiJ, varargin{1:(end-2)}, flag, MOD);
    fe_out = fqei_out.fe;
    qe_out = fqei_out.qe;
    fi_out = fqei_out.fi;
    qi_out = fqei_out.qi;
end

