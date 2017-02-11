function dmdx = dm_dx_DAEAPI_auto(x, n, DAE)
%function dmdx = dm_dx_DAEAPI_auto(x, n, DAE)
%This function computes the derivative of m of a DAE with respect to x using
%vecvalder.
%INPUT args:
%   x           - vector for unknowns
%   n           - noise vector 
%   DAE         - a DAEAPI object/structure describing a DAE
%
%OUTPUT:
%   dmdx        - dm_dx(x,n,DAE) 
%

    %{
    for Octave not to complain
	if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
		fprintf(2,'dm_dx_auto: vecvalder (needed for computing dm/dx) not found - aborting');
		dmdx = [];
		return;
	end
    %}

	nunks = feval(DAE.nunks, DAE);
	neqns = feval(DAE.neqns, DAE);

	vvx = vecvalder(x, speye(nunks)); % single vecvalder

	vvm_of_x = feval(DAE.m, vvx, n, DAE);

	if isa(vvm_of_x, 'vecvalder')
		dmdx = der2mat(vvm_of_x);
	else
		dmdx = sparse(neqns, nunks);
	end
%end dm_dx_auto
