function h = cosh(u)
  %VECVALDER/COSH overloads tangent of a vecvalder object argument
  n = size(u(1).der,2);
  h = vecvalder(cosh(val2mat(u)), repmat((sinh(val2mat(u))),[1 n]).*der2mat(u));
end
