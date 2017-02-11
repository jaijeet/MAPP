function display (obj)
  %a = val2mat(obj);
  val = full(val2mat(obj));
  %b = der2mat(obj);
  der = full(der2mat(obj));
  fprintf(2,'vecvalder with %d entries depending on %d indep. vars.\n', ...
  	size(val,1), size(der,2));
  val
  der
