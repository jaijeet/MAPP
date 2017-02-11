function h = mpower(u,v)
  %VECVALDER/MPOWER (vv2 version) overloads mpower ^ with at least one 
  % vecvalder object argument. 
  % mpower is Z = X^y, where X is a square matrix and y is scalar
  % (non-scalar y is an error).
  % In the overloaded version, X can ONLY be a SCALAR vecvalder (with y 
  % a scalar vecvalder), because matrix vecvalder is not supported.
  % 
  % NO SIZE CHECKS (for efficiency): we rely on numeric mpower to catch size
  % inconsistencies.
  %
  % TODO: NEEDS THOROUGH TESTING
  %
  % Author: JR, 2014/06/16

  % NOTE: BOTH u and v MUST be scalar here because otherwise mpower does
  % not make any sense. If you think it does, you are thinking of power,
  % not mpower. The code below should not work if either is a vector.
  if ~isobject(u) % u is numeric, hence v must be a (scalar) vecvalder
    % f(v) = u^v = exp(v*log(u)) => df/dx = f'(v) * dv/dx => 
    % df/dx = log(u)*exp(v*log(u)) * dv/dx = log(u) * u^v * dv/dx
    h = v; % avoid copy constructor
    tmp = u^v.valder(:,1);
    h.valder = [tmp, log(u)*tmp*v.valder(:,2:end)];
  elseif ~isobject(v) % v is numeric, therefore u must be a vecvalder
    % f(u) = u^v = exp(v*log(u)) => df/dx = f'(u) * du/dx => 
    % df/dx = v/u*exp(v*log(u)) * du/dx = v*u^(v-1)*du/dx
    h = u; % avoid copy constructor
    tmp = u.valder(:,1)^(v-1);
    h.valder = [u.valder(:,1)*tmp, v*tmp*u.valder(:,2:end)];
  else % both u and v are vecvalders
    % f(x) = f(u(x), v(x)) = u(x)^v(x) 
    % => df/dx = delf_delu*du/dx + delf_delv*dv/dx
	% => delf_delu = v*u^(v-1); 
	% f(u,v) = u^v => log(f(u,v)) = v*log(u) => f(u,v) = e^{v*log(u)}
	% => delf_delv = log(u)*e^{v*log(u)} = log(u)*f(u,v)
	h = u; % avoid copy constructor
    tmp2 = u.valder(:,1)^(v.valder(:,1)-1); % h
    tmp1 = tmp2*u.valder(:,1); % h
    h.valder = [tmp1, log(u.valder(:,1))*tmp1*v.valder(:,2:end)];
    h.valder(:,2:end) = h.valder(:,2:end) + ...
                        v.valder(:,1)*tmp2*u.valder(:,2:end);
  end
end
