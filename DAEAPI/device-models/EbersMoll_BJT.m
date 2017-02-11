function NBJTobj = EbersMoll_BJT
%function NBJTobj = EbersMoll_BJT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	NBJTobj.f = @f;
% end constructor


function [IC, IB, dIC_dVBE, dIC_dVCE, dIB_dVBE, dIB_dVCE] = f(VBE, VCE, IsF, VtF, IsR, VtR, alphaF, alphaR)
%function [IC, IB, dIC_dVBE, dIC_dVCE, dIB_dVBE, dIB_dVCE] = f(VBE, VCE, IsF, VtF, IsR, VtR, alphaF, alphaR)
%
%Note: the function is VECTORIZED wrt VBE (rows) and VCE (cols).
%VBE and VCE should be identically sized matrices.
%FIXME: put example code for creating VBE and VCE matrices.
%All the outputs will matrices of the same size: nVBE rows x nVCE cols

	% IC and IB
	diod = diode;
	[forward_diode_i, dfd_dVBE] = feval(diod.f, VBE, IsF, VtF);
	[reverse_diode_i, drd_dVBC] = feval(diod.f, VBE-VCE, IsR, VtR);
	IC = forward_diode_i*alphaF - reverse_diode_i;
	IB = forward_diode_i*(1-alphaF) + reverse_diode_i*(1-alphaR);

	if nargout > 2
		% compute and return the derivatives
		dIC_dVBE = alphaF*dfd_dVBE - drd_dVBC;
		dIC_dVCE = drd_dVBC;
		dIB_dVBE = (1-alphaF)*dfd_dVBE + (1-alphaR)*drd_dVBC;
		dIB_dVCE = - (1-alphaR)*drd_dVBC;
	end % if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





