function MOD = RRAM_v0_Yakopcic_ModSpec()
% 
%Yakopcic model equtions: 
% 
% itb = f1(vtb, x);
% d/dt x = f2(vtb, x);
% 
% f1 = a1 * x * sinh(b * vtb), if vtb>=0;
%      a2 * x * sinh(b * vtb), if vtb<0;
% 
% f2 = eta * g(vtb) * f(x);
% 
% g(vtb) = Ap * (exp(vtb) - exp(Vp)),  vtb>Vp;
%          -An * (exp(-vtb) - exp(Vn)), vtb<-Vn;
%          0,           -Vn <= vtb <= Vp;
% 
% f(x) = exp(-alphap*(x-xp))*wp(x,xp), x>=xp 
%        1, 1-xn<x<xp 
%        exp(alphan*(x-1+xn))*wn(x,xn), x<=1-xn
% 
% wp(x, xp) = (xp-x)/(1-xp)+1
% wn(x, xn) = x/(1-xn)
%
%Modifications:
%
% - g(vtb) shouldn't be all zeros between -Vn <= vtb <= Vp.
%   Use a small K. When K is 1, it becomes the original Yakopcic model.
%
% g(vtb) = Ap * (exp(vtb) - exp(Vp)) + K*Vp,  vtb>Vp;
%          -An * (exp(-vtb) - exp(Vn)) - K*Vn, vtb<-Vn;
%          K*vtb,           -Vn <= vtb <= Vp;
%
% - get rid of wp and wn
%
% f(x) = exp(-alphap*(x-xp)), x>=xp 
%        1, 1-xn<x<xp 
%        exp(alphan*(x-1+xn)), x<=1-xn
% 
% f2 = eta * g(vtb) * f(x);
% 
% Fw1 = smoothstep(1-xn-x, smoothing);
% Fw2 = smoothstep(x-xp, smoothing);
% clip_xn = (safeexp(Kclip*(1-xn-x), maxslope) - f2) * Fw1;
% clip_xp = (-safeexp(Kclip*(x-xp), maxslope) - f2) * Fw2;
%
% f2* = f2 + clip_xn + clip_xp;
%
    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'RRAM');
    MOD = add_to_ee_model(MOD, 'terminals', {'t', 'b'}); % create IO: vtb, itb
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'itb'});
    MOD = add_to_ee_model(MOD, 'internal_unks', {'x'});
    MOD = add_to_ee_model(MOD, 'implicit_eqn_names', {'dx'});

    MOD = add_to_ee_model(MOD, 'parms', {'a1', 0.17, 'a2', 0.17, 'b', 0.05});
    MOD = add_to_ee_model(MOD, 'parms', {'Vp', 0.16, 'Vn', 0.15, 'Ap', 4e3, 'An', 4e3});
    MOD = add_to_ee_model(MOD, 'parms', {'xp', 0.3, 'xn', 0.5, 'alphap', 1, 'alphan', 5});
    MOD = add_to_ee_model(MOD, 'parms', {'K', 1});
    MOD = add_to_ee_model(MOD, 'parms', {'eta', 1});
    MOD = add_to_ee_model(MOD, 'parms', {'maxslope', 1e15});
    MOD = add_to_ee_model(MOD, 'parms', {'smoothing', 1e-8, 'Kclip', 50});
    MOD = add_to_ee_model(MOD, 'parms', {'GMIN', 1e-12});

    MOD = add_to_ee_model(MOD, 'fqei', {@fe, @qe, @fi, @qi});

    MOD = finish_ee_model(MOD);
end

function out = fe(S)
    v2struct(S);
	if vtb >= 0
		out = a1 * x * safesinh(b * vtb, maxslope) + GMIN*vtb; % itb
	else % vtb < 0
		out = a2 * x * safesinh(b * vtb, maxslope) + GMIN*vtb; % itb
	end
end

function out = qe(S)
    out = 0; % itb
end

function out = fi(S)
    v2struct(S);
	if vtb > Vp
		g_of_vtb = Ap * (safeexp(vtb, maxslope) - safeexp(Vp, maxslope)) + K*Vp;
	elseif vtb < -Vn
        g_of_vtb = -An * (safeexp(-vtb, maxslope) - safeexp(Vn, maxslope)) - K*Vn;
	else % -Vn <= vtb <= Vp
        g_of_vtb = K*vtb;
	end

	if x >= xp
		f_of_x = safeexp(-alphap*(x-xp), maxslope);
	elseif x <= 1-xn
		f_of_x = safeexp(alphan*(x-1+xn), maxslope);
	else % 1-xn<x<xp
		f_of_x = 1;
	end

	f2 = eta * g_of_vtb * f_of_x;

	Fw1 = smoothstep(0-x, smoothing);
	Fw2 = smoothstep(x-1, smoothing);
	clip_0 = (safeexp(Kclip*(0-x), maxslope) - f2) * Fw1;
	clip_1 = (-safeexp(Kclip*(x-1), maxslope) - f2) * Fw2;

	out = f2 + clip_0 + clip_1;
end

function out = qi(S)
    v2struct(S);
    out = - x;
end

function y = safesinh(x, maxslope)
    y = (safeexp(x, maxslope) - safeexp(-x, maxslope))/2;
end % safesinh

