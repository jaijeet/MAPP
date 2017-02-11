function h = sign2(u)
  %VECVALDER/SIGN2 overloads sign2 of a vecvalder object argument
  %sign2 is non-differentiable at 0; this routine returns a zero derivative
  %at 0.
  n = size(u(1).der,2); 
  h = vecvalder(sign2(val2mat(u)), repmat(0*val2mat(u),[1 n]));
end
