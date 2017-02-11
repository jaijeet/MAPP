function h = minus(u,v)
  %VECVALDER/MINUS overloads subtraction - with at least one vecvalder object argument
  if ~isa(u,'vecvalder') %u is a scalar
     h = vecvalder(u-val2mat(v), -der2mat(v));
  elseif ~isa(v,'vecvalder') %v is a scalar
     h = vecvalder(val2mat(u)-v, der2mat(u));
   else
     h = vecvalder(val2mat(u)-val2mat(v), der2mat(u)-der2mat(v));
   end
end
