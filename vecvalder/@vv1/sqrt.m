function h = sqrt(u)
  %VECVALDER/SQRT overloads square root of a vecvalder object argument
  n = size(u(1).der,2);
  h = vecvalder(sqrt(val2mat(u)), der2mat(u)./repmat(2*sqrt(val2mat(u)),[1 n]));
end
