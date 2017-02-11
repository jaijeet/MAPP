function out = lt(a,b)
  %VECVALDER/lt a < b with at least one vecvalder object argument. Returns vector of logicals.
  if ~isa(a,'vecvalder') %a is a scalar
     aa = a;
  else % a is a vecvalder
     aa = val2mat(a);
  end
  if ~isa(b,'vecvalder') %b is a scalar
     bb = b;
  else % a is a vecvalder
     bb = val2mat(b);
  end

  out = aa < bb ;
end
