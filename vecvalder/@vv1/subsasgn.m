function lhs = subsasgn(lhs, S, rhs)
  %VECVALDER/subsasgn lhs(indices) = rhs overloads subsasgn for a 
  %vecvalder object argument
  %Use: lhs(1:5) = rhs; lhs(1:5,1) = rhs; lhs(1:5,:) = rhs
  %     subsasgn is invoked only if lhs is a vecvalders. 
  %	TODO: need to also overload double.subsref(double, S, vecvalder)
  %	rhs can be: 
  %	    - another vecvalder (of the right dimension)
  %	    - a vector of the right dimension
  %	    - a scalar
  %
  %Note: builtin subsasgn works correctly for, eg,:
  %	- lhs(1:5) = vvobj; lhs(1:5,1) = vvobj; lhs(1:5,:) = vvobj;
  %ie, when the rhs is a vecvalder. But it does _not_ work correctly when the
  %rhs is not a vecvalder.  This overloaded subsasgn handles these latter
  %cases correctly by allocating 0s for the derivative entries.
  %
  %Author: J. Roychowdhury, 2011/10/17

  if ~isa(rhs, 'vecvalder') % non-vecvalder rhs => lhs must be vecvalder
  	nindeps = size(lhs(1).der,2);
	%rhs = vecvalder(rhs, sparse(zeros(size(rhs,1), nindeps)));
	nentries = size(rhs,1);
	if 1 == nentries  % rhs is just a scalar
  		if  1 == strcmp(S.type, '()')
			nentries = length(S.subs{1});
			rhs = rhs*ones(nentries,1);
		else
			error('vecvalder subsasgn: only () indexing currently supported\n');
		end
	end
	rhs = vecvalder(rhs, sparse(nentries, nindeps));
  end

  if ~isa(lhs, 'vecvalder') % non-vecvalder lhs => rhs must be vecvalder
  	%fprintf(2, 'subasgn: lhs is not a vecvalder\n');
	%{
		lhs = rhs; % this was extremely dangerous.
		example of problem

		% a does not exist yet, hence not a vecvalder
		a(2) = somevv(1)

		instead of creating a vecvalder of size 2, it creates a vv a
		of size 1! then, you do

		a(1) = someothervv(1)

		and it clobbers a(2)
	%}
	maxidx = max(S.subs{1});
	nlhs = length(lhs);

	if 0 == nlhs
		% lhs doesn't really exist, yet
  		nindeps = size(rhs(1).der,2);
		lhs = vecvalder(zeros(maxidx,1), sparse(maxidx, nindeps));
	else
		% lhs is an existing non-vecvalder vector
		fprintf(2,'in vecvalder.subsasgn(double, vecvalder)\n');
		if maxidx > nlhs
			lhs((nlhs+1):maxidx) = 0;
		end
		lhs = vecvalder(lhs, sparse(length(lhs), nindeps));
	end

	% now call subasgn(vecvalder, vecvalder) to do the real work
	lhs = subsasgn(lhs, S, rhs);
  else % lhs is vecvalder => use builtin subsasgn
	%{
  	lhs = builtin('subsasgn', lhs, S, rhs); % call builtin with vecvalder rhs 
	%}
	% problem: whatever this does sometimes breaks der2mat there's a problem with cell2mat
	% so we should write this from scratch
  	if  1 == strcmp(S.type, '()')
		lhsvals = val2mat(lhs);
		lhsders = der2mat(lhs);

		rhsvals = val2mat(rhs);
		rhsders = der2mat(rhs);

		%fprintf(2, 'S.subs{1}: '); S.subs{1}
		lhsvals(S.subs{1},1) = rhsvals(:,1);
		lhsders(S.subs{1},:) = rhsders;
		%lhsvals
		%lhsders
		lhs = vecvalder(lhsvals, lhsders);
	else
		error('vecvalder subsasgn: only () indexing currently supported\n');
	end
  end
end
