function MOD = RRAM_ModSpec_wrapper(uniqID)
%function MOD = RRAM_ModSpec_wrapper(uniqID)
% This function creates a ModSpec model for a resistive random-access memory
% (RRAM) cell.
%
% verion 1: copied from v0, added GMIN
% verion 0: copied from UMich v5's fi/qi and Stanford v2's itb formulation.
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'RRAM1'
%
%Return values:
% - MOD:    a ModSpec object for the RRAM UMich model
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'p', 'n'} (positive and negative terminals).
%
% - parameters:
% - 'Area' (device area [m^2])
%           default: 1e-18
% - 'Ua'   (ion barrier height [V])
%           default: 0.87
% - 'h'    (film thickness [m])
%           default: 5e-9
% - 'Phi0' (electron barrier height [V])
%           default: 1
% - 'Beta' (parameter equal to the attempt frequency multiplied by the hopping
%           distance)
%           default: 10.56
% - 'Kappa' (parameter that determines the rate dependence on applied voltage)
%           default: 1903.84
% - 'T'     (temperature [K])
%           default: 300
% - 'smoothing' (smoothing factor)
%           default: 1e-5
% - 'maxslope' (maxmum slope in safeexp)
%           default: 1e15
% - TODO: update parameters
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO names:                        vpn  ipn
% - explicit output name(s):         ipn
% - other IO name(s) (vecX):         vpn
%
% - implicit unknown name(s) (vecY): l (in nm)
% - input names (vecU):              {} % TODO: variation comes in here if needed
% - limited variable (vecLim):       {}
%
% 2. equations: %TODO
%
%
%Examples
%--------
%TODO
%
%See also
%--------
% 
% add_element, circuitdata[TODO], ModSpec, DAEAPI, DAE_concepts
%

    MOD = ee_model();

    MOD = add_to_ee_model(MOD, 'modelname', 'RRAM_ModSpec_wrapper');
    MOD = add_to_ee_model(MOD, 'description', 'TODO');

    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});

    MOD = add_to_ee_model(MOD, 'internal_unks', {'l'});

    MOD = add_to_ee_model(MOD, 'parms', {'Area', 1e-18});
          % device area (m^2)
    MOD = add_to_ee_model(MOD, 'parms', {'Ua', 0.87});
          % ion barrier height (V)
    MOD = add_to_ee_model(MOD, 'parms', {'h', 5e-9});
          % film thickness(m)
    MOD = add_to_ee_model(MOD, 'parms', {'Phi0', 1});
          % electron barrier height (V)
    % TODO: init value for l, how to include it in the model specification
    MOD = add_to_ee_model(MOD, 'parms', {'Beta', 10.56});
          % parameter equal to the attempt frequency multiplied by the hopping
          % distance
    MOD = add_to_ee_model(MOD, 'parms', {'Kappa', 1903.84});
          % parameter that determines the rate dependence on applied voltage
    MOD = add_to_ee_model(MOD, 'parms', {'T', 300});
          % temperature
    MOD = add_to_ee_model(MOD, 'parms', {'smoothing', 1e-5});
          % smoothing factor
    MOD = add_to_ee_model(MOD, 'parms', {'maxslope', 1e15});
          % maxmum slope in safeexp

    % parameters below are fitting parameters from the Stanford model
    %     see RRAM_Stanford_ModSpec_wapper_v2.m
    MOD = add_to_ee_model(MOD, 'parms', {'I0', 1000e-6});
    MOD = add_to_ee_model(MOD, 'parms', {'g0', 0.25e-9});
    MOD = add_to_ee_model(MOD, 'parms', {'V0', 0.25});

    MOD = add_to_ee_model(MOD, 'parms', {'GMIN', 1e-12});

    MOD = add_to_ee_model (MOD, 'fe', @fe);
    MOD = add_to_ee_model (MOD, 'qe', @qe);
    MOD = add_to_ee_model (MOD, 'fi', @fi);
    MOD = add_to_ee_model (MOD, 'qi', @qi);

    MOD = finish_ee_model(MOD);

end

function out = fe(S)
    out = fqei(S, 'f', 'e');
end

function out = qe(S)
    out = fqei(S, 'q', 'e');
end

function out = fi(S)
    out = fqei(S, 'f', 'i');
end

function out = qi(S)
    out = fqei(S, 'q', 'i');
end

function out = fqei(S, forq, eori)

    v2struct(S);

    k = 1.3806226e-23; % Boltzmann's Constant (joules/kelvin)
    q = 1.6021918e-19; % Electron Charge (C)

    if 1 == strcmp(eori,'e') % e
        if 1 == strcmp(forq, 'f') % f
			out(1,1) = I0 * safeexp(-(h - 1e-9*l)/g0, maxslope) * mysinh(vpn/V0, maxslope);
            out(1,1) = out(1,1) + GMIN * vpn;
        else % q
            out(1,1) = 0;
        end % forq
    else % i
        if 1 == strcmp(forq, 'f') % f
            Vt = k*T/q;
            ion_flow = Beta * safeexp(-Ua/Vt, maxslope) * mysinh(vpn * Kappa/T, maxslope);
            % TODO: properly update vecvalder to support sinh, then change mysinh back

            % % smooth version
            clipfactor = 1 - smoothstep(-ion_flow, smoothing)*smoothstep(-l, smoothing);
            out(1,1) = 1e9*clipfactor * ion_flow;

            % % original:
            % prev_underflow = double((sign(l) + sign(ion_flow) + 1) > 0);
            % out(1,1) = prev_underflow * ion_flow;

            % % if-else version
            % if l <= 0 && ion_flow < 0
            %     out(1,1) = 0;
            % else
            %     out(1,1) = ion_flow;
            % end

        else % q
            out(1,1) = -l;
        end
    end
end

%%%%%%%%%%%%%  Internal Functions  %%%%%%%%%%%%%%%%%

function y = mysinh(x, maxslope)
    y = (safeexp(x, maxslope) - safeexp(-x, maxslope))/2;
end % mysinh
