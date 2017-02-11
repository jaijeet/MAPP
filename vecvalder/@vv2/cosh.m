function h = cosh(u)
%function h = cosh(u)
%VECVALDER/COSH (vv2 version) overloads cosh(u) when the argument is of
%vecvalder type.
% 
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16
    
    % h = cosh(u) => dh_dx = sinh(u)*du_dx
    h = u; % for efficiency
    % 
    h.valder = [cosh(u.valder(:,1)), diag(sinh(u.valder(:,1)))*u.valder(:,2:end)];
end
