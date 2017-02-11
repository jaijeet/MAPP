function h = asin(u)
  %VECVALDER/ASIN overloads arcsine of a vecvalder object argument
  n = size(u(1).der,2);
  h = vecvalder(asin(val2mat(u)), der2mat(u)./repmat(sqrt(1-val2mat(u).^2),[1 n]));
end
