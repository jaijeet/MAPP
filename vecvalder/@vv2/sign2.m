function h = sign2(u)
%function h = sign2(u)
%VECVALDER/SIGN2 (vv2 version) overloads sign2().  sign2 is like sign except
%that sign2(0)=1.
%Author: JR, 2014/06/18
  h = u; % for efficiency
  h.valder = [sign2(u.valder(:,1)), 0*u.valder(:,2:end)];
end
