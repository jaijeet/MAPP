function h = abs(u)
%function h = abs(u)
%VECVALDER/ABS (vv2 version) overloads abs()
%abs is non-differentiable at zero; this routine assigns a zero derivative at 0
%Author: JR, 2014/06/18
  h = u; % for efficiency
  h.valder = [abs(u.valder(:,1)), diag(sign(u.valder(:,1)))*u.valder(:,2:end)];
end
