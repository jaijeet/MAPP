function h = sign(u)
%function h = sign(u)
%VECVALDER/SIGN (vv2 version) overloads sign()
%sign is non-differentiable at 0; this routine assigns a zero derivative at 0
%Author: JR, 2014/06/18
  h = u; % for efficiency
  h.valder = [sign(u.valder(:,1)), 0*u.valder(:,2:end)];
end
