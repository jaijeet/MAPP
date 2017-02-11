function MOD = RLC_ModSpec_wrapper()
%function MOD = RLC_ModSpec_wrapper()
% This function returns a ModSpec model for a "device" that describes an RLC
% tank: parallel connection of a resistor, an inductor and a capacitor.
%
%Return values:
% - MOD:    a ModSpec object for the RLC tank. help ModSpec for more
%           information about ModSpec.
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'p', 'n'} positive and negative terminals of the RLC tank.
%
% - parameters and their default values:
%   - 'R'  (internal resistor): 1e3
%   - 'L'  (internal inductance): 1e-9
%   - 'C'  (internal capacitance): 1e-6
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO names:                        vpn, ipn
% - explicit output name(s):         ipn
% - other IO name(s) (vecX):         vpn
% - implicit unknown name(s) (vecY): iL
% - input names (vecU):              {}
%
% 2. equations:
% - explicit equation:
%   ipn = vpn/R + d/dt C*vpn + iL;
% - implicit equation:
%   0 = vpn - d/dt L*iL;
%
%Examples
%--------
% % adding an RLC tank device to an existing circuit netlist structure
% %                         model                name      nodes  
% %                           v                   v          v   
% ckt = add_element(ckt, RLC_ModSpec_wrapper(), 'RLC1', {'n1', 'n2'},...
%                       {{'R', 1e9}, {'C', 1e-9}});
% %                                   ^     
% %                                parameters
%
%See also
%--------
% 
% add_element, circuitdata[TODO], ModSpec, supported_ModSpec_devices[TODO],
% DAEAPI, DAE_concepts

	MOD = ee_model();

    MOD = add_to_ee_model(MOD, 'external_nodes', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});
    MOD = add_to_ee_model(MOD, 'internal_unks', {'iL'});
    MOD = add_to_ee_model(MOD, 'parms', {'R', 1e3, 'C', 1e-6, 'L', 1e-9});
    
    MOD = add_to_ee_model(MOD, 'fe', @fe);
    MOD = add_to_ee_model(MOD, 'qe', @qe);
    MOD = add_to_ee_model(MOD, 'fi', @fi);
    MOD = add_to_ee_model(MOD, 'qi', @qi);

	MOD = finish_ee_model(MOD);
end

function out = fe(S)
    v2struct(S); % S.vpn, S.iL, S.R, S.C, S.L
    out = vpn/R + iL;
end

function out = qe(S)
    v2struct(S); % S.vpn, S.iL, S.R, S.C, S.L
    out = C*vpn;
end

function out = fi(S)
    v2struct(S);
    out = vpn;
end

function out = qi(S)
    v2struct(S);
    out = -L*iL;
end
