function MOD = memristorModSpec(uniqID, f1_switch, f2_switch)
%function MOD = memristorModSpec(uniqID, f1_switch, f2_switch)
%
%This function returns a ModSpec model for a memristor.
%
%The template of a memristor model can be written as 
%
%     ipn = f1(vpn, s);        (1)
%     d/dt s = f2(vpn, s);     (2)
%
%By defining different versions of f1(.,.) and f2(.,.), this function
%implements a collection of memristor models. The type of the model is
%controlled by two arguments: f1_switch and f2_switch.
% 
%Note that internal unknown s in (1) and (2) doesn't have a direct physical
%meaning. At the same vpn, the larger the value of s, the larger the current
%ipn. We try to keep 0 <= s <= 1 in simulation and scale other related
%parameters and variables. For example, for RRAM devices, the tunnelling gap
%can be represented by s*minGap+(1-s)*maxGap.
% 
% ----------------------------------------------------------------
%The implementation of f1(.,.) is controlled by argument f1_switch: 
% 
% - f1_switch == 1: shifting between two resistors
%
%     f1 = (Ron*s + Roff*(1-s))^(-1) * vpn;
%
%     Note: We have to ensure that Roff - (Ron-Roff) *s ~= 0,
%         which is to say s ~= Roff/(Ron-Roff);
%     Therefore, in the actual implementation, we use
%       y = smoothclip(s - Roff/(Ron-Roff), smoothing) + Roff/(Ron-Roff);
%     Then
%       f1 = (Ron*y + Roff*(1-y))^(-1) * vpn;
%
%   Need to define parameters: Ron, Roff.
%
% - f1_switch == 2:
%
%     f1 = 1/Ron * exp(-Lambda *(1-s)) * vpn;
%
%   Need define parameters: Lambda, Ron.
%
% - f1_switch == 3: sinh(vpn) adjusted by exp(vpn), modulated by s^n.
%
%     f1 = s^n * Beta * sinh(Alpha*vpn) + chi * (exp(Gamma*vpn) - 1);
%
%   Need to define parameters: n, Beta, Alpha, chi, Gamma.
%
% - f1_switch == 4: asymmetric sinh(vpn) , modulated by s.
%
%     f1 = A1 * s * sinh(B * vpn), if vpn>=0;
%     f1 = A2 * s * sinh(B * vpn), if vpn<0;
%
%   Need to define parameters: A1, A2, B.
%
% - f1_switch == 5: sinh(vpn) , modulated by exp(-Gap/g0).
%     Gap is represented as s*minGap+(1-s)*maxGap.
%
%     f1 = I0*exp(-(s*minGap+(1-s)*maxGap)/g0)*sinh(vpn/V0);
%
%   Need to define parameters: I0, g0, V0, minGap, maxGap.
%
% ----------------------------------------------------------------
%The implementation of f2(.,.) is controlled by argument f2_switch: 
%
% - f2 == 1: linear ion drift model
%
%     f2 = mu_v * Ron * f1(vpn, s);
%
%     Need to define parameters: mu_v, Ron.
%
% - f2 == 2: nonlinear ion drift model
%
%     f2 = a * vpn^m;
%
%     Need to define parameters: a, m
%
% - f2 == 3: Simmons tunnelling barrier model
%
%     i = f1(vpn, s);
%     if i >= 0
%         f2 = c_off * sinh(i/i_off) * exp(-exp((s-a_off)/wc - i/b) - s/wc);
%     else % if f1 < 0
%         f2 = c_on * sinh(i/i_on) * exp(-exp(-(s-a_on)/wc + i/b) - s/wc);
%
%     We use the smooth version of this if-else statement:
%       i = f1(vpn, s);
%       f2p = c_off * safesinh(i/i_off, maxslope)
%           * safeexp(-safeexp((s-a_off)/wc - i/b, maxslope) - s/wc, maxslope);
%       f2n = c_on * safesinh(i/i_on, maxslope)
%           * safeexp(-safeexp(-(s-a_on)/wc + i/b, maxslope) - s/wc, maxslope);
%       f2 = smoothswitch(f2n, f2p, i, smoothing);
%
%     Need to define parameters: c_off, c_on, i_off, i_on, a_off, a_on, wc, b.
%     
% - f2 == 4: modified VTEAM model
%
%   S. Kvatinsky, M. Ramadan, E. G. Friedman and A. Kolodny, "VTEAM: A General
%   Model for Voltage-Controlled Memristors," in IEEE Transactions on Circuits
%   and Systems II: Express Briefs, vol. 62, no. 8, pp. 786-790, Aug. 2015.
%   doi: 10.1109/TCSII.2015.2433536
%
%     if vpn-v_off+(v_off-v_on)*s >= 0
%         f2 = k_off * ((vpn-v_off+(v_off-v_on)*s)/v_off)^alpha_off;
%     else % if vpn-v_off+(v_off-v_on)*s < 0
%         f2 = k_on * ((vpn-v_off+(v_off-v_on)*s)/v_on)^alpha_on;
%
%     We use the smooth version of this if-else statement:
%
%         Vstar = vpn-v_off+(v_off-v_on)*s;
%         f2p = k_off * (Vstar/v_off)^alpha_off;
%         f2n = k_on * (Vstar/v_on)^alpha_on;
%         f2 = smoothswitch(f2n, f2p, Vstar, smoothing);
%
%     Need to define parameters: k_off, k_on, v_off, v_on, alpha_off, alpha_on.
%
% - f2 == 5: modified Yakopcic model
%
%   C. Yakopcic, T. M. Taha, G. Subramanyam and R. E. Pino, "Generalized
%   Memristive Device SPICE Model and its Application in Circuit Design," in
%   IEEE Transactions on Computer-Aided Design of Integrated Circuits and
%   Systems, vol.  32, no. 8, pp. 1201-1214, Aug. 2013.
%   doi: 10.1109/TCAD.2013.2252057
%
%     f2 = g(vpn) * f(s);
%
%     where 
% 
%     g(vpn) = Ap * (exp(vpn) - exp(-Vn*s + Vp*(1-s)))
%                  if vpn - (-Vn*s + Vp*(1-s)) >= 0,
%              -An * (exp(vpn) - exp(-Vn*s + Vp*(1-s)))
%                  otherwise.
%
%     f(s) = exp(-alphap*(s-xp)), s>=xp 
%            1, 1-xn<s<xp 
%            exp(alphan*(s-1+xn)), s<=1-xn
% 
%     We use the smooth version of these if-else statements. See the actual
%     code for implementation details.
%
%     Need to define parameters: Ap, An, Vp, Vn, xp, xn, alphap, alphan.
%
% - f2 == 6: Standford/ASU RRAM model
%
%     Gap = s*minGap+(1-s)*maxGap;
%     Gamma = gamma0 - Beta0 * Gap^3;
%     f2 = 1e9 * (maxGap-minGap) * Vel0 * exp(- q*Ea/k/T)
%          * sinh(vpn*Gamma*a0/tox*q/k/T);
%
%     Need to define parameters: minGap, maxGap, gamma0, Beta0, Vel0, Ea, a0,
%                                tox.
% ----------------------------------------------------------------
% 
%Arguments:
% - uniqID: (optional) a string for unique identification. Eg, 'M1'.
%           By default, it is ''.
% - f1_switch: (optional) an integer from [1, 5].
%           By default, it is 1.
% - f2_switch: (optional) an integer from [1, 6].
%           By default, it is 5.
%
%Return values:
% - MOD:    a ModSpec object for the memristor.
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'p', 'n'} (the two nodes of the memristor).
%
% - parameters and their default values:
%   [TODO]
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO name(s):                      vpn, ipn
% - explicit output name(s):         ipn
% - other IO name(s) (vecX):         vpn
% - implicit unknown name(s) (vecY): s
% - input name(s) (vecU):            {}
%
% 2. equations:
% - model equations:
%   ipn = f1(vpn, s);
%   d/dt s = f2(vpn, s);
% - fe: f1(vpn, s);
% - qe: 0;
% - fi: 1e-9 * f2(vpn, s);
% - qi: 1e-9 * (-s);
%
%Examples
%--------
% % adding a memristor to an existing circuitdata structure
% cktdata = add_element(cktdata, memristorModSpec(), 'X1', {'n1', 'n2'});
% %                                   ^         ^          ^
% %                       memristor model      name      nodes
%
%See also
%--------
% 
% add_element, circuitdata[TODO], ModSpec, supported_ModSpec_devices[TODO],
% DAEAPI, DAE_concepts

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%change log:
%-----------
%2016/04/13: Tianshi Wang <tianshi@berkeley.edu> Created.

    default_uniqID = '';
    default_f1_switch = 1;
    default_f2_switch = 5;

    % Verbose, but logically clear enough.
    % Whichever branch it ends up in, there should be three assignments.
    if nargin < 1
        f2_switch = default_f2_switch;
        f1_switch = default_f1_switch;
        MOD.uniqID = default_uniqID;
    elseif nargin < 2
        if isstr(uniqID)
            f2_switch = default_f2_switch;
            f1_switch = default_f1_switch;
            MOD.uniqID = uniqID;
        else
            f2_switch = default_f2_switch;
            f1_switch = uniqID;
            MOD.uniqID = default_uniqID;
        end
    elseif nargin < 3
        if isstr(uniqID)
            f2_switch = default_f2_switch;
            % f1_switch = f1_switch;
            MOD.uniqID = uniqID;
        else
            f2_switch = f1_switch;
            f1_switch = uniqID;
            MOD.uniqID = default_uniqID;
        end
    else
        % f2_switch = f2_switch;
        % f1_switch = f1_switch;
        MOD.uniqID = uniqID;
    end

    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'memristor');
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
