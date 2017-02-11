function h = mrdivide(u,v)
%function h = mrdivide(u,v)
%VECVALDER/MRDIVIDE (vv2 version) overloads / (matrix right divide) when
%one or more arguments is a vecvalder. For numeric arguments, this is 
%roughly the same as u*inv(v)
%In the overloaded version, this is implemented as u/v. v must be scalar 
%(numeric or vecvalder); u can be of vector numeric or vecvalder type.
% 
% NO SIZE CHECKS (for efficiency): we rely on numeric mrdivide to catch size
% inconsistencies.
%
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16
  if ~isobject(u) %u is a numeric vector, v is a (scalar) vecvalder
    % f(v(x)) = u/v(x) => df/dx = -u/v^2(x) * dv_dx
    h = v; % for efficiency
    tmp = u/v.valder(:,1);
    h.valder = [tmp, -tmp/v.valder(:,1)*v.valder(:,2:end)];
  elseif ~isobject(v) %v is numeric (scalar), u is a vector vecvalder
    % f(u(x)) = u(x)/v => df/dx = du_dx/v
    h = u; % for efficiency
    h.valder = u.valder/v;
  else % u, v are both vecvalders
    % f(u(x),v(x)) = u(x)/v(x) => df/dx = du_dx/v(x) - u(x)/v^2(x)*dv_dx
    h = v;
    tmp = u.valder(:,1)/v.valder(:,1);
    h.valder = [tmp, -tmp/v.valder(:,1)*v.valder(:,2:end)];
    h.valder(:,2:end) = h.valder(:,2:end) + u.valder(:,2:end)/v.valder(:,1);
  end
end
