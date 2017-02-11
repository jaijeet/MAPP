function h = mpower(u,v)
  %VECVALDER/MPOWER overloads power ^ with at least one vecvalder object argument
  n = size(u(1).der,2);
  if ~isa(u,'vecvalder') %u is a scalar
    h = vecvalder(u^val2mat(v), u^val2mat(v).*log(u)*der2mat(v));
  elseif ~isa(v,'vecvalder') %v is a scalar
    h = vecvalder(val2mat(u).^v, repmat(v*val2mat(u).^(v-1),[1 n]).*der2mat(u));
  else
    h = exp(v*log(u)); %call overloaded log, * and exp
  end
end
