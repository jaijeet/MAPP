function h = le(u,v)
%function h = le(u,v)
%VECVALDER/LE (vv2 version) tests less than or equal to (<=) if at least
%one of u, v is a vecvalder, returning a vector of logicals. ONLY VALUES ARE
%COMPARED FOR EQUALITY; DERIVATIVES ARE IGNORED.
%
% NO SIZE CHECKS (for efficiency): we rely on MATLAB's built-in <= for 
% numeric arguments to catch size inconsistencies.
% 
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/17
  if ~isobject(u) % u is not a vecvalder, v is
    h = (u <= v.valder(:,1));
  elseif ~isobject(v) % v is not a vecvalder, u is
    h = (u.valder(:,1) <= v);
  else % both are vecvalders
    h = (u.valder(:,1) <= v.valder(:,1)); 
  end
end
