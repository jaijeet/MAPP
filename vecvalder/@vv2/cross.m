function h = cross(u,v)
%function h = cross(u,v)
%VECVALDER/CROSS (vv2 version) overloads the cross-product operation between
%two 3-vectors when at least one is of vecvalder type.
%both u and v must be of size 3.
%
% NO SIZE CHECKS (for efficiency): we rely on MATLAB's built-in cross() for 
% numeric arguments to catch size inconsistencies.
% 
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/17

  % if y = cross(u, v), then dy/dx = cross(du/dx, v) + cross(u, dv/dx)
  % - proof straightforward, if painful, from first principles. See Wikipedia.
  if ~isobject(u) %u is numeric, v is vecvalder
    % dy/dx = cross(u, dv/dx)
    h = v; % for efficiency
    h.valder = cross(u*ones(1,size(v.valder,2)), v.valder);
  elseif ~isobject(v) %v is numeric, u is a vector/scalar vecvalder
    % dy/dx = cross(du/dx, v)
    h = u; % for efficiency
    h.valder = cross(u.valder, v*ones(1,size(u.valder,2)));
  else % u, v are both vecvalders
    % dy/dx = cross(u, dv/dx) + cross(du/dx, v)
    h = v;
    h.valder = cross(u.valder(:,1)*ones(1,size(v.valder,2)), v.valder);
    h.valder(:,2:end) = h.valder(:,2:end) + cross(u.valder(:,2:end), ...
                                    v.valder(:,1)*ones(1,size(u.valder,2)-1));
  end
end

