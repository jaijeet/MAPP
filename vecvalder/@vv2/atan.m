function h = atan(u)
%function h = atan(u)
%VECVALDER/ATAN (vv2 version) overloads atan(u) when the argument is of
%vecvalder type.
% 
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16
    
    % h = atan(u) => dh_dx = du_dx/(1+u^2)
    h = u; % for efficiency
    % 
    h.valder = [atan(u.valder(:,1)), diag(1./(1+u.valder(:,1).^2))*u.valder(:,2:end)];
end
