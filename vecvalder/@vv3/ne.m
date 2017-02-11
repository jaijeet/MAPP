function out = ne(a,b)
  %VECVALDER/ne a ~= b with at least one arg a vecvalder. Returns vector of logicals.

  out = ~(a == b);
  %out = (val2mat(a) ~= val2mat(b)) | ...
  %sum(single((full(der2mat(a))~=full(der2mat(b)))),2);
end
