function lhs = subsasgn(lhs, S, rhs)
%function lhs = subsasgn(lhs, S, rhs)
%VECVALDER/subsasgn lhs(indices) = rhs overloads subsasgn for a vecvalder
%object argument.
%Use: lhs(1:5) = rhs; lhs(1:5,1) = rhs; lhs(1:5,:) = rhs
%       subsasgn is invoked only if lhs is a vecvalder. (?)
%
%The second index, if present, is basically ignored - it is always taken to be
%1. It's value is NOT CHECKED (for efficiency). lhs(:,n) or lhs(:,n:m) WILL
%NOT DO WHAT YOU THINK (whatever that might be) if n or m > 1.
%
%MINIMAL SIZE/TYPE CHECKS (for efficiency): relying mostly on underlying numeric
%operations and builtin subsasgn.
%
%Note: only S.type = '()' is supported - '{}' and '.' are not supported.
%
%Author: J. Roychowdhury, 2014/06/18

  if strcmp(S.type, '{}') || strcmp(S.type, '.')
    error('vecvalder (vv2) subasgn: {} and . are not supported.');
  end

  if isobject(lhs)
    oof = lhs; % copy LHS structure
  else % lhs can in fact be [] if it does not yet exist; rhs is then a vecvalder
    oof = rhs; % copy RHS structure
    oof.valder = 0*oof.valder; % zero everything
  end

  S.subs{2} = ':';
  oof.valder(S.subs{1},:) = 0; % this creates new rows if S.subs{1} exceeds
                               % current matrix dimensions
  tmp = subsref(oof.valder, S);

  if ~isobject(rhs) % non-vecvalder rhs => derivs set to zero
    tmp = zeros(size(tmp)); 
    tmp(:,1) = rhs; % rhs should be of the right size
  else % rhs is also a vecvalder
    if 1==size(rhs.valder,1)
        tmp = ones(size(tmp,1),1)*rhs.valder;
    else
        tmp = rhs.valder;
    end
  end
  oof.valder(S.subs{1},:) = tmp;
  lhs = oof;
end
