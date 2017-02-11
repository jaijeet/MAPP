function h = power(u,v)
%function h = power(u,v)
%VECVALDER/POWER (vv2 version) overloads power .^ with at least one 
%vecvalder object argument. 
%In the overloaded version, u and v need to be numeric or vecvalder vectors
%of the same size; either can be scalar.
% 
% NO SIZE CHECKS (for efficiency): we rely on numeric power to catch size
% inconsistencies.
%
% TODO: NEEDS THOROUGH TESTING
%
% Author: JR, 2014/06/16

  if ~isobject(u) % u is numeric, therefore v must be a vecvalder
    % f(v) = u^v = exp(v*log(u)) => df/dx = f'(v) * dv/dx => 
    % df/dx = log(u)*exp(v*log(u)) * dv/dx = log(u) * u^v * dv/dx
    h = v; % avoid copy constructor
    tmp = u.^v.valder(:,1);
    h.valder = [tmp, diag(log(u).*tmp)*v.valder(:,2:end)];
  elseif ~isobject(v) % v is numeric, therefore u must be a vecvalder
    % f(u) = u^v = exp(v*log(u)) => df/dx = f'(u) * du/dx => 
    % df/dx = v/u*exp(v*log(u)) * du/dx = v*u^(v-1)*du/dx
    h = u; % avoid copy constructor
    tmp = u.valder(:,1).^(v-1);
    h.valder = [u.valder(:,1).*tmp, diag(v.*tmp)*u.valder(:,2:end)];
  else % both u and v are vecvalders
    % f(x) = f(u(x), v(x)) = u(x)^v(x) 
    % => df/dx = delf_delu*du/dx + delf_delv*dv/dx
    h = u; % avoid copy constructor
    tmp2 = u.valder(:,1).^(v.valder(:,1)-1);
    tmp1 = u.valder(:,1).*tmp2;
    h.valder = [tmp1, diag(log(u.valder(:,1)).*tmp1)*v.valder(:,2:end)];
    h.valder(:,2:end) = h.valder(:,2:end) + ...
                        diag(v.valder(:,1).*tmp2)*u.valder(:,2:end);
  end
end
