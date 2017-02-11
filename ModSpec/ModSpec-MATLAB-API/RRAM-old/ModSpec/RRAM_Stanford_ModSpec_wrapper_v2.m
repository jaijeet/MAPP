function MOD = RRAM_ModSpec_wrapper(uniqID)
%function MOD = RRAM_ModSpec_wrapper(uniqID)
% Note: v1 applies GMIN hack, trying to get rid of matrix singularity problem,
%       but is not working;
%       v2 scales internal unk 'Gap' in 'nm', but is not working
% This function creates a ModSpec model for a resistive random-access memory
% (RRAM) cell.
%
% The model is implemented based on the Verilog A model published as:
%     Jiang, Z., Wong, H. (2014). Stanford University Resistive-Switching
%     Random Access Memory (RRAM) Verilog-A Model. nanoHUB.
%     doi:10.4231/D37H1DN48	
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'RRAM1'
%
%Return values:
% - MOD:    a ModSpec object for the RRAM Stanford model
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'p', 'n'} (positive and negative terminals).
%
% - parameters:
% TODO: update their descriptions
%    - 'g0', 0.25e-9
%    - 'V0', 0.25
%    - 'Vel0', 10
%    - 'I0', 1000e-6
%    - 'Beta', 0.8
%    - 'gamma0', 16
%    - 'deltaGap0', 0.02
%    - 'T_smth', 500
%    - 'Ea', 0.6
%    - 'a0', 0.25e-9
%    - 'T_ini', 273 + 25
%    - 'F_min', 1.4e9
%    - 'gap_ini', 2e-10
%    - 'gap_min', 2e-10
%    - 'gap_max', 17e-10
%    - 'Rth', 2.1e3
%    - 'tox', 12e-9
%    - 'maxslope', 1e15
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO names:                        vpn  ipn
% - explicit output name(s):         {}
% - other IO name(s) (vecX):         Gap
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

    MOD = add_to_ee_model(MOD, 'terminals', {'t', 'b'});

    MOD = add_to_ee_model(MOD, 'explicit_outs', {});

    MOD = add_to_ee_model(MOD, 'internal_unks', {'Gap'});

    MOD = add_to_ee_model(MOD, 'parms', {'g0', 0.25e-9});
    MOD = add_to_ee_model(MOD, 'parms', {'V0', 0.25});
    MOD = add_to_ee_model(MOD, 'parms', {'Vel0', 10});
    MOD = add_to_ee_model(MOD, 'parms', {'I0', 1000e-6});
    MOD = add_to_ee_model(MOD, 'parms', {'Beta', 0.8});
    MOD = add_to_ee_model(MOD, 'parms', {'gamma0', 16});
    MOD = add_to_ee_model(MOD, 'parms', {'deltaGap0', 0.02});
    MOD = add_to_ee_model(MOD, 'parms', {'T_smth', 500});
    MOD = add_to_ee_model(MOD, 'parms', {'Ea', 0.6});
    MOD = add_to_ee_model(MOD, 'parms', {'a0', 0.25e-9});
    MOD = add_to_ee_model(MOD, 'parms', {'T_ini', 273 + 25});
    MOD = add_to_ee_model(MOD, 'parms', {'F_min', 1.4e9});
    MOD = add_to_ee_model(MOD, 'parms', {'gap_ini', 2e-10});
    MOD = add_to_ee_model(MOD, 'parms', {'gap_min', 2e-10});
    MOD = add_to_ee_model(MOD, 'parms', {'gap_max', 17e-10});
    MOD = add_to_ee_model(MOD, 'parms', {'Rth', 2.1e3});
    MOD = add_to_ee_model(MOD, 'parms', {'tox', 12e-9});
    MOD = add_to_ee_model(MOD, 'parms', {'maxslope', 1e15});

    MOD = add_to_ee_model (MOD, 'fe', @fe);
    MOD = add_to_ee_model (MOD, 'qe', @qe);
    MOD = add_to_ee_model (MOD, 'fi', @fi);
    MOD = add_to_ee_model (MOD, 'qi', @qi);

    MOD = finish_ee_model(MOD);

    MOD.implicit_equation_names = {'eqn_itb', 'eqn_Gap'}; %TODO: a hack, because ee_wrapper doesn't support zero explicit outputs

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

    kb = 1.3806226e-23; % Boltzmann's Constant (joules/kelvin)
    q = 1.6021918e-19; % Electron Charge (C)

	T_cur = T_ini + abs(vtb * itb * Rth);

    gamma_ini = gamma0;
	if (vtb < 0)
		gamma_ini = 16;
	end	
	gamma = gamma_ini - Beta * (Gap)^3;
	if ((gamma * abs( vtb )/ tox) < F_min)
		gamma = 0;
	end
		
	Gap_ddt = - 1e9 * Vel0 * exp(- q * Ea / kb / T_cur) * mysinh(gamma * a0 / tox * q * vtb / kb / T_cur, maxslope);

	if (Gap<1e9*gap_min)
		Gap = 1e9*gap_min + 1e-6*(Gap - 1e9*gap_min); %TODO: gmin hack
	elseif (Gap>gap_max)
		Gap = 1e9*gap_max + 1e-6*(Gap - 1e9*gap_max); %TODO: gmin hack
	end

	Itb = I0 * safeexp(-1e-9*Gap/g0, maxslope) * mysinh(vtb/V0, maxslope);

    Itb = Itb + 1e-12 * vtb; %TODO: gmin hack

    if 1 == strcmp(eori,'e') % e
        if 1 == strcmp(forq, 'f') % f
            out = [];
        else % q
            out = [];
        end % forq
    else % i
        if 1 == strcmp(forq, 'f') % f
			out(1,1) = itb - Itb;
			out(2,1) = Gap_ddt;
        else % q
            out(1,1) = 0;
            out(2,1) = -Gap;
        end
    end
end

%%%%%%%%%%%%%  Internal Functions  %%%%%%%%%%%%%%%%%

function y = mysinh(x, maxslope)
    y = (safeexp(x, maxslope) - safeexp(-x, maxslope))/2;
end % mysinh
