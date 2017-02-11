function h = uplus(u)
  %VECVALDER/UPLUS overloads unary + with a vecvalder object argument
  h = vecvalder(val2mat(u), der2mat(u));
end
