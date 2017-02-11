function h = mtimes(A,v)
  %VECVALDER/MTIMES overloads matrix-vector multiplication * with vecvalder v
  if ~isa(A,'vecvalder') % A is numeric => v is vecvalder
  	h = vecvalder(A*val2mat(v), A*der2mat(v));
  else % A is a vecvalder - use times (.*)
  	h = times(A,v); 
	%h = A.*v;% weird problems in octave
  end
end
