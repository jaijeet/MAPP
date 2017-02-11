function MOD = RRAM_ModSpec()
%function MOD = RRAM_ModSpec()
%
%This function returns a ModSpec model for an RRAM device based on the
%Standford/ASU model.
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'t', 'b'} (the two nodes/electrodes of the RRAM).
%
% - parameters and their default values:
%   - 'g0' (fitting parameter): 0.25.
%   - 'V0' (fitting parameter): 0.25.
%   - 'I0' (fitting parameter): 1e-3.
%   - 'Vel0' (fitting parameter): 10.
%   - 'Beta' (fitting parameter): 0.8.
%   - 'gamma0' (fitting parameter): 16.
%   - 'Ea' (fitting parameter): 0.6.
%   - 'a0' (atom spacing): 0.25.
%   - 'tox' (oxide thickness in nm): 12.
%   - 'maxGap' (upper bound of gap in nm): 1.7.
%   - 'minGap' (lower bound of gap in nm): 0.
%   - 'maxslope' (maximum slope in safeexp and safesinh): 1e15.
%   - 'smoothing' (smoothing factor): 1e-8.
%   - 'Kclip' (scaling factor in clipping funcs to enforce gap's bounds): 50.
%   - 'GMIN' (minimum conductance between electrodes): 1e-12.
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO name(s):                      vtb, itb
% - explicit output name(s):         itb
% - other IO name(s) (vecX):         vtb
% - implicit unknown name(s) (vecY): Gap
% - input name(s) (vecU):            {}
%
% 2. equations:
% - basic RRAM equations:
%     itb = I0*safeexp(-Gap/g0, maxslope)*sinh(vtblim1/V0) + GMIN*vtb;
%     Gamma = gamma0 - Beta * Gap^3;
%     d/dt 1e-9 * Gap = - Vel0 * exp(- q*Ea/k/T)
%                       * sinh(vtblim2 * Gamma*a0/tox*q/k/T);
%
%   Note: on top of these equations, we added clipping functions to enforce
%         that Gap has upper and lower bounds in simulation. To see the
%         implementation, please directly look at the model code.
%
%Examples
%--------
% % adding a RRAM to an existing circuitdata structure
% cktdata = add_element(cktdata, RRAM_ModSpec(), 'R1', {'n1', 'n2'});
% %                                   ^           ^          ^       
% %                            RRAM model        name      nodes     
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
