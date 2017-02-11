function DAE = BJTdiffpair_wrapper()
	DAE = init_DAE();

	DAE = add_to_DAE(DAE, 'uniqIDstr','BJTdiffpair');
	DAE = add_to_DAE(DAE, 'nameStr', 'Diffpari with Ebers-Moll BJTs');
	DAE = add_to_DAE(DAE, 'unkname(s)', {'eCL', 'eCR', 'eE', 'eIN'});
	DAE = add_to_DAE(DAE, 'eqnname(s)', {'CL_KCL', 'CR_KCL', 'E_KCL', 'IN_KVL'});
	DAE = add_to_DAE(DAE, 'inputname(s)', {'Vin'});
	DAE = add_to_DAE(DAE, 'outputname(s)', {'Vout=eCL-rCR'});

	DAE = add_to_DAE(DAE, 'parm(s)', {'VDD', 5, 'IE', 2e-3, 'rL', 2e3, 'rR', 2e3, 'CL', 1e-6, 'CR', 1e-6});
	DAE = add_to_DAE(DAE, 'parm(s)', {'QR_IsF', 1e-12, 'QR_VtF', 0.025, 'QR_IsR', 1e-12, 'QR_VtR', 0.025, 'QR_alphaF', 0.99, 'QR_alphaR', 0.5});
	DAE = add_to_DAE(DAE, 'parm(s)', {'QL_IsF', 1e-12, 'QL_VtF', 0.025, 'QL_IsR', 1e-12, 'QL_VtR', 0.025, 'QL_alphaF', 0.99, 'QL_alphaR', 0.5});
	DAE = add_to_DAE(DAE, 'f_takes_inputs', 1);

	DAE = add_to_DAE(DAE, 'f', @f);
	DAE = add_to_DAE(DAE, 'q', @q);

	DAE = add_to_DAE(DAE, 'C', @C);
	DAE = add_to_DAE(DAE, 'D', @D);

	DAE = finish_DAE(DAE);
end

function fout = f(S)
	v2struct(S);

	NBJT = EbersMoll_BJT;
	% CL KCL: -(VDD-eCL)/rL + left_BJT_IC(Vin-eE, eCL-eE);
	[QL_IC, QL_IB] = feval(NBJT.f, Vin-eE, eCL-eE, QL_IsF, QL_VtF, QL_IsR, QL_VtR, QL_alphaF, QL_alphaR);
	fout(1,1) = -(VDD-eCL)/rL + QL_IC;

	% CR KCL: -(VDD-eCR)/rR + right_BJT_IC(0-eE, eCR-eE);
	[QR_IC, QR_IB] = feval(NBJT.f, -eE, eCR-eE, QR_IsF, QR_VtF, QR_IsR, QR_VtR, QR_alphaF, QR_alphaR);
	fout(2,1) = -(VDD-eCR)/rR + QR_IC;

	% E  KCL: IE - left_BJT_IC(Vin-eE, eCL-eE) - left_BJT_IB(Vin-eE, eCL-eE)
	%	  - right_BJT_IC(0-eE, eCR-eE) - right_BJT_IB(0-eE, eCR-eE);
	fout(3,1) = IE - QL_IC - QL_IB - QR_IC - QR_IB;
	fout(4,1) = eIN - Vin;
% end f(...)
end

function qout = q(S)
	v2struct(S);

	% CL KCL: - d/dt(CL*(VDD-eCL)) -(VDD-eCL)/rL + left_BJT_IC(Vin-eE, eCL-eE);
	qout(1,1) = -CL*(VDD-eCL);

	% CR KCL: - d/dt(CR*(VDD-eCR)) -(VDD-eCR)/rR + right_BJT_IC(0-eE, eCR-eE);
	qout(2,1) = -CR*(VDD-eCR);

	qout(3,1) = 0;
	qout(4,1) = 0;
% end q(...)
end

function out = C(DAE)
	out = [1 -1 0 0]; % Vout = eCL - eCR
% end C(...)
end

function out = D(DAE)
	out = 0;
% end D(...)
end
