function out = is_not_small(the_vec, vec_or_scalar_reference, norm_reltol, norm_abstol)
%function out = is_not_small(the_vec, vec_or_scalar_reference, norm_reltol, norm_abstol)
%returns 1 if ||the_vec|| > ||vec_or_scalar_reference||*norm_reltol norm_abstol, 0 otherwise
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	out = (norm(the_vec) > norm(vec_or_scalar_reference)*norm_reltol + norm_abstol);
end
