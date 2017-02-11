function h = tanh(u)
%function h = tanh(u)
%VECVALDER/TANH (vv2 version) overloads tanh(u) when the argument is of
%vecvalder type.
% 
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16
    
    % h = tanh(u) => dh_dx = (1-tanh^2(u))*du_dx = sech^2(u)*du_dx
    h = u; % for efficiency
    % 
    h.valder = [tanh(u.valder(:,1)), diag(sech(u.valder(:,1)).^2)*u.valder(:,2:end)];
end
