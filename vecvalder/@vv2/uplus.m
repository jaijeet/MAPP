function h = uplus(u)
%function h = uplus(u)
%VECVALDER/UPLUS (vv2 version) overloads + - one arg version
%Author: JR, 2014/06/16
  h = u; % avoid calling constructor, for efficiency
  h.valder = u.valder;
end
