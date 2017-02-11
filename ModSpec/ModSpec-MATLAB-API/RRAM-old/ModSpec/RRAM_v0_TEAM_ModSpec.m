function MOD = RRAM_v0_TEAM_ModSpec(f1_switch, f2_switch)
%
%TEAM equations:
%
% ipn = f1(vpn, s);
% d/dt s = f2(vpn, s);
% 
% ----------------------------------------------------------------
% 
% f1 = (Ron*s/D + Roff*(1-s/D))^(-1) * vpn;
%
% f1 = s^n * Beta * sinh(Alpha*vpn) + chi * (exp(Gamma*vpn) - 1);
%
% f1 = 1/Ron * exp(-Lambda * (s - xon)/(xoff-xon)) * vpn;
%
% ----------------------------------------------------------------
%
% We always keep 0 <= s <= 1 and scale the related parameters.
%
% f1 == 1
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
% f1 == 2
% f1 = 1/Ron * exp(-Lambda * s) * vpn;
%
% Need parameters: Lambda, Ron
%
% f1 == 3
% f1 = s^n * Beta * sinh(Alpha*vpn) + chi * (exp(Gamma*vpn) - 1);
%
% Need parameters: n, Beta, Alpha, chi, Gamma
%
% ----------------------------------------------------------------
%
% f2 = mu_v * Ron * (Ron*s + Roff*(1-s))^(-1) * vpn;
%
% f2 = a * vpn^m;
%
% if f1 >= 0
%     f2 = c_off * sinh(f1/i_off) * exp(-exp((s-a_off)/wc - f1/b) - s/wc);
%
% else % if f1 < 0
%     f2 = c_on * sinh(f1/i_on) * exp(-exp(-(s-a_on)/wc + f1/b) - s/wc);
%
% VTEAM:
% if vpn > voff
%     f2 = koff * (vpn/voff-1)^alpha_off;
%
% elseif vpn < von
%     f2 = kon * (vpn/von-1)^alpha_on;
%
% else
%     f2 = 0;
% ----------------------------------------------------------------
%
% f2 == 1
% f2 = mu_v * Ron * (Ron*s + Roff*(1-s))^(-1) * vpn;
%
% Need parameters: mu_v, Ron, Roff
%
% f2 == 2
% f2 = a * vpn^m;
%
% Need parameters: a, m
%
% f2 == 3
%
% if f1 >= 0
%     f2 = c_off * sinh(f1/i_off) * exp(-exp((s-a_off)/wc - f1/b) - s/wc);
%
% else % if f1 < 0
%     f2 = c_on * sinh(f1/i_on) * exp(-exp(-(s-a_on)/wc + f1/b) - s/wc);
%
% Need parameters: c_off, c_on, i_off, i_on, a_off, a_on, wc, b
% 
% f2 == 4
% if vpn-v_off+(v_off-v_on)*s >= 0
%     f2 = k_off * ((vpn-v_off+(v_off-v_on)*s)/v_off)^alpha_off;
%
% else % if vpn-v_off+(v_off-v_on)*s < 0
%     f2 = k_on * ((vpn-v_off+(v_off-v_on)*s)/v_on)^alpha_on;
%
% Need parameters: k_off, k_on, v_off, v_on, alpha_off, alpha_on
%
% ----------------------------------------------------------------
%

    if nargin < 1
        f1_switch = 1;
        f2_switch = 4; 
    elseif nargin < 2
        f2_switch = 4; 
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
        MOD = add_to_ee_model(MOD, 'parms', {'Ron', 1e2, 'Roff', 2e5});
    case 2
        MOD = add_to_ee_model(MOD, 'parms', {'Lambda', 7.6, 'Ron', 1e2});
    case 3
        MOD = add_to_ee_model(MOD, 'parms', {'n', 14, 'Beta', 1, 'Alpha', 2});
        MOD = add_to_ee_model(MOD, 'parms', {'chi', 0.01, 'Gamma', 4});
    otherwise
    end

    switch f2_switch
    case 1
        MOD = add_to_ee_model(MOD, 'parms', {'mu_v', 1e6});
        if 1 ~= f1_switch && 2 ~= f1_switch
            MOD = add_to_ee_model(MOD, 'parms', {'Ron', 1e2});
        end
    case 2
        MOD = add_to_ee_model(MOD, 'parms', {'a', 1e4, 'm', 13});
    case 3
        MOD = add_to_ee_model(MOD, 'parms', {'c_off', 1e3, 'c_on', 1e3});
        MOD = add_to_ee_model(MOD, 'parms', {'i_off', 115e-6, 'i_on', 8.9e-6});
        MOD = add_to_ee_model(MOD, 'parms', {'a_off', 0.6, 'a_on', 0.4});
        MOD = add_to_ee_model(MOD, 'parms', {'wc', 0.107, 'b', 500e-6});
    case 4
        MOD = add_to_ee_model(MOD, 'parms', {'k_off', 100, 'k_on', -100});
        MOD = add_to_ee_model(MOD, 'parms', {'v_off', 0.3, 'v_on', -0.3});
        MOD = add_to_ee_model(MOD, 'parms', {'alpha_off', 3, 'alpha_on', 3});
    otherwise
    end

    MOD = add_to_ee_model(MOD, 'parms', {'maxslope', 1e15});
    MOD = add_to_ee_model(MOD, 'parms', {'smoothing', 1e-10, 'Kclip', 10});
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
        f1 = 1/Ron * safeexp(-Lambda * s, maxslope) * vpn;
    case 3
        f1 = s^n*Beta*safesinh(Alpha*vpn, maxslope) + chi*(safeexp(Gamma*vpn, maxslope)-1);
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
        if i >= 0
            f2 = c_off * safesinh(i/i_off, maxslope) * safeexp(-safeexp((s-a_off)/wc - i/b, maxslope) - s/wc, maxslope);
        else % if i < 0
            f2 = c_on * safesinh(i/i_on, maxslope) * safeexp(-safeexp(-(s-a_on)/wc + i/b, maxslope) - s/wc, maxslope);
        end
    case 4
        Vstar = vpn-v_off+(v_off-v_on)*s;
        if Vstar >= 0
            f2 = k_off * (Vstar/v_off)^alpha_off;
        else % if Vstar < 0
            f2 = k_on * (Vstar/v_on)^alpha_on;
        end
    otherwise
    end

    % f2 = 1e-9*f2;
    % f2 = 0;

    Fw1 = smoothstep(0-s, smoothing);
    Fw2 = smoothstep(s-1, smoothing);
    clip_0 = (safeexp(Kclip*(0-s), maxslope) - f2) * Fw1;
    clip_1 = (-safeexp(Kclip*(s-1), maxslope) - f2) * Fw2;
    % clip_0 = 0;
    % clip_1 = 0;

    out = 1e-6 * (f2 + clip_0 + clip_1);
    % out =f2 + clip_0 + clip_1;
    % out = f2;
end

function out = qi(S)
    v2struct(S);
    out = -1e-6*s;
end

function y = safesinh(x, maxslope)
    y = (safeexp(x, maxslope) - safeexp(-x, maxslope))/2;
end % safesinh
