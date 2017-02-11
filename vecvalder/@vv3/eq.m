function out = eq(a,b)
  %VECVALDER/eq a == b with at least one vecvalder object argument. Returns vector of logicals.
  if ~isa(a,'vecvalder') %a is a scalar
     aa = a;
     aisvv = 0;
  else % a is a vecvalder
     aa = val2mat(a);
     aisvv = 1;
  end
  if ~isa(b,'vecvalder') %b is a scalar
     bb = b;
     bisvv = 0;
  else % a is a vecvalder
     bb = val2mat(b);
     bisvv = 1;
  end

  out = aa == bb; 
  if 1 == aisvv && 1 == bisvv
  	out = out & prod(single(full(der2mat(a))==full(der2mat(b))),2);
  end
end
