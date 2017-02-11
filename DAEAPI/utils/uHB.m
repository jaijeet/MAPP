function uout = uHB(f, DAE)
% function uout = uHB(f, DAE)
%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2012/06/08
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	if isempty(DAE.uHBfunc_updates.vector_uHBfunc)
		%uHBfunc_default = @(f, DAEarg) zeros(feval(DAEarg.ninputs,DAEarg),1);
		uout = feval(DAE.uHBfunc_default, f, DAE);
	else
		uout = feval(DAE.uHBfunc_updates.vector_uHBfunc, f, DAE.uHBfunc_updates.vector_uHBfunc_args);
	end

	nI = length(DAE.uHBfunc_updates.indices);
	for i=1:nI
		u = feval(DAE.uHBfunc_updates.uHBfunclist{i}, f, DAE.uHBfunc_updates.uHBargslist{i});
		% u should be a row vector of F coeffs
		uout(DAE.uHBfunc_updates.indices(i),:) = u;
		% FIXME: we want to resize each u to the max row length, filling in zeros in the proper FFT order
	end
end % uHB
