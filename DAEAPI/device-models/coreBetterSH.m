%author: J. Roychowdhury <jr@berkeley.edu>, 2011/sometime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% an attempt to make a proper SH model, using equations
% from Sedra and Smith, and making it charge based with the
% charges at least continuous.
%
% CURRENTLY INCOMPLETE
%
function SHdevice = betterCoreSH
	SHdevice.f = @f;
	SHdevice.q = @q;
% end

function [ID, IG, IS] = f(VDB, VGB, VSB)
% SH MOSFET model from Sedra and Smith
% 
% parameters:
% 	- use a directed graph to store parameter dependendencies
%	  - direction a -> b means b can be derived from a
%	  - bidirectional a <-> b means b can be derived from a, and vice-versa
%
%independent parameters:
% mu  - mobility
% Cox - oxide cap / unit area
% W - width
% L - length
% Lov - overlap length (used for overlap capacitance)
% lambda - (multiplies active region current by 1+lambda*Vds); 1/lambda is the Early voltage V_A
% Vt0 - "flat band threshold voltage"?
% gamma - body effect parameter; ~0.4 sqrt(V) for NMOS, -0.5 sqrt(V) for PMOS
% phi_f - ?
%	- 2*phi_f is ~0.6V for NMOS, ~0.75V for PMOS
% 
%dependent parameters:
% beta = mu Cox W/L
% Vt = Vt0 + gamma*(sqrt(2*phif + abs(VSB)) - sqrt(2*phif))

