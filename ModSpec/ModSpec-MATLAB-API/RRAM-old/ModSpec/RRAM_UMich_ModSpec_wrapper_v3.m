function MOD = RRAM_ModSpec_wrapper(uniqID)
%function MOD = RRAM_ModSpec_wrapper(uniqID)
% This function creates a ModSpec model for a resistive random-access memory
% (RRAM) cell.
%
% verion 3: copied from v2, change sign to a hacksign (at the bottom),
%           not exactly singular, but cond number is 1.6e15, because of 
%           scaling issues, ie, the third function is always too small
%
% The model is implemented based on the SPICE model published in:
%     Sheridan, Patrick, et al. "Device and SPICE modeling of RRAM devices."
%     Nanoscale 3.9 (2011): 3833-3840.
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
% TODO: init value for l, how to include it in the model specification
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
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO names:                        vpn  ipn
% - explicit output name(s):         ipn
% - other IO name(s) (vecX):         vpn
%
% - implicit unknown name(s) (vecY): l
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
    % m = 0.31*9.1e-31; % Effective Mass in a-Si from the SPICE model
    m = 0.31*9.10938215e-31; % Effective Electron Mass in a-Si: amorphous Silicon (kg)
                       % TODO: is there a higher-precision version?
    plank = 6.6260755e-34; % Plank's Constant (joules*sec)

    if 1 == strcmp(eori,'e') % e
        if 1 == strcmp(forq, 'f') % f
			% Alpha = 1.4e19; % from the SPICE model
			Alpha = 2*sqrt(2*m) / (plank/(2*pi));

            SMALLNUM1 = 1e-6; % a hack
            SMALLNUM2 = 1e-6; % a hack
            if abs(vpn) < SMALLNUM1
				high_bias = 0;
            else
            % TODO: elseif l < h - SMALLNUM2 * h;
				F0 = 2*Alpha*sqrt(q*Phi0^3);
				F = abs(vpn)/(h-l);
                high_bias = 4*pi*m*q^2/ (plank^3*Alpha^2*Phi0) * F^2 * ...
                        safeexp(-F0/F, maxslope);
            end

            if l < h - SMALLNUM2 * h;
				c1_l = Alpha * (h - l) / (2*sqrt(Phi0*q));
				% low_bias = 8*pi*m*q*k*T / plank^3 * pi/ ( c1_l * sin(pi*c1_l *k*T));
				low_bias = 8*pi*m*q / plank^3 / c1_l^2;
            else
                C = 8*pi*m*q / plank^3 * 4 * Phi0*q / Alpha^2;  
                % note: C*1/(h-l)^2 is the function we try to approximate here
                slope = C*2 / (h*SMALLNUM2)^3;
				low_bias = slope * (l - (h - SMALLNUM2 * h)) + C/(h*SMALLNUM2)^2;
            end

            out(1,1) = hacksign(vpn) * Area * ( ...
                      (1-smoothstep(abs(vpn)-Phi0, smoothing)) * low_bias + ...
                      smoothstep(abs(vpn)-Phi0, smoothing)     * high_bias);
        else % q
            out(1,1) = 0;
        end % forq
    else % i
        if 1 == strcmp(forq, 'f') % f
            Vt = k*T/q;
            ion_flow = Beta * safeexp(-Ua/Vt, maxslope) * mysinh(vpn * Kappa/T, maxslope);
            % TODO: properly update vecvalder to support sinh, then change mysinh back

            % % smooth version
            clipfactor = 1 - smoothstep(-ion_flow, smoothing)*smoothstep(-1e9*l, smoothing);
            out(1,1) = clipfactor * ion_flow;

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

function y = hacksign(x)
    if x>=0
        y = 1;
    else
        y = -1;
    end
end % mysinh
