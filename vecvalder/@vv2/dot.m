function h = dot(u,v)
%function h = dot(u,v)
%VECVALDER/DOT (vv2 version) overloads the vector dot product operation when
%at least one argument is of vecvalder type.
% 
% NO SIZE CHECKS (for efficiency): we rely on numeric .' and * to catch size
% inconsistencies.
%
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16
  if ~isobject(u) %u is numeric, v is vecvalder
    % f(v(x)) = u.' * v(x) => df/dx = u.' * dv_dx
    h = v; % for efficiency
    h.valder = u.'*v.valder; 
  elseif ~isobject(v) %v is numeric, u is a vector/scalar vecvalder
    % f(u(x)) = u(x).' * v  = v.' * u(x) => df/dx = v.' * du_dx
    h = u; % for efficiency
    h.valder = v.'*u.valder;
  else % u, v are both vecvalders
    % f(u(x),v(x)) = u(x).' * v(x) => df/dx = u(x).'*dv_dx + du_dx.' * v
    h = v;
    h.valder = u.valder(:,1).' * v.valder;
    h.valder(:,2:end) = h.valder(:,2:end) + v.valder(:,1).' * u.valder(:,2:end);
  end
end
