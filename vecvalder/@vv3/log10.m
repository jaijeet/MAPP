function h = log10(u)
  %VECVALDER/LOG10 overloads logarithm to the base 10 of a vecvalder object argument
  n = size(u(1).der,2);
  h = vecvalder(log10(val2mat(u)), repmat(1./val2mat(u)/log(10),[1 n]).*der2mat(u));
end
