function MOSobj = DSintSH
%function MOSobj = DSintSH
%Author: J. Roychowdhury <jr@berkeley.edu>, 2011/sometime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	MOSobj.f = @f;
%end


function [ID, dID_dVGS, dID_dVDS] = f(VGS, VDS, beta, VT)
%function [ID, dID_dVGS, dID_dVDS] = f(VGS, VDS, beta, VT)
%SH with drain-source inversion.
%
%DSintSH is vectorized wrt VDS (rows) and VGS (cols)
%VGS and VDS should be identically sized matrices - ./doit.m contains an
%example showing how to create them.
%ID is a matrix of the same size: nVGS rows x nVDS cols
%similarly dID_dVGS and dID_dVDS are also matrices with nVGS rows x nVDS cols
%
%
% logic: if VDS < 0, then drain and source should be exchanged, ie:
%	=> internal VDS = - (external VDS)
%	=> internal VGS = external VGD = external VGS - external VDS
%	=> external ID = - (internal ID)

	DSint = (VDS < 0); % 1 if DS exchanged, 0 if not

	% note on implementing if conditions in vectorized form: 
	% 	if (!DSint) {a} else {b} === (1-DSint)*a + DSint*b

	intVDS = (1-DSint).*VDS - DSint.*VDS;
	intVGS = (1-DSint).*VGS + DSint.*(VGS - VDS);

	[intID, dintID_dintVGS, dintID_dintVDS]=coreSH(intVGS,intVDS,beta,VT);

	ID = (1-DSint).*intID - DSint.*intID;

%%%%%%%%%%%%%%%%%% begin compute dID_dVGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% to get dID_dVGS: just differentiate the above mechanically, line by line
	if nargout >= 2
		% DSint = (VDS < 0);
		dDSint_dVGS = 0; % since (external) VDS and VGS are indep vars

		% intVDS = (1-DSint).*VDS - DSint.*VDS;
		dintVDS_dVGS = ... %-dDSint_dVGS.*VDS+(1-DSint).*dVDS_dVGS == 0
			... % - dDSint_dVGS.*VDS == 0
			- DSint.*0; % ie, dintVDS_dVGS == 0

		% intVGS = (1-DSint).*VGS + DSint.*(VGS - VDS);
		dintVGS_dVGS = ... % -dDSint_dVGS.*VGS == 0
			+ (1-DSint) ...
			... % + dDSint_dVGS.*(VGS-VDS)
			+ DSint; 
			% == simply a vector/matrix of 1s

		% intID = SH(intVGS, intVDS, beta, VT);
		% => dintID_dVGS = 
		%	dSH_dintVGS.*dintVGS_dVGS+dSH_dintVDS.*dintVDS_dVGS
		dintID_dVGS = dintID_dintVGS; %.*dintVGS_dVGS==1
			%+ dintID_dintVDS.*dintVDS_dVGS==0;

		% ID = (1-DSint).*intID - DSint.*intID;
		dID_dVGS = ... %-dDSint_dVGS.*intID==0
			+ (1-DSint).*dintID_dVGS ...
			... % - dDSint_dVGS.*intID==0
			- DSint.*dintID_dVGS;
	end %if nargout >= 2
%%%%%%%%%%%%%%%%%% end compute dID_dVGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%% begin compute dID_dVDS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute dID_dVDS by differentiating the code for ID mechanically:
	if nargout >= 3
		% DSint = (VDS < 0); % DSinit a function of VDS, but it is not
		% 	differentiable at VDS=0.
		dDSint_dVDS = 0; % this is valid everywhere except VDS=0. More
				 % correctly, this should be a delta function.
				 % However, the form of the SH equations is
				 % such that the value of dDSint_dVDS at VDS=0 
				 % will not matter eventually to ID, dID/dVGS or
				 % dID/dVDS - you can work this out on paper,
				 % or infer it from the code below.  So we
				 % leave it at 0, for convenience.

		% intVDS = (1-DSint).*VDS - DSint.*VDS;
		dintVDS_dVDS = -dDSint_dVDS.*VDS + (1-DSint) ...
			- dDSint_dVDS.*VDS - DSint; % ie, 1-2*DSint
		% we have kept the dDSint_dVDS terms above so that it is easy
		% to redefine it to a delta function approximation, if desired.

		% intVGS = (1-DSint).*VGS + DSint.*(VGS - VDS);
		dintVGS_dVDS = -dDSint_dVDS.*VGS ...
			... %+ (1-DSint).*0
			+ dDSint_dVDS.*(VGS-VDS) ...
			- DSint;  %% ie, -DSint.

		% intID = SH(intVGS, intVDS, beta, VT);
		% => dintID_dVDS = 
		%	dSH_dintVGS.*dintVGS_dVDS+dSH_dintVDS.*dintVDS_dVDS
		dintID_dVDS = dintID_dintVGS.*dintVGS_dVDS ...
			+ dintID_dintVDS.*dintVDS_dVDS;

		% ID = (1-DSint).*intID - DSint.*intID = (1-2*DSint).*intID;
		dID_dVDS = -2*dDSint_dVDS.*intID ...
			+ (1-2*DSint).*dintID_dVDS;
	end %if nargout >= 3
%%%%%%%%%%%%%%%%%% end compute dID_dVDS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
