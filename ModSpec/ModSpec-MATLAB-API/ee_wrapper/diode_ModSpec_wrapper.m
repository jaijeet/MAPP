function MOD = diode_ModSpec_wrapper()
%function MOD = diode_ModSpec_wrapper()
% This function returns a ModSpec model for a simple diode.
% The function should be self-explanatory. To see the code:
% >> type diode_ModSpec_wrapper;
% or
% >> edit diode_ModSpec_wrapper;
%
	MOD = ee_model();

    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});
    MOD = add_to_ee_model(MOD, 'limited_var', {'vpnlim'});
    MOD = add_to_ee_model(MOD, 'limited_matrix', 1);
    MOD = add_to_ee_model(MOD, 'parms', {'Is', 1e-12, 'VT', 0.025});
    
    MOD = add_to_ee_model(MOD, 'f', @f);

    MOD = add_to_ee_model(MOD, 'initGuess', @initGuess);
    MOD = add_to_ee_model(MOD, 'limiting', @limiting);

    MOD = finish_ee_model(MOD);
end

function out = f(S)
    v2struct(S); % Is = S.Is; VT = S.VT; vpn = S.vpn; vpnlim = S.vpnlim;
    out = Is*(exp(vpnlim/VT)-1);
end

function out = initGuess(S)
    v2struct(S); % Is = S.Is; VT = S.VT; vpn = S.vpn; vpnlim = S.vpnlim;

	vcrit = VT*log(VT/(sqrt(2)*Is));
	out = vcrit;
end

function out = limiting(S)
    v2struct(S); % Is = S.Is; VT = S.VT; vpn = S.vpn; vpnlim = S.vpnlim;

	vcrit = VT*log(VT/(sqrt(2)*Is));
	out = pnjlim(vpnlim, vpn, VT, vcrit);
end
