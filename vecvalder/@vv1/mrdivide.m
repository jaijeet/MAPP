function h = mrdivide(u,v)
  %VECVALDER/MRDIVIDE overloads division / with at least one vecvalder object argument
  if ~isa(u,'vecvalder') %u is a vector of scalars
    n = size(v(1).der,2);
    if (size(u,1)==1)
      h = vecvalder(u/val2mat(v), (-u.*der2mat(v))./repmat((val2mat(v)).^2,[1 n]));
    else
      h = vecvalder(u./val2mat(v), (-repmat(u,[1 n]).*der2mat(v))./repmat((val2mat(v)).^2,[1 n]));
    end
  elseif ~isa(v,'vecvalder') %v is a vector of scalars
    n = size(u(1).der,2);
    if (size(v,1)==1)
     h = vecvalder(val2mat(u)/v, der2mat(u)/v);
    else
      h = vecvalder(val2mat(u)./v, der2mat(u)./repmat(v,[1 n]));
    end
  else
    n = size(u(1).der,2);
    h = vecvalder(val2mat(u)./val2mat(v), (der2mat(u).*repmat(val2mat(v),[1 n])-repmat(val2mat(u), [1 n]).*der2mat(v))./repmat((val2mat(v)).^2,[1 n]));
  end
end
