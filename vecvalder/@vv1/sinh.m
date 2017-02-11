function h = sinh(u)
  %VECVALDER/SINH overloads hyperbolic sine of a vecvalder object argument
  n = size(u(1).der,2);
  h = vecvalder(sinh(val2mat(u)), repmat((cosh(val2mat(u))),[1 n]).*der2mat(u));
end
