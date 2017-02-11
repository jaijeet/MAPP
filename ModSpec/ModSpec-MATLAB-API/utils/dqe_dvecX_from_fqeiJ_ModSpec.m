
function out = dqe_dvecX_from_fqeiJ_ModSpec(varargin)
    flag.fe = 0; flag.qe = 1; flag.fi = 0; flag.qi = 0; flag.J = 1;
    MOD = varargin{end};
    [fqei_out, J_out] = feval(MOD.fqeiJ, varargin{1:(end-1)}, [], flag, MOD);
    out = J_out.Jqe.dqe_dvecX;
end

