function MOD = RRAM_v0_ModSpec()
    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'RRAM');
    MOD = add_to_ee_model(MOD, 'terminals', {'t', 'b'}); % create IO: vtb, itb
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'itb'});
    MOD = add_to_ee_model(MOD, 'internal_unks', {'Gap'});
    MOD = add_to_ee_model(MOD, 'implicit_eqn_names', {'dGap'});

    MOD = add_to_ee_model(MOD, 'parms', {'g0', 0.25, 'V0', 0.25, 'I0', 1e-3});
    MOD = add_to_ee_model(MOD, 'parms', {'Vel0', 10, 'Beta', 0.8, 'gamma0', 16});
    MOD = add_to_ee_model(MOD, 'parms', {'Ea', 0.6, 'a0', 0.25, 'tox', 12});
    MOD = add_to_ee_model(MOD, 'parms', {'maxGap', 1.7, 'minGap', 0});
    MOD = add_to_ee_model(MOD, 'parms', {'maxslope', 1e15});
    MOD = add_to_ee_model(MOD, 'parms', {'smoothing', 1e-8, 'Kclip', 50});
    MOD = add_to_ee_model(MOD, 'parms', {'GMIN', 1e-12});

    MOD = add_to_ee_model(MOD, 'fqei', {@fe, @qe, @fi, @qi});

    MOD = add_to_ee_model(MOD, 'limited_var', {'vtblim1', 'vtblim2'});
    MOD = add_to_ee_model(MOD, 'limited_matrix', [1, 0; 1, 0]);
    MOD = add_to_ee_model(MOD, 'limiting', @limiting);
    MOD = add_to_ee_model(MOD, 'initGuess', @initGuess);

    MOD = finish_ee_model(MOD);
end

function out = fe(S)
    v2struct(S);
    out = I0*safeexp(-Gap/g0, maxslope)*sinh(vtblim1/V0) + GMIN*vtb; % itb
end

function out = qe(S)
    out = 0; % itb
end

function out = fi(S)
    v2struct(S);
    T = 300;
    k = 1.3806226e-23; % Boltzmann's Constant (joules/kelvin)
    q = 1.6021918e-19; % Electron Charge (C)

    Gamma = gamma0 - Beta * Gap^3;
    ddt_Gap = - Vel0 * exp(- q*Ea/k/T) * sinh(vtblim2 * Gamma*a0/tox*q/k/T);

    Fw1 = smoothstep(minGap-Gap, smoothing);
    Fw2 = smoothstep(Gap-maxGap, smoothing);
    clip_minGap = (safeexp(Kclip*(minGap-Gap), maxslope) - ddt_Gap) * Fw1;
    clip_maxGap = (-safeexp(Kclip*(Gap-maxGap), maxslope) - ddt_Gap) * Fw2;

    out = ddt_Gap + clip_minGap + clip_maxGap;
end

function out = qi(S)
    v2struct(S);
    out = - 1e-9 * Gap;
end

function vtblimInitout = initGuess(S)
    v2struct(S);
    vtblimInitout(1, 1) = 0;
    vtblimInitout(2, 1) = 0;
end

function vtblimout = limiting(S)
    v2struct(S);
    T = 300;
    k = 1.3806226e-23; % Boltzmann's Constant (joules/kelvin)
    q = 1.6021918e-19; % Electron Charge (C)
    vtblimout(1, 1) = sinhlim(vtb, vtblim1, 1/V0);
    Gamma = gamma0 - Beta * Gap^3;
    vtblimout(2, 1) = sinhlim(vtb, vtblim2, Gamma*a0/tox*q/k/T);
end

function xlim = sinhlim(x, xold, k)
    % return xlim such that sinh(k*xlim) = sinh(k*xold) + k*cosh(k*xold) * (x - xold)
    ylim = sinh(k*xold) + k*cosh(k*xold) * (x - xold);
    xlim = log(ylim + sqrt(1+ylim^2)) / k; 
end
