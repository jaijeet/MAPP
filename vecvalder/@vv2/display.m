function display(obj)
%function display(obj)
%VECVALDER/DISPLAY (vv2) overloads the display method for vecvalder objects.
%
%Author: JR, 2014/06/16
  if isempty(obj.valder)
    fprintf(2,'empty vecvalder (vv2) object.\n');
    valder = []
  else
    val = obj.valder(:,1);
    der = obj.valder(:,2:end);
    fprintf(2,'vecvalder (vv2) with %d entries depending on %d indep. vars.\n', ...
  	    size(val,1), size(der,2));
    val
    der
  end
end
