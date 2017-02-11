function h = mtimes(u,v)
%function h = mtimes(u,v)
%VECVALDER/MTIMES (vv2 version) overloads * (matrix multiply) when
%one or more arguments is of vecvalder type.
%In the overloaded version, the following cases are supported:
%- u a numeric matrix, v a vector vecvalder
%- u a vector vecvalder, v scalar (numeric or vecvalder)
%- u a scalar vecvalder, v a vector vecvalder
% 
% NO SIZE CHECKS (for efficiency): we rely on numeric mtimes to catch size
% inconsistencies.
%
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16
  if ~isobject(u) %u is numeric, v is vecvalder
    % f(v(x)) = u*v(x) => df/dx = u * dv_dx
    h = v; % for efficiency
    h.valder = u*v.valder; % matrix multiplication on per-column basis
        % case 1: u is a numeric vector, v a vecvalder scalar: works
        % case 2: u is a numeric scalar, v a vecvalder vector: works
        % case 3: u is a numeric matrix, v a vecvalder vector: works
  elseif ~isobject(v) %v is numeric, u is a vector/scalar vecvalder
    % f(u(x)) = u(x)*v => df/dx = du_dx*v
    h = u; % for efficiency
    h.valder = v*u.valder;
        % case 1: u is a scalar vecvalder, v is a numeric vector/matrix
        %           v*u.valder works here (work it out)
        % case 2: u is a vector vecvalder, v is a numeric scalar
        %           v*u.valder works here too
  else % u, v are both vecvalders
    % f(u(x),v(x)) = u(x)*v(x) => df/dx = u*dv_dx + du_dx*v
    h = v;
    h.valder = u.valder(:,1)*v.valder;
    h.valder(:,2:end) = h.valder(:,2:end) + v.valder(:,1)*u.valder(:,2:end);
    % combination of the above two cases
  end
end
