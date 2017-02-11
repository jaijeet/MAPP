function h = tan(u)
%function h = tan(u)
%VECVALDER/TAN (vv2 version) overloads tan(u) when the argument is of
%vecvalder type.
% 
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16
    
    % h = tan(u) => dh_dx = sec^2(u)*du_dx
    h = u; % for efficiency
    % 
    h.valder = [tan(u.valder(:,1)), diag(sec(u.valder(:,1)).^2)*u.valder(:,2:end)];
end
