function dfdx = df_dx_DAEAPI_auto(x, xlim, u, DAE)
%function dfdx = df_dx_DAEAPI_auto(x, xlim, u, DAE)
%This function computes the derivative of f of a DAE with respect to x using
%vecvalder.
%INPUT args:
%   x           - vector for unknowns
%   xlim        - vector for limited variables
%   u           - input vector 
%   DAE         - a DAEAPI object/structure describing a DAE
%
%OUTPUT:
%   dfdx        - df_dx(x,xlim,u,DAE) 

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
		fprintf(2,'df_dx_auto: vecvalder (needed for computing df/dx) not found - aborting');
		dfdx = [];
		return;
	end
    %}

	nunks = feval(DAE.nunks, DAE);
	neqns = feval(DAE.neqns, DAE);

	vvx = vecvalder(x, speye(nunks)); % single vecvalder

	if 0 == DAE.f_takes_inputs
		if 0 == f_takes_xlim
			if DAE.support_initlimiting
				vvxlim = DAE.xTOxlim(vvx, DAE);
				vvf_of_x = feval(DAE.f, vvx, vvxlim, DAE); 
			else
				vvf_of_x = feval(DAE.f, vvx, DAE); 
			end
		else
			if DAE.support_initlimiting
				vvf_of_x = feval(DAE.f, vvx, xlim, DAE); 
			else
                error(sprintf('The DAE %s doesn''t support init/limiting.',...
                     feval(DAE.daename, DAE)));
			end
		end
	else
		if 0 == f_takes_xlim
			if DAE.support_initlimiting
				vvxlim = DAE.xTOxlim(vvx, DAE);
				vvf_of_x = feval(DAE.f, vvx, vvxlim, u, DAE); 
			else
				vvf_of_x = feval(DAE.f, vvx, u, DAE); 
			end
		else
			if DAE.support_initlimiting
				vvf_of_x = feval(DAE.f, vvx, xlim, u, DAE); 
			else
                error(sprintf('The DAE %s doesn''t support init/limiting.',...
                     feval(DAE.daename, DAE)));
			end
		end
	end

	if isa(vvf_of_x, 'vecvalder')
		dfdx = der2mat(vvf_of_x);
	else
		dfdx = sparse(neqns,nunks);
	end
%end df_dx_auto
