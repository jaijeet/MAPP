function h = atan(u)
  %VECVALDER/ATAN overloads arctangent of a vecvalder object argument
  n = size(u(1).der,2);
  h = vecvalder(atan(val2mat(u)), der2mat(u)./repmat(1+val2mat(u).^2,[1 n]));
end
