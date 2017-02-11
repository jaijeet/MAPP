function dNRlimitingdx = dNRlimiting_dx_DAEAPI_auto(x, xlimOld, u, DAE)
%function dNRlimitingdx = dNRlimiting_dx_DAEAPI_auto(x, xlimOld, u, DAE)
%This function computes the derivative of NRlimiting of a DAE with respect to
% x using vecvalder.
%INPUT args:
%   x           - vector for unknowns
%   xlimOld     - vector for limited variables used in the last NR iteration
%   u           - input vector 
%   DAE         - a DAEAPI object/structure describing a DAE
%
%OUTPUT:
%   dNRlimitingdx        - dNRlimiting_dx(x,xlimOld,u,DAE) 

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
		fprintf(2,'dNRlimiting_dx_auto: vecvalder (needed for computing df/dx) not found - aborting');
		dNRlimitingdx = [];
		return;
	end
    %}

	nunks = feval(DAE.nunks, DAE);
	nlvars = feval(DAE.nlimitedvars, DAE);

	if 0 ~= nlvars
		vvx = vecvalder(x, speye(nunks)); % single vecvalder

		vvxlim_of_x = feval(DAE.NRlimiting, vvx, xlimOld, u, DAE);

		if isa(vvxlim_of_x, 'vecvalder')
			dNRlimitingdx = der2mat(vvxlim_of_x);
		else
			dNRlimitingdx = sparse(nlvars,nunks);
		end
	else
		dNRlimitingdx = sparse(nlvars,nunks);
	end

%end dNRlimiting_dx_auto
