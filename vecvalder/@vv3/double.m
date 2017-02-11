function vec = double(obj)
  %VECVALDER/DOUBLE Convert vecvalder object to vector of doubles.
  vec = [val2mat(obj),der2mat(obj)];
end
