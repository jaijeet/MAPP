function h = uminus(u)
%function h = uminus(u)
%VECVALDER/UMINUS (vv2 version) overloads negation - one arg version
%Author: JR, 2014/06/16
  h = u; % avoid calling constructor, for efficiency
  %h = vecvalder(-val2mat(u), -der2mat(u));
  h.valder = -u.valder;
end
