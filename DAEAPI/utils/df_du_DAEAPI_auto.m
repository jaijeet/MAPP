function dfdu = df_du_DAEAPI_auto(x, xlim, u, DAE)
%function dfdu = df_du_DAEAPI_auto(x, xlim, u, DAE)
%This function computes the derivative of f of a DAE with respect to u using
%vecvalder.
%INPUT args:
%   x           - vector for unknowns
%   xlim        - vector for limited variables
%   u           - input vector 
%   DAE         - a DAEAPI object/structure describing a DAE
%
%OUTPUT:
%   dfdu        - df_du(x,xlim,u,DAE) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	if 4 == nargin
		f_takes_xlim = 1;
		if 0 == DAE.f_takes_inputs
			error('df_du_auto: 0 == DAE.f_takes_inputs and 3 arguments.');
			dfdu=[];
			return;
		end
	elseif 3 == nargin
		DAE = u;
		if 0 == DAE.f_takes_inputs
			f_takes_xlim = 1;
		else
			u = xlim;
			f_takes_xlim = 0;
		end
	else
		DAE = xlim;
		f_takes_xlim = 0;
		if 1 == DAE.f_takes_inputs
			error('df_du_auto: 1 == DAE.f_takes_inputs and only 2 arguments.');
			dfdu=[];
			return;
		end
	end

    %{ 
    for Octave not to complain
	if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
		fprintf(2,'df_du_auto: vecvalder (needed for computing df/du) not found - aborting');
		dfdu = [];
		return;
	end
    %}

	ninps = feval(DAE.ninputs, DAE);
	neqns = feval(DAE.neqns, DAE);

	vvu = vecvalder(u, speye(ninps)); % single vecvalder

	% if 0 == f_takes_xlim
	if 3 == nargin(DAE.f)
		vvf_of_u = feval(DAE.f, x, vvu, DAE);
	else
		vvf_of_u = feval(DAE.f, x, xlim, vvu, DAE);
	end

	if isa(vvf_of_u, 'vecvalder')
		dfdu = der2mat(vvf_of_u);
	else
		dfdu = sparse(neqns,ninps);
	end
%end df_du_auto
