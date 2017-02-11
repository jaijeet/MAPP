function h = asin(u)
%function h = asin(u)
%VECVALDER/ASIN (vv2 version) overloads asin(u) when the argument is of
%vecvalder type.
% 
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16
    
    % h = asin(u) => dh_dx = du_dx/sqrt(1-u^2)
    h = u; % for efficiency
    % 
    h.valder = [asin(u.valder(:,1)), diag(1./sqrt(1-u.valder(:,1).^2))*u.valder(:,2:end)];
end
