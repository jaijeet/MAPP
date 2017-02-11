function h = sqrt(u)
%function h = sqrt(u)
%VECVALDER/SQRT (vv2 version) overloads sqrt(u) when the argument is of
%vecvalder type.
% 
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16
    
    % h = sqrt(u) => dh_dx = 1/(2*sqrt(u))*du_dx
    h = u; % for efficiency
    % 
    tmp = sqrt(u.valder(:,1));
    h.valder = [tmp, diag(1./(2*tmp))*u.valder(:,2:end)];
end
