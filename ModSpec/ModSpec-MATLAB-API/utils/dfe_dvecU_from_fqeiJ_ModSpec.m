
function out = dfe_dvecU_from_fqeiJ_ModSpec(varargin)
    flag.fe = 1; flag.qe = 0; flag.fi = 0; flag.qi = 0; flag.J = 1;
    MOD = varargin{end};
    [fqei_out, J_out] = feval(MOD.fqeiJ, varargin{1:(end-1)}, flag, MOD);
    out = J_out.Jfe.dfe_dvecU;
end

