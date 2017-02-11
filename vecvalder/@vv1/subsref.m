function out = subsref(vvobj, S)
  %VECVALDER/subsref overloads subsref for a vecvalder object argument
  %Use: x = vv(1); y = vv(2:5);
  if  1 == strcmp(S.type, '()') || 1 == strcmp(S.type, '{}') 
  	if 1 == length(S.subs)
		% eg, vvobj(1:5)
		indices = S.subs{1};
	elseif 2 == length(S.subs)
		% eg, vvobj(2,1)
		indices = S.subs{1};
		arg2 = S.subs{2};
		if 1 == isa(arg2, 'numeric') && 1 ~= arg2
			error('vecvalder subsref: second argument of type numeric but not 1');
		end
		if 1 == isa(arg2, 'char') && 1 ~= strcmp(arg2, ':')
			error('vecvalder subsref: second argument is char but not :');
		end
		if ~((1 == isa(arg2, 'numeric') ) || 1 == isa(arg2, 'char') ) 
			error('vecvalder subsref: invalid second argument');
		end
	else
		error('vecvalder subsref: more than 2 dimensions not supported');
	end
  end % if

  if ischar(indices) && 1 == strcmp(indices, ':') % vv(:) access
  	indices = 1:length(vvobj);
  end

  if  1 == strcmp(S.type, '()')
	%vals = vvobj.val(indices,1);
	%derivs = vvobj.der(indices,2:end);
  	%error('vecvalder subsref: not implemented yet');
	%vals = vvobj.val;
	%ders = vvobj.der;
	out = vvobj(indices); % using built-in vv(1:3), which seems to work with only 1 index.
	%out = vecvalder(vals(indices,1), ders(indices,:));
  elseif 1 == strcmp(S.type, '{}')
  	% {} is useful for splitting components of a vecvalder object
	% into a cell array (which can then be used in, eg, deal(...))
	% of scalar vecvalders.
	for i=1:length(indices)
		out{i} = vvobj(indices(i));
	end
  elseif 1 == strcmp(S.type, '.')
	fld = S.subs;
	if 1 == strcmp(fld, 'val')
		out = vvobj.val(1);
	end
  	%error('vecvalder subsref: types other than () and {} not supported');
  end
end
