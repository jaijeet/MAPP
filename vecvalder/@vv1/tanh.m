function h = tanh(u)
  %VECVALDER/TANH overloads tangent of a vecvalder object argument
  n = size(u(1).der,2);
  h = vecvalder(tanh(val2mat(u)), repmat((sech(val2mat(u))).^2,[1 n]).*der2mat(u));
end
