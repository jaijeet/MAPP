function h = sin(u)
%function h = sin(u)
%VECVALDER/SIN (vv2 version) overloads sin(u) when the argument is of
%vecvalder type.
% 
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16
    
    % h = sin(u) => dh_dx = cos(u)*du_dx
    h = u; % for efficiency
    % 
    h.valder = [sin(u.valder(:,1)), diag(cos(u.valder(:,1)))*u.valder(:,2:end)];
end
