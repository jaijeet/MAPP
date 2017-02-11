function h = asinh(u)
%function h = asinh(u)
%VECVALDER/ASINH (vv2 version) overloads asinh(u) when the argument is of
%vecvalder type.
% 
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16
    
    % h = asinh(u) => dh_dx = 1/sqrt(1+u^2)*du_dx
    h = u; % for efficiency
    % 
    h.valder = [asinh(u.valder(:,1)), diag(1./sqrt(1+u.valder(:,1).^2))*u.valder(:,2:end)];
end
