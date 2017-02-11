function h = sinh(u)
%function h = sinh(u)
%VECVALDER/SINH (vv2 version) overloads sinh(u) when the argument is of
%vecvalder type.
% 
% TODO: NEEDS THOROUGH TESTING
%
% Author: Tianshi Wang, 2016/01/18
    
    % h = sinh(u) => dh_dx = cosh(u)*du_dx
    h = u; % for efficiency
    % 
    h.valder = [sinh(u.valder(:,1)), diag(cosh(u.valder(:,1)))*u.valder(:,2:end)];
end
