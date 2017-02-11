function out = subsref(vvobj, S)
%function out = subsref(vvobj, S)
%VECVALDER/subsref overloads subsref for a vecvalder object argument
%Author: JR, 2014/06/18
%Use: x = vv(1); y = vv(2:5); ycell = vv{2:5}
%Note: {} uses a for loop and is very inefficient.
%Note: . support is pending actual need.

  if 1 == length(S.subs)
  	% eg, vvobj(1:5)
  	indices1 = S.subs{1};
  elseif 2 == length(S.subs)
  	% eg, vvobj(2,1)
  	indices1 = S.subs{1};
  	indices2 = S.subs{2};
  	if isnumeric(indices2) && 1 ~= indices2
  		error('vecvalder (vv2) subsref: second argument of type numeric but not 1');
  	end
  	if ischar(indices2) && 1 ~= strcmp(indices2, ':')
  		error('vecvalder (vv2) subsref: second argument is char but not :');
  	end
  	if ~((1 == isnumeric(indices2) ) || 1 == ischar(indices2) ) 
  		error('vecvalder (vv2) subsref: invalid second argument');
  	end
  else
  	error('vecvalder (vv2)subsref: more than 2 dimensions not supported');
  end
  out = vvobj;
  %out.valder = subsref(vvobj.valder, S);
  out.valder = vvobj.valder(S.subs{1}, ':');

  if 1 == strcmp(S.type, '{}')
    % return as a bunch of size-1 vecvalders in a cell array
    %error('vecvalder (vv2): subsref does not support {} yet');
    for i=1:size(out.valder,1)
        outcell{i} = vecvalder();
        outcell{i}.valder = out.valder(i,:);
    end
    out = outcell;
  elseif 1 == strcmp(S.type, '.')
    error('vecvalder (vv2): subsref does not support . yet');
  end
end
