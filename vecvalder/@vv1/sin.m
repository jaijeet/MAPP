function h = sin(u)
  %VECVALDER/SIN overloads sine with a vecvalder object argument
  n = size(u(1).der,2);
  h = vecvalder(sin(val2mat(u)), repmat(cos(val2mat(u)),[1 n]).*der2mat(u));
end
