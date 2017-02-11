function Qdepl = diode1_Qdepl(Vd, parms)
%function Qdepl = diode1_Qdepl(Vd, parms)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%
% 1N4004 diode SPICE parms (from http://www.allaboutcircuits.com/vol_3/chpt_3/14.html)
% .model Da1N4004 D (IS=18.8n RS=0 BV=400 IBV=5.00u CJO=30 M=0.333 N=2)

% see also http://www.mathworks.com/help/toolbox/physmod/elec/ref/diode.html

	if (nargin < 2) % parms not given
		% Vd
		fc = 0.5;
		% tt = 1ps: transit time
		tt = 1e-12;
		% Id
		% area = 1 (what units?)
		area = (1e-7)^2; % 0.1 micron on the side
		% cjo = ? zero-bias junction capacitance - F/m^2
		cjo = 30;
		phi = 0.7;
		m = 0.5;
		is = 1e-14;
	else
		fc = parms.fc;
		tt = parms.tt;
		area = parms.area;
		cjo = parms.cjo;
		phi = parms.phi;
		m = parms.m;
		is = parms.is;
	end
	%
	% fcp
	fcp = fc*phi;
	%f1, f2, f3
	%f1 = (phi/(1 - m))*(1 - pow((1 - fc), m));
	f1 = (phi/(1 - m))*(1 - (1 - fc)^m);
	%f2 = pow((1 - fc), (1 + m));
	f2 = (1 - fc)^(1 + m);
	f3 = 1 - fc*(1 + m);


	%% tt*Id: diffusion cap
	%% the rest: depletion cap

	% depletion (or junction) charge
	ifcond = (Vd <= fcp); % in general, a vector
	%if (Vd <= fcp)
	%     Qdepl = area*cjo*phi*(1 - pow((1 - Vd/phi), (1 - m)))/(1 - m);
	%else
	%     Qdepl = area*cjo*(f1+(1/f2)*(f3*(Vd-fcp)+(0.5*m/phi)*(Vd*Vd-fcp*fcp)));
	%end
	Qdepl = ifcond.*(area*cjo*phi*(1 - (1 - Vd/phi).^(1 - m))/(1 - m));
	Qdepl = Qdepl + (1-ifcond).*(area*cjo*(f1+(1/f2)*(f3*(Vd-fcp)...
		+(0.5*m/phi)*(Vd.*Vd-fcp*fcp))));

	% diffusion charge
	%Qdiff = tt*Id;

	% total charge
	%Qd = Qdiff + Qdepl;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





