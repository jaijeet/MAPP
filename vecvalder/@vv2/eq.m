function h = eq(u,v)
%function h = eq(u,v)
%VECVALDER/EQ (vv2 version) tests equality if at least one of u, v is a
%vecvalder, returning a vector of logicals. Values are compared for equality;
%if both u and v are vecvalders, the derivatives are also compared.
%
% NO SIZE CHECKS (for efficiency): we rely on MATLAB's built-in eq() for 
% numeric arguments to catch size inconsistencies.
% 
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/17
  if ~isobject(u) % u is not a vecvalder, v is
    h = (u == v.valder(:,1));
  elseif ~isobject(v) % v is not a vecvalder, u is
    h = (v == u.valder(:,1));
  else % both are vecvalders
    h = logical(prod((u.valder == v.valder)*1, 2)); % matrix comparison (value & derivatives)
  end
end
