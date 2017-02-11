
function out = dqi_dvecY_from_fqeiJ_ModSpec(varargin)
    flag.fe = 0; flag.qe = 0; flag.fi = 0; flag.qi = 1; flag.J = 1;
    MOD = varargin{end};
    [fqei_out, J_out] = feval(MOD.fqeiJ, varargin{1:(end-1)}, [], flag, MOD);
    out = J_out.Jqi.dqi_dvecY;
end