% non-dynamic components
	% VGS = VGB - VSB;
	% VDS = VDG - VSB;
	% VT = Vt0 + gamma*(sqrt(2*phif + abs(VSB)) - sqrt(2*phif));
	% 	note: dVT_dVSB = 0.5*gamma*sign(VSB)/(sqrt(2*phif + abs(VSB)) is _discontinuous_
	%
	% if (VGS < VT)
	% 	% off
	% 	ID = 0*VDS; % return vector
	% 	dID_dVGS = 0;
	% 	dID_dVDS = 0;
	% elseif (VGS <= VDS + VT)
	% 	% active
	% 	ID =beta/2*(VGS-VT)^2*(1+lambda*VDS)
	% 	dID_dVGS = beta*(VGS-VT)*(1+lambda*VDS);
	% 	dID_dVDS = lambda*beta/2*(VGS-VT)^2;
	% else % VGS > VDS+VT
	% 	% triode
	% 	ID = beta*VDS*(VGS-VT-VDS/2);
	% 	dID_dVGS = beta*VDS;
	% 	dID_dVDS = beta*(VGS-VT-VDS/2) - beta*VDS/2
	% 		 = beta*(VGS-VT) - beta*VDS = beta*(VGS-VT-VDS)
	% end


% dynamic equations - Sedra and Smith, Section 4.8
	%
	% total gate to channel capacitance Ctot = W*L*Cox
	% total overlap capacitance: Cov = W*Lov*Cox, with Lov ~ 0.1L
	%
	% triode region:
	%	- Cgs = Cgd = 0.5*Ctot + Cov
	%	- Cgb = 0;	
	% active region:
	%	- Cgs = 2/3 Ctot + Cov
	%	- Cgd = Cov
	%	- Cgb = 0
	% off region:
	%	- Cgs = Cgd = Cov
	%	- Cgb = Ctot
	%
	% moving the above to a charge-based model, there are 3 charges: qD, qG, qS
	% triode region:
	%	- qGS = (0.5*Ctot+Cov)*VGS
	%	- qGD = (0.5*Ctot+Cov)*VGD
	%	- qGB = 0;	
	%
	%	=>
	%
	%	- qG = qGS + qGD = (0.5*Ctot+Cov)*VGS + (0.5*Ctot+Cov)*VGD
	%	- qS = -qGS = -(0.5*Ctot+Cov)*VGS
	%	- qD = -qGD = -(0.5*Ctot+Cov)*VGD
	%	- qB = 0
	% -------------------------------------------------------------
	%	- check: qG + qS + qD + qB = 0
	%
	% active region:
	%	- qGS = Cgs*VGS = (2/3 Ctot + Cov)*VGS
	%	- qGD = Cgd*VGD = Cov*VGD
	%	- qGB = Cgb*VGB = 0
	%
	%	=>
	%
	%	- qG = qGS + qGD = (2/3 Ctot + Cov)*VGS + Cov*VGD
	%	- qS = -qGS = -(2/3 Ctot + Cov)*VGS
	%	- qD = -qGD = - Cov*VGD
	%	- qB = 0
	% -------------------------------------------------------------
	%	- check: qG + qS + qD + qB = 0
	%
	% off region:
	%	- qGS = Cgs*VGS = Cov*VGS
	%	- qGD = Cgd*VGD = Cov*VGD
	%	- qGB = Cgb*VGB = Ctot*VGB
	%
	%	=>
	%
	%	- qG = qGS + qGD + qGB = Cov*(VGS+VGD) + Ctot*VGB
	%	- qS = -qGS = -Cov*VGS
	%	- qD = -qGD = -Cov*VGD
	%	- qB = -qGB = - Ctot*VGB
	% -------------------------------------------------------------
	%	- check: qG + qS + qD + qB = 0
	%
	% Note that the qs are not even continuous as we go from off to active
	% to triode. So we need to add charges to the active and triode regions
	% to make it continuous.
	%
	% We start with VGS=0, VDS=+ve and start moving VGS up. Initially,
	% when VGS < Vt, we are in the off region. At VGS=Vt, we have VGS-Vt=0,
	% hence VGS-Vt < VDS; so we go to the active region. As VGS keeps
	% increasing, we arrive at VGS-Vt = VDS; at this point, we go
	% to the triode region.
	%
	% Can we jump directly from the off to the triode region? Yes, if VDS=0,
	% in which case the active region becomes of size null.
	% 
	% making the qs continuous:
	%
	% boundary between off region and active region: VGS=Vt with VDS>0:
	%   - off region charge equations:
	%	- qGS = Cgs*VGS = Cov*VGS = Cov*Vt
	%	- qGD = Cgd*VGD = Cov*VGD = Cov*(VGS - VDS) = Cov*(Vt-VDS)
	%	- qGB = Cgb*VGB = Ctot*VGB
	%   - active region charge equations:
	%	- qGS = Cgs*VGS = (2/3 Ctot + Cov)*VGS = (2/3 Ctot + Cov)*Vt: discontinuous
	%		- if we add a constant 2/3*Ctot*Vt to the off equation, it becomes continuous		
	%		- or we could gradually increase it to 2/3 Ctot*VGS
	%	- qGD = Cgd*VGD = Cov*VGD: continuous
	%	- qGB = Cgb*VGB = 0: discontinuous
	%		- VGB = VGS + VSB, which at the boundary is Vt(VSB) + VSB
	%		- if we add the (VGS-independent) constant Ctot*(Vt + VSB) to qGB in the active
	%		  region, then it becomes continuous. This should be OK.
	%
	% boundary between active and triode regions: VGS-Vt=VDS>0:
	%   - active region charge equations:
	%	- qGS = Cgs*VGS = (2/3 Ctot + Cov)*VGS = (2/3 Ctot + Cov)*Vt: discontinuous
	%		- if we add a constant 2/3*Ctot*Vt to the off equation, it becomes continuous		
	%		- or we could gradually increase it to 2/3 Ctot*VGS
	%	- qGD = Cgd*VGD = Cov*VGD: continuous
	%	- qGB = Cgb*VGB = Ctot*(Vt+VSB)% was 0 before
	%		- VGB = VGS + VSB, which at the boundary is Vt(VSB) + VSB
	%		- if we add the (VGS-independent) constant Ctot*(Vt + VSB) to qGB in the active
	%		  region, then it becomes continuous. This should be OK.
	%
	%   - triode region charge equations:
	%	- qGS = (0.5*Ctot+Cov)*VGS = (0.5*Ctot+Cov)*VGS: discontinuous by Ctot*VGS/6 (compare with (2/3 Ctot + Cov)*VGSby)
	%		- could fix by adding the "constant" Ctot*VGS/6 @ VGS=VDS+Vt, ie, Ctot/6*(VDS+Vt)
	%	- qGD = (0.5*Ctot+Cov)*VGD: discontinuous by 0.5*Ctot*VGD = 0.5*Ctot*(VGS-VDS) = 0.5*Ctot*Vt
	%		- could fix by adding 0.5*Ctot*Vt to the active and off equations.
	%	- qGB = 0; % continuous wrt the fixed version above
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% So, the fixed charge equations are:
	%   - off region charge equations:
	%	- qGS = Cov*VGS + 2/3*Ctot*Vt
	%	- qGD = Cov*VGD + 0.5*Ctot*Vt
	%	- qGB = Ctot*VGB = Ctot(VGS+VSB)
	%	
	%   - active region charge equations: (boundary: VGS=Vt with VDS>0)
	%	- qGS = (2/3 Ctot + Cov)*VGS
	%	- qGD = Cov*VGD + 0.5*Ctot*Vt
	%	- qGB = Ctot*(Vt+VSB)
	%
	%   - triode region charge equations: (boundary: VGS-Vt=VDS>0)
	%	- qGS = (0.5*Ctot+Cov)*VGS + Ctot/6*(VDS+Vt)
	%	- qGD = (0.5*Ctot+Cov)*VGD
	%	- qGB = Ctot*(Vt+VSB)
	%
	% and these should be continuous across the boundaries
	%
	% next step: translate these expressions to qD, qG and qS; plot each of these as a function of
	%	VGB, VDB and VSB, respectively - indeed, keep VSB fixed (eg, at 0 or some other value)
	%	then do 3D plots wrt VGB and VDB
	%	



	% vectorized version
	notoff = (VGS >= VT); % vector/matrix (of size VGS) of 0s/1s 
	active = (VGS <= VDS + VT); % vector/matrix (of size VDS) of 0s/1s 
	triode = 1-active;

	ID = notoff.*(active.*(beta/2*(VGS-VT).^2) + ... 
			triode.*beta.*VDS.*(VGS-VT-VDS/2));

	if nargout >= 2
		dID_dVGS = notoff.*(active.*beta.*(VGS-VT) + ...
			triode.*beta.*VDS);
	end % if

	if nargout == 3
		dID_dVDS = notoff.*triode.*beta.*(VGS-VT-VDS);
	end % if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





