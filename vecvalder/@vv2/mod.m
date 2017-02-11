function h = mod(u,v)
%function h = mod(u,v)
%VECVALDER/MOD (vv2 version) performs element-by-element AND (&) if one of u,
%v is a vecvalder, returning a vector of logicals. ONLY VALUES ARE COMPARED
%FOR EQUALITY; DERIVATIVES ARE IGNORED.
%
% FEW SIZE CHECKS (for efficiency): we rely mostly on MATLAB's built-in mod for 
% numeric arguments to catch size inconsistencies.
% 
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/17

  % if y = mod(u,v), then dy/dx = dmod_du*du_dx + dmod_dv*dv_dx
  % dmod_du(u, v) = 1 except at mod(u, v) = 0, where it does not exist
  % dmod_dv(u, v)  is more interesting. Try this:
  %         u=3; vs=(1:1000)/1000*5; plot(vs, mod(u, vs));
  % To derive the expression, note that mod(u,v) = u - floor(u/v)*v
  % => dmod_dv = +dfloor_dx(u/v)*u/v - floor(u/v)
  %            = 0 (a.e.) - floor(u/v)
  if ~isobject(u) % u is not a vecvalder, v is
    h = v; % for efficiency
    if 1 == length(u)
        u = u*ones(size(v.valder,1),1); % making them the same size
    end
    h.valder(:,1) = mod(u, v.valder(:,1));
    h.valder(:,2:end) = -diag(floor(u./v.valder(:,1)))*v.valder(:,2:end);
  elseif ~isobject(v) % v is not a vecvalder, u is
    if 1 == length(v)
        v = v*ones(size(u.valder,1),1); % making them the same size
    end
    h = u; % for efficiency
    h.valder(:,1) = mod(u.valder(:,1), v);
    h.valder(:,2:end) = u.valder(:,2:end);
  else % both are vecvalders
    if 1 == size(u.valder, 1)
        u.valder = ones(size(v.valder,1),1)*u.valder; % same size
    elseif 1 == size(v.valder,1)
        v.valder = ones(size(u.valder,1),1)*v.valder; % same size
    end
    h = u; % for efficiency
    h.valder(:,1) = mod(u.valder(:,1), v.valder(:,1));
    h.valder(:,2:end) = -diag(floor(u.valder(:,1)./v.valder(:,1)))*v.valder(:,2:end);
    h.valder(:,2:end) = h.valder(:,2:end) + u.valder(:,2:end);
  end
end
