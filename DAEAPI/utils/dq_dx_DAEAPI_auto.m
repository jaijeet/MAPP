function dqdx = dq_dx_DAEAPI_auto(x, xlim, DAE)
%function dqdx = dq_dx_DAEAPI_auto(x, xlim, DAE)
%This function computes the derivative of q of a DAE with respect to x using
%vecvalder.
%INPUT args:
%   x           - vector for unknowns
%   xlim        - vector for limited variables
%   u           - input vector 
%   DAE         - a DAEAPI object/structure describing a DAE
%
%OUTPUT:
%   dqdx        - dq_dx(x,xim,DAE) 


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
		fprintf(2,'dq_dx_auto: vecvalder (needed for computing dq/dx) not found - aborting');
		dqdx = [];
		return;
	end
    %}

	nunks = feval(DAE.nunks, DAE);
	neqns = feval(DAE.neqns, DAE);

	vvx = vecvalder(x, speye(nunks)); % single vecvalder

	if 0 == q_takes_xlim
		if DAE.support_initlimiting
			vvxlim = DAE.xTOxlim(vvx, DAE);
			vvq_of_x = feval(DAE.q, vvx, vvxlim, DAE); 
		else
			vvq_of_x = feval(DAE.q, vvx, DAE); 
		end
	else
		if DAE.support_initlimiting
			vvq_of_x = feval(DAE.q, vvx, xlim, DAE); 
		else
			error(sprintf('The DAE %s doesn''t support init/limiting.',...
				 feval(DAE.daename, DAE)));
		end
	end

	if isa(vvq_of_x, 'vecvalder')
		dqdx = der2mat(vvq_of_x);
	else
		dqdx = sparse(neqns,nunks);
	end
%end dq_dx_auto
