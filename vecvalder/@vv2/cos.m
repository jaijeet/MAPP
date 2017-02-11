function h = cos(u)
%function h = cos(u)
%VECVALDER/COS (vv2 version) overloads cos(u) when the argument is of
%vecvalder type.
% 
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16
    
    % h = cos(u) => dh_dx = -sin(u)*du_dx
    h = u; % for efficiency
    % 
    h.valder = [cos(u.valder(:,1)), -diag(sin(u.valder(:,1)))*u.valder(:,2:end)];
end
