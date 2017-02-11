function h = min(u,v)
  %VECVALDER/MIN overloads MIN .* with at least one vecvalder object argument
  % min(u,v) = 0.5*(-abs(u-v) + v + u);

  h = 0.5*(-abs(u-v) + v + u);

  %{
  template for doing it from scratch
  if ~isa(u,'vecvalder') %u is a vector of scalars
    n = size(v(1).der,2);
    if (size(u,1)==1)
      h = vecvalder(u*val2mat(v), u*der2mat(v));
    else
      h = vecvalder(u.*val2mat(v), repmat(u,[1 n]).*der2mat(v));
    end
  elseif ~isa(v,'vecvalder') %v is a vector of scalars
    n = size(u(1).der,2);
    if (size(v,1)==1)
      h = vecvalder(v*val2mat(u), v*der2mat(u));
    else
      h = vecvalder(v.*val2mat(u), repmat(v,[1 n]).*der2mat(u));
    end
  else
    % deal with the case where one of the vecvalders is a scalar
    sz1 = size(val2mat(u), 1);
    sz2 = size(val2mat(v), 1);
    if 1 == sz1
    	u = ones(sz2,1) * u;
    elseif 1 == sz2
    	v = ones(sz1,1) * v;
    elseif sz1 ~= sz2 % both vecvalders of sz > 1, not = each other: eror
    	error('error in vecvalder::times: attempt to multiply 2 vecvalders of differing sizes');
	h = [];
    end
    % do the vecvalder multiplication
    n = size(u(1).der, 2);
    h = vecvalder(val2mat(u).*val2mat(v), der2mat(u).*repmat(val2mat(v),[1 n]) + repmat(val2mat(u),[1 n]).*der2mat(v));
  end
  %}
end
