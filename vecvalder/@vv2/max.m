function h = max(u,v)
%function h = max(u,v)
%VECVALDER/MAX (vv2 version) overloads MAX if at least one argument is a
%vecvalder.
%
%NO SIZE CHECKS (for efficiency): relying on numeric max to catch size errors.
%
%Note: max(u,v) = 0.5*(abs(u-v) + v + u), but for efficiency, this
%implementation does not call abs().
%
%Author: JR, 2014/06/18

  %h(u,v) = 0.5*(abs(u-v) + v + u) =>
  % dh_dx = dh_du*du_dx + dh_dv*dv_dx;
  % dh_du = 0.5(dabs_darg(u-v) + 1) = 0.5*(sign(u-v) + 1);
  % dh_dv = 0.5(-dabs_darg(u-v) + 1) = 0.5*(-sign(u-v) + 1)
  if ~isobject(u) %u is a scalar
    h = v; % avoid using constructor
    h.valder = [max(u,v.valder(:,1)), ...
                0.5*diag(-sign(u-v.valder(:,1))+1)*v.valder(:,2:end)];
  elseif ~isobject(v) %v is a scalar
    h = u; % avoid using constructor
    h.valder = [max(u.valder(:,1),v), ...
                0.5*diag(sign(u.valder(:,1)-v)+1)*u.valder(:,2:end)];
  else
    if 1 == size(u.valder,1)
        u.valder = ones(size(v.valder,1),1)*u.valder;
    elseif 1 == size(v.valder,1)
        v.valder = ones(size(u.valder,1),1)*v.valder;
    end
    h = u; % avoid using constructor
    h.valder = [max(u.valder(:,1),v.valder(:,1)), ...
               0.5*diag(sign(u.valder(:,1)-v.valder(:,1))+1)*u.valder(:,2:end)];
    h.valder(:,2:end) = h.valder(:,2:end) + ...
              0.5*diag(-sign(u.valder(:,1)-v.valder(:,1))+1)*v.valder(:,2:end);
  end
end
