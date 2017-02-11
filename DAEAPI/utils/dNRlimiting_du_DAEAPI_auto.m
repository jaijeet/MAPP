function dNRlimitingdu = dNRlimiting_du_DAEAPI_auto(x, xlimOld, u, DAE)
%function dNRlimitingdu = dNRlimiting_du_DAEAPI_auto(x, xlimOld, u, DAE)
%This function computes the derivative of NRlimiting of a DAE with respect to
% u using vecvalder.
%INPUT args:
%   x           - vector for unknowns
%   xlimOld     - vector for limited variables used in the last NR iteration
%   u           - input vector 
%   DAE         - a DAEAPI object/structure describing a DAE
%
%OUTPUT:
%   dNRlimitingdu        - dNRlimiting_du(x,xlimOld,u,DAE) 

%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





    %{
    for Octave not to complain
	if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
		fprintf(2,'dNRlimiting_du_auto: vecvalder (needed for computing df/dx) not found - aborting');
		dNRlimitingdu = [];
		return;
	end
    %}

	ninps = feval(DAE.ninputs, DAE);
	nlvars = feval(DAE.nlimitedvars, DAE);

	if 0 ~= nlvars
		vvu = vecvalder(u, speye(ninps)); % single vecvalder

		vvxlim_of_u = feval(DAE.NRlimiting, x, xlimOld, vvu, DAE);

		if isa(vvxlim_of_u, 'vecvalder')
			dNRlimitingdu = der2mat(vvxlim_of_u);
		else
			dNRlimitingdu = sparse(nlvars,ninps);
		end
	else
		dNRlimitingdu = sparse(nlvars,ninps);
	end
%end dNRlimiting_du_auto
