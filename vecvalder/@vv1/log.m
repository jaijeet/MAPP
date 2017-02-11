function h = log(u)
  %VECVALDER/LOG overloads natural logarithm of a vecvalder object argument
  n = size(u(1).der,2);
  h = vecvalder(log(val2mat(u)), repmat(1./val2mat(u),[1 n]).*der2mat(u));
end
