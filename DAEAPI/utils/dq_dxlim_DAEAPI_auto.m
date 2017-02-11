function dqdxlim = dq_dxlim_DAEAPI_auto(x, xlim, DAE)
%function dqdxlim = dq_dxlim_DAEAPI_auto(x, xlim, DAE)
%This function computes the derivative of q of a DAE with respect to xlim using
%vecvalder.
%INPUT args:
%   x           - vector for unknowns
%   xlim        - vector for limited variables
%   u           - input vector 
%   DAE         - a DAEAPI object/structure describing a DAE
%
%OUTPUT:
%   dqdxlim        - dq_dxlim(x,xim,DAE) 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




	if 3 == nargin
		q_takes_xlim = 1;
	else
		DAE = xlim;
		q_takes_xlim = 0;
	end

    %{
    for Octave not to complain
	if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
		fprintf(2,'dq_dxlim_auto: vecvalder (needed for computing dq/dx) not found - aborting');
		dqdxlim = [];
		return;
	end
    %}

	nlvars = feval(DAE.nlimitedvars, DAE);
	neqns = feval(DAE.neqns, DAE);

	if 0 == q_takes_xlim
		dqdxlim = zeros(neqns, nlvars);
		return;
	end

	if 0 ~= nlvars
		vvxlim = vecvalder(xlim, speye(nlvars)); % single vecvalder

		vvq_of_x = feval(DAE.q, x, vvxlim, DAE); 

		if isa(vvq_of_x, 'vecvalder')
			dqdxlim = der2mat(vvq_of_x);
		else
			dqdxlim = sparse(neqns,nlvars);
		end
	else
		dqdxlim = sparse(neqns,nlvars);
	end
%end dq_dxlim_auto
