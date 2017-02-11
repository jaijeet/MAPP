function MOD = RRAM_v0_all(f1_switch, f2_switch)
%
%TEAM equations:
%
% ipn = f1(vpn, s);
% d/dt s = f2(vpn, s);
% 
% We always keep 0 <= s <= 1 and scale the related parameters.
%
% %%%%%%% f1 == 1 %%%%%%% 
% f1 = (Ron*s + Roff*(1-s))^(-1) * vpn;
%
% We have to ensure that Roff - (Ron-Roff) *s ~= 0;
% s ~= Roff/(Ron-Roff) < 0;
% y = smoothclip(s - Roff/(Ron-Roff), smoothing) + Roff/(Ron-Roff);
% Then
% f1 = (Ron*y + Roff*(1-y))^(-1) * vpn;
%
% Need parameters: Ron, Roff, smoothing
%
% %%%%%%% f1 == 2 %%%%%%% 
% f1 = 1/Ron * exp(-Lambda *(1-s)) * vpn;
%
% Need parameters: Lambda, Ron
%
% %%%%%%% f1 == 3 %%%%%%% 
% f1 = s^n * Beta * sinh(Alpha*vpn) + chi * (exp(Gamma*vpn) - 1);
%
% Need parameters: n, Beta, Alpha, chi, Gamma
%
% %%%%%%% f1 == 4 %%%%%%% 
% f1 == 4
% f1 = A1 * s * sinh(B * vpn), if vpn>=0;
%      A2 * s * sinh(B * vpn), if vpn<0;
%
% Need parameters: A1, A2, B
%
% %%%%%%% f1 == 5 %%%%%%% 
% f1 == 5
% f1 = I0*exp(-(s*minGap+(1-s)*maxGap)/g0)*sinh(vpn/V0);
%
% Need parameters: I0, g0, V0, minGap, maxGap
%
% ----------------------------------------------------------------
%
% %%%%%%% f2 == 1 %%%%%%% 
% f2 = mu_v * Ron * (Ron*s + Roff*(1-s))^(-1) * vpn;
%
% Need parameters: mu_v, Ron, Roff
%
% %%%%%%% f2 == 2 %%%%%%% 
% f2 = a * vpn^m;
%
% Need parameters: a, m
%
% %%%%%%% f2 == 3 %%%%%%% 
%
% if f1 >= 0
%     f2 = c_off * sinh(f1/i_off) * exp(-exp((s-a_off)/wc - f1/b) - s/wc);
%
% else % if f1 < 0
%     f2 = c_on * sinh(f1/i_on) * exp(-exp(-(s-a_on)/wc + f1/b) - s/wc);
%
% Need parameters: c_off, c_on, i_off, i_on, a_off, a_on, wc, b
% 
% %%%%%%% f2 == 4 %%%%%%%
% if vpn-v_off+(v_off-v_on)*s >= 0
%     f2 = k_off * ((vpn-v_off+(v_off-v_on)*s)/v_off)^alpha_off;
%
% else % if vpn-v_off+(v_off-v_on)*s < 0
%     f2 = k_on * ((vpn-v_off+(v_off-v_on)*s)/v_on)^alpha_on;
%
% Need parameters: k_off, k_on, v_off, v_on, alpha_off, alpha_on
%
% %%%%%%% f2 == 5 %%%%%%%
%
% f2 = g(vpn) * f(s);
% 
% if vpn - (-Vn*s + Vp*(1-s)) >= 0
%     g(vpn) = Ap * (exp(vpn) - exp(-Vn*s + Vp*(1-s)))
% else % if vpn - (-Vn*s + Vp*(1-s)) < 0
%     g(vpn) = -An * (exp(vpn) - exp(-Vn*s + Vp*(1-s)))
% 
% f(s) = exp(-alphap*(s-xp))*wp(s,xp), s>=xp 
%        1, 1-xn<s<xp 
%        exp(alphan*(s-1+xn))*wn(s,xn), s<=1-xn
% 
% wp(s, xp) = (xp-s)/(1-xp)+1
% wn(s, xn) = s/(1-xn)
%
% Need parameters: Ap, An, Vp, Vn, xp, xn, alphap, alphan
%
% %%%%%%% f2 == 6 %%%%%%%
%
% T = 300;
% k = 1.3806226e-23; % Boltzmann's Constant (joules/kelvin)
% q = 1.6021918e-19; % Electron Charge (C)
%
% Gap = s*minGap+(1-s)*maxGap;
% Gamma = gamma0 - Beta0 * Gap^3;
% f2 = (maxGap-minGap) * Vel0*exp(- q*Ea/k/T)*sinh(vpn*Gamma*a0/tox*q/k/T);
%
% Need parameters: minGap, maxGap, gamma0, Beta0, Vel0, Ea, a0, tox
%
% ----------------------------------------------------------------
%

    default_f1_switch = 1;
    default_f2_switch = 4;
    if nargin < 2
        f2_switch = default_f2_switch;
        if nargin < 1
            f1_switch = default_f1_switch;
        end
    end

    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'RRAM');
    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'}); % create IO: vpn, ipn
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});
    MOD = add_to_ee_model(MOD, 'internal_unks', {'s'});
    MOD = add_to_ee_model(MOD, 'implicit_eqn_names', {'ds'});

    MOD = add_to_ee_model(MOD, 'parms', {'f1_switch', f1_switch, 'f2_switch', f2_switch});
    switch f1_switch
    case 1
        MOD = add_to_ee_model(MOD, 'parms', {'Ron', 20, 'Roff', 2e4});
    case 2
        MOD = add_to_ee_model(MOD, 'parms', {'Lambda', 6.91, 'Ron', 20});
    case 3
        MOD = add_to_ee_model(MOD, 'parms', {'n', 3, 'Beta', 1e-2, 'Alpha', 2});
        MOD = add_to_ee_model(MOD, 'parms', {'chi', 1e-6, 'Gamma', 4});
    case 4
        MOD = add_to_ee_model(MOD, 'parms', {'A1', 1e-2, 'A2', 1e-2, 'B', 2});
    case 5
        MOD = add_to_ee_model(MOD, 'parms', {'g0', 0.25, 'V0', 0.25, 'I0', 1e-3});
        MOD = add_to_ee_model(MOD, 'parms', {'maxGap', 1.7, 'minGap', 0});
    otherwise
    end

    switch f2_switch
    case 1
        MOD = add_to_ee_model(MOD, 'parms', {'mu_v', 1e6});
        if 1 ~= f1_switch && 2 ~= f1_switch
            MOD = add_to_ee_model(MOD, 'parms', {'Ron', 20});
        end
    case 2
        MOD = add_to_ee_model(MOD, 'parms', {'a', 1e4, 'm', 3});
    case 3
        MOD = add_to_ee_model(MOD, 'parms', {'c_off', 1e5, 'c_on', 1e5});
        MOD = add_to_ee_model(MOD, 'parms', {'i_off', 1e-2, 'i_on', 1e-2});
        MOD = add_to_ee_model(MOD, 'parms', {'a_off', 0.6, 'a_on', 0.4});
        MOD = add_to_ee_model(MOD, 'parms', {'wc', 1e3, 'b', 1});
    case 4
        MOD = add_to_ee_model(MOD, 'parms', {'k_off', 50, 'k_on', -50});
        MOD = add_to_ee_model(MOD, 'parms', {'v_off', 0.2, 'v_on', -0.2});
        MOD = add_to_ee_model(MOD, 'parms', {'alpha_off', 3, 'alpha_on', 3});
    case 5
        MOD = add_to_ee_model(MOD, 'parms', {'Vp', 0.16, 'Vn', 0.15, 'Ap', 4e3, 'An', 4e3});
        MOD = add_to_ee_model(MOD, 'parms', {'xp', 0.3, 'xn', 0.5, 'alphap', 1, 'alphan', 5});
    case 6
        if 5 ~= f1_switch
            MOD = add_to_ee_model(MOD, 'parms', {'maxGap', 1.7, 'minGap', 0});
        end
        MOD = add_to_ee_model(MOD, 'parms', {'Vel0', 10, 'Beta0', 0.8, 'gamma0', 16});
        MOD = add_to_ee_model(MOD, 'parms', {'Ea', 0.6, 'a0', 0.25, 'tox', 12});
    otherwise
    end

    MOD = add_to_ee_model(MOD, 'parms', {'maxslope', 1e15});
    MOD = add_to_ee_model(MOD, 'parms', {'smoothing', 1e-8, 'Kclip', 50});
    MOD = add_to_ee_model(MOD, 'parms', {'GMIN', 1e-12});

    MOD = add_to_ee_model(MOD, 'fqei', {@fe, @qe, @fi, @qi});

    MOD = finish_ee_model(MOD);
