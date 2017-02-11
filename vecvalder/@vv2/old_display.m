function display (obj)
  %a = val2mat(obj);
  val = full(val2mat(obj));
  %b = der2mat(obj);
  der = full(der2mat(obj));
  fprintf(2,'vecvalder with %d entries depending on %d indep. vars.\n', ...
  	size(val,1), size(der,2));
  val
  der
  if 0 == 1
	  for i=1:size(a,1)
	    if (size(a(:))==1)
	      fprintf('%s =', inputname(1));
	    else
	      fprintf('%s(%d,1) =', inputname(1),i);
	    end
	    fprintf('\n');
	    fprintf('\n');
	    fprintf('  vecvalder');
	    fprintf('\n');
	    fprintf('\n');
	    fprintf('  Properties:\n');
	    fprintf('    val:');
	    fprintf(' %g \n',full(a(i,1)));
	    fprintf('    der: ');
	    if (size(b,2)>1)
	      fprintf('[');
	    end
	    fprintf('%g',full(b(i,1)));
	    if (size(b,2)>1)
	      for k=2:size(b,2)
		fprintf(' %g',full(b(i,k)));
	      end
	      fprintf(']');
	    end
	    fprintf('\n');
	    fprintf('\n');
	  end
  end
end
