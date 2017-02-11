function dfdxlim = df_dxlim_DAEAPI_auto(x, xlim, u, DAE)
%function dfdxlim = df_dxlim_DAEAPI_auto(x, xlim, u, DAE)
%This function computes the derivative of f of a DAE with respect to xlim using
%vecvalder.
%INPUT args:
%   x           - vector for unknowns
%   xlim        - vector for limited variables
%   u           - input vector 
%   DAE         - a DAEAPI object/structure describing a DAE
%
%OUTPUT:
%   dfdxlim     - df_dxlim(x,xlim,u,DAE) 

%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



	if 4 == nargin
		f_takes_xlim = 1;
		if 0 == DAE.f_takes_inputs
			error('df_dx_auto: 0 == DAE.f_takes_inputs and 3 arguments.');
			dfdx=[];
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
			error('df_dx_auto: 1 == DAE.f_takes_inputs and only 2 arguments.');
			dfdx=[];
			return;
		end
	end

    %{
    for Octave not to complain
	if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
		fprintf(2,'df_dxlim_auto: vecvalder (needed for computing df/dx) not found - aborting');
		dfdxlim = [];
		return;
	end
    %}

	nlvars = feval(DAE.nlimitedvars, DAE);
	neqns = feval(DAE.neqns, DAE);

	if 0 == f_takes_xlim
		dfdxlim = zeros(neqns, nlvars);
		return;
	end

	if 0 ~= nlvars
		vvxlim = vecvalder(xlim, speye(nlvars)); % single vecvalder

		if 0 == DAE.f_takes_inputs
			vvf_of_x = feval(DAE.f, x, vvxlim, DAE); 
		else
			vvf_of_x = feval(DAE.f, x, vvxlim, u, DAE);
		end

		if isa(vvf_of_x, 'vecvalder')
			dfdxlim = der2mat(vvf_of_x);
		else
			dfdxlim = sparse(neqns,nlvars);
		end
	else
		dfdxlim = sparse(neqns,nlvars);
	end
%end df_dxlim_auto
