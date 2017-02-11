function h = cos(u)
  %VECVALDER/COS overloads cosine of a vecvalder object argument
  n = size(u(1).der,2); 
  h = vecvalder(cos(val2mat(u)), repmat(-sin(val2mat(u)),[1 n]).*der2mat(u));
end
