function h = rdivide(u,v)
%function h = rdivide(u,v)
%VECVALDER/RDIVIDE (vv2 version) overloads ./ (element by element division) when
%one or more arguments is a vecvalder. Both arguments must be of the same size
%(and at least one should be vecvalder for this routine to be called); either
%may be scalar.
% 
% NO SIZE CHECKS (for efficiency): we rely on numeric rdivide to catch size
% inconsistencies.
%
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16
  if ~isobject(u) %u is a numeric vector, v is a (scalar) vecvalder
    % f(v(x)) = u./v(x) => df/dx = -u/v^2(x) * dv_dx
    h = v; % for efficiency
    tmp = u./v.valder(:,1);
    h.valder = [tmp, -diag(tmp./v.valder(:,1))*v.valder(:,2:end)];
  elseif ~isobject(v) %v is numeric (scalar), u is a vector vecvalder
    % f(u(x)) = u(x)/v => df/dx = du_dx/v
    h = u; % for efficiency
    h.valder = diag(1./v)*u.valder;
  else % u, v are both vecvalders
    % f(u(x),v(x)) = u(x)/v(x) => df/dx = du_dx/v(x) - u(x)/v^2(x)*dv_dx
    h = v;
    tmp = u.valder(:,1)./v.valder(:,1);
    h.valder = [tmp, -diag(tmp./v.valder(:,1))*v.valder(:,2:end)];
    h.valder(:,2:end) = h.valder(:,2:end) + diag(1./v.valder(:,1))*u.valder(:,2:end);
  end
end
