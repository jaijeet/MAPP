function h = uminus(u)
  %VECVALDER/UMINUS overloads negation - with a vecvalder object argument
  h = vecvalder(-val2mat(u), -der2mat(u));
end
