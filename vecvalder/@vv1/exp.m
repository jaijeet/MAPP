function h = exp(u)
  %VECVALDER/EXP overloads exp of a vecalder object argument
  n = size(u(1).der,2);
  h = vecvalder(exp(val2mat(u)), repmat(exp(val2mat(u)),[1 n]).*der2mat(u));
end