end

function out = fe(S)
    v2struct(S);

    switch f1_switch
    case 1
        % Reff = smoothclip(Ron*s + Roff*(1-s), smoothing);
        % f1 = vpn / Reff;
        % Better formula below, as we have better control using smoothing
        y = smoothclip(s - Roff/(Ron-Roff), smoothing) + Roff/(Ron-Roff);
        f1 = vpn / (Ron*y + Roff*(1-y));
    case 2
        f1 = 1/Ron * safeexp(-Lambda * (1-s), maxslope) * vpn;
    case 3
        f1 = s^n*Beta*safesinh(Alpha*vpn, maxslope) + chi*(safeexp(Gamma*vpn, maxslope)-1);
    case 4
		f1p = A1 * s * safesinh(B * vpn, maxslope);
		f1n = A2 * s * safesinh(B * vpn, maxslope);
		f1 = smoothswitch(f1n, f1p, vpn, smoothing);
    case 5
        f1 = I0*safeexp(-(s*minGap+(1-s)*maxGap)/g0, maxslope)*safesinh(vpn/V0, maxslope);
    otherwise
    end

    out = f1 + GMIN*vpn; % ipn
end

function out = qe(S)
    out = 0; % itb
end

function out = fi(S)
    v2struct(S);

    switch f2_switch
    case 1
        f2 = mu_v * Ron * fe(S);
    case 2
        f2 = a * (vpn)^m;
    case 3
        i = fe(S);
		f2p = c_off * safesinh(i/i_off, maxslope) * safeexp(-safeexp((s-a_off)/wc - i/b, maxslope) - s/wc, maxslope);
		f2n = c_on * safesinh(i/i_on, maxslope) * safeexp(-safeexp(-(s-a_on)/wc + i/b, maxslope) - s/wc, maxslope);
		f2 = smoothswitch(f2n, f2p, i, smoothing);
    case 4
        Vstar = vpn-v_off+(v_off-v_on)*s;
		f2p = k_off * (Vstar/v_off)^alpha_off;
		f2n = k_on * (Vstar/v_on)^alpha_on;
		f2 = smoothswitch(f2n, f2p, Vstar, smoothing);
    case 5
		Vstar = vpn - (-Vn*s + Vp*(1-s));
		g_of_vpnp = Ap * (safeexp(vpn, maxslope) - safeexp(-Vn*s + Vp*(1-s), maxslope));
		g_of_vpnn = -An * (safeexp(-vpn, maxslope) - safeexp(+Vn*s - Vp*(1-s), maxslope));
		g_of_vpn = smoothswitch(g_of_vpnn, g_of_vpnp, Vstar, smoothing);

		f_of_sp = smoothswitch(1, safeexp(-alphap*(s-xp), maxslope), s-xp, smoothing);
		f_of_s = smoothswitch(safeexp(alphan*(s-1+xn), maxslope), f_of_sp, s-1+xn, smoothing);

        f2 = g_of_vpn * f_of_s;
    case 6
        T = 300;
        k = 1.3806226e-23; % Boltzmann's Constant (joules/kelvin)
        q = 1.6021918e-19; % Electron Charge (C)

        Gap = s*minGap+(1-s)*maxGap;
        Gamma = gamma0 - Beta0 * Gap^3;
        f2 = 1e9*(maxGap-minGap) * Vel0*exp(- q*Ea/k/T)*safesinh(vpn*Gamma*a0/tox*q/k/T, maxslope);
    otherwise
    end

    f2 = 1e-9*f2;
    % f2 = 0;

    Fw1 = smoothstep(0-s, smoothing);
    Fw2 = smoothstep(s-1, smoothing);
    clip_0 = (safeexp(Kclip*(0-s), maxslope) - f2) * Fw1;
    clip_1 = (-safeexp(Kclip*(s-1), maxslope) - f2) * Fw2;
    % clip_0 = 0;
    % clip_1 = 0;

    % out = 1e-9 * (f2 + clip_0 + clip_1);
    out =f2 + clip_0 + clip_1;
    % out = f2;
end

function out = qi(S)
    v2struct(S);
    out = -1e-9*s;
end

function y = safesinh(x, maxslope)
    y = (safeexp(x, maxslope) - safeexp(-x, maxslope))/2;
end % safesinh
