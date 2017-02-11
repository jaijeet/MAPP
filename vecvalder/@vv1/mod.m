function out = mod(a,b)
  %VECVALDER/mod mod(a,b) with at least one vecvalder object argument.
  %mod(a,b) is not differentiable, but the derivatives here should be correct for a, b where mod(a,b) _is_ differentiable
  if ~isa(a,'vecvalder') %a is a scalar
     aa = a;
  else % a is a vecvalder
     aa = val2mat(a);
  end
  if ~isa(b,'vecvalder') %b is a scalar
     bb = b;
  else % b is a vecvalder
     bb = val2mat(b);
     szb = size(der2mat(b));
  end

  if isa(a,'vecvalder') %a is a vecvalder
  	out = vecvalder(mod(aa,bb), der2mat(a));
  elseif isa(b,'vecvalder')
        szb = size(der2mat(b));
  	out = vecvalder(mod(aa,bb), sparse(zeros(szb)));
  end
end
