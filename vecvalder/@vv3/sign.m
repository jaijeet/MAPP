function h = sign(u)
  %VECVALDER/SIGN overloads sign of a vecvalder object argument
  %sign is non-differentiable at 0; this routine returns a zero derivative
  %at 0.
  n = size(u(1).der,2); 
  h = vecvalder(sign(val2mat(u)), repmat(0*val2mat(u),[1 n]));
end
