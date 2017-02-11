function h = times(u,v)
%function h = times(u,v)
%VECVALDER/TIMES (vv2 version) overloads .* (element by element
%multiplication) when one or more arguments is a vecvalder. Both arguments
%must be of the same size (and at least one should be vecvalder for this
%routine to be called); either may be scalar.
% 
% NO SIZE CHECKS (for efficiency): we rely on numeric times to catch size
% inconsistencies.
%
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16
  if ~isobject(u) %u is a numeric vector, v is a (scalar) vecvalder
    % f(v(x)) = u*v(x) => df/dx = u * dv_dx
    h = v; % for efficiency
    h.valder = diag(u)*v.valder;
  elseif ~isobject(v) %v is numeric (scalar), u is a vector vecvalder
    % f(u(x)) = u(x)*v => df/dx = du_dx*v
    h = u; % for efficiency
    h.valder = diag(v)*u.valder;
  else % u, v are both vecvalders
    % f(u(x),v(x)) = u(x)*v(x) => df/dx = du_dx*v(x) + u(x)*dv_dx
    h = v;
    if 1 == size(v.valder,1)
        h.valder = u.valder(:,1)*v.valder;
    else
        h.valder = diag(u.valder(:,1))*v.valder;
    end

    if 1 == size(u.valder,1)
        h.valder(:,2:end) = h.valder(:,2:end) + v.valder(:,1)*u.valder(:,2:end);
    else
        h.valder(:,2:end) = h.valder(:,2:end) + ...
                                diag(v.valder(:,1))*u.valder(:,2:end);
    end
  end
end
