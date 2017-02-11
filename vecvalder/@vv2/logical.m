function h = logical(u)
%function h = logical(u)
%VECVALDER/LOGICAL (vv2 version) converts vecvalders to a vector of logicals.
%
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/17
  h = logical(u.valder(:,1));
end
