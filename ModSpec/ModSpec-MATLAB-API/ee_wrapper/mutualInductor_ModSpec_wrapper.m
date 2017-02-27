function MOD = mutualInductor_ModSpec_wrapper()
%function MOD = mutualInductor_ModSpec_wrapper()
%
%This is a 4-terminal model for a mutual inductor, with nodes pL1, nL1, 
%pL2, nL2. The node pairs (pL1, nL1) and (pL2, nL2) are not connected within
%the model.
%
%The device's equations are:
%
% V_L1 = d/dt (L1 I_L1) + d/dt (M * I_L2)
% V_L2 = d/dt (L2 I_L2) + d/dt (M * I_L1)
%
% M = mutual inductance = K*sqrt(L1*L2); k is the coupling parameter, which
%     should be between -1 and +1. At k = \pm 1, the mutual inductor becomes a
%     perfect transformer.
%
%Examples
%--------
%
%type/edit/run test_mutualInductor
%

%Author: JR, 2017/02/25
% 
%
	MOD = ee_model();

    MOD = add_to_ee_model(MOD, 'external_nodes', {'pL1', 'nL1', 'pL2', 'nL2'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'vpL1nL2', 'vpL2nL2', 'inL1nL2'});
    MOD = add_to_ee_model(MOD, 'parms', {'L1', 1e-9, 'L2', 1e-9, 'K', 0.0});

    MOD = add_to_ee_model(MOD, 'q', @q);
    MOD = add_to_ee_model(MOD, 'f', @f);

	MOD = finish_ee_model(MOD);
end

function out = q(S) % out = [vpL1nL2, vpL2nL2]
    v2struct(S); 
    M = K*sqrt(L1*L2);
    out(1,1) = L1*ipL1nL2 + M*ipL2nL2;
    out(2,1) = L2*ipL2nL2 + M*ipL1nL2;
    out(3,1) = 0;
end

function out = f(S) % out = [vpL1nL2, vpL2nL2]
    v2struct(S); 
    out(1,1) = vnL1nL2;
    out(2,1) = 0;
    out(3,1) = -ipL1nL2;
end
