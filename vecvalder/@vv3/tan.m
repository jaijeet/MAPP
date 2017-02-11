function h = tan(u)
  %VECVALDER/TAN overloads tangent of a vecvalder object argument
  n = size(u(1).der,2);
  h = vecvalder(tan(val2mat(u)), repmat((sec(val2mat(u))).^2,[1 n]).*der2mat(u));
end
