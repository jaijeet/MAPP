function s = get (obj, f)
  n1 = size(obj(1).der,2)
  n2 = size(obj,1)
  %s.der = zeros(n1,n2);
  val = {obj.val};
  der = {obj.der};
  if (nargin == 1)
    s.val = zeros(n2,1);
    s.val(:) = cell2mat(val);
    s.der = sparse(n1,n2);
    s.der(:) = cell2mat(der);
    s.der = s.der.';
  elseif (nargin == 2)
    if (ischar (f))
      switch (f)
        case 'val'
    	  s = zeros(n2,1);
          s(:) = cell2mat(val);
        case 'der'
    	  s = sparse(n1,n2);
          s(:) = cell2mat(der);
          s(:) = cell2mat(der);
        otherwise
          error ('get: invalid property %s', f);
      end
    else
      error ('get: expecting the property to be a string');
    end
  else
    print_usage ();
  end
end
