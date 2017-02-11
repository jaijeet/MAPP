   % VECVALDER class implementing Automatic Differentiation by operator overloading.
   % Computes first order derivative or multivariable gradient vectors by
   % starting with a known simple valder such as x=vecvalder(3,1) and 
   % propagating it through elementary functions and operators. 
function obj = vecvalder (a,b)
  if (nargin == 0)
    obj.val = [];
    obj.der = [];
    obj = class (obj, 'vecvalder');
  elseif (nargin == 1)
    if (size(a,2)>1)
      disp(' Error: the argument can only be a vertical vector!');
      return;
    end
    
    obj = struct('val',num2cell(a),'der',num2cell(sparse(zeros(size(a)))));
    %obj = struct('val',a,'der',sparse(zeros(size(a))));
    obj = class(obj,'vecvalder');    
  elseif (nargin == 2)
    if ischar(b)
        % I'm assuming that strcmp(b, 'indep')
        b = speye(size(a,1));
    end

    if (size(a,1)~=size(b,1))
      disp(' Error: the two arguments must have the same number of rows!');
      return;
    end
    if (size(a,2)>1)
      disp(' Error: the first argument can only be a vertical vector!');
      return;
    end
    
    %3/2013 Juan's number to cell of a and b matrix
    %note that this can be improved with part of the
    %actual code used in num2cell matlab function
    a_cell = cell(size(a));
    for i=1:length(a)
        a_cell{i} = a(i);
    end   
    
    length_b=size(b,1);
    b_cell = cell(length_b,1);
    for i=1:length_b
        b_cell{i} = b(i,:);
    end   
    obj = struct('val',a_cell,'der',b_cell); 
    %end of Juan's number to cell of a and b matrix
    
    %obj = struct('val',num2cell(a),'der',num2cell(b,2)); 
    %obj = struct('val',a,'der',b); 
    obj = class (obj, 'vecvalder');
  else
    print_usage ();
  end
end

