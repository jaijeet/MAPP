function DAE = TwoReactionChainDAEAPI_wrapper()
	DAE = init_DAE();

	DAE = add_to_DAE(DAE, 'unkname(s)', {'nA', 'nB', 'nC', 'nD', 'nE'});
	DAE = add_to_DAE(DAE, 'eqnname(s)', {'dnA/dt', 'dnB/dt', 'dnC/dt', 'dnD/dt', 'dnE/dt'});
	DAE = add_to_DAE(DAE, 'outputname(s)', {'nA', 'nB', 'nC', 'nD', 'nE'});
	DAE = add_to_DAE(DAE, 'parm(s)', {'ks', [1.9 0.3 1.4 0.4]});
	DAE = add_to_DAE(DAE, 'f_takes_inputs', 0);
	DAE = add_to_DAE(DAE, 'f', @f);
	DAE = add_to_DAE(DAE, 'q', @q);
	DAE = add_to_DAE(DAE, 'internalfunc', @internalfuncs);

	DAE = finish_DAE(DAE);
end


function out = f(S)
	v2struct(S);
	%stoichmat = [ ...
	%	sA1, sA2; ... % determines d/dt [A]
	%	sB , 0  ; ... % determines d/dt [B]
	%	sC1, sC2; ... % determines d/dt [C]
	%	0  , sD ; ... % determines d/dt [D]
	%	0  , sE ; ... % determines d/dt [E]
	%];
	x = [nA; nB; nC; nD; nE];
	%x = vertcat(nA, nB, nC, nD, nE);
	ratevec = forwardratefunc(x, ks, DAE);
	stoichmat = stoichmatfunc(DAE);
	out = stoichmat*ratevec;
% end f(...)
end

function out = q(S)
	v2struct(S);
	x = [nA; nB; nC; nD; nE];
	%x = vertcat(nA, nB, nC, nD, nE);
	out = -x;
% end q(...)
end

%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
function ifs = internalfuncs(DAE)
	ifs.stoichmatfunc = @stoichmatfunc;
	ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
	ifs.forwardratefunc = @forwardratefunc;
	ifs.forwardratefuncUsage = 'feval(forwardratefunc, x, parms, DAE)';
% end internalfuncs
end

function stoichmat = stoichmatfunc(DAE)
	sA1 = -1;  % stoichiometric coeff for A, first reaction
	sA2 = +1;  % stoichiometric coeff for A, second reaction
	sB = -1;  % stoichiometric coeff for B
	sC1 = +1; % stoichiometric coeff for C, first reaction
	sC2 = -1; % stoichiometric coeff for C, second reaction
	sD = -1; % stoichiometric coeff for D
	sE = +1; % stoichiometric coeff for E

	stoichmat = [ ...
		sA1, sA2; ... % determines d/dt [A]
		sB , 0  ; ... % determines d/dt [B]
		sC1, sC2; ... % determines d/dt [C]
		0  , sD ; ... % determines d/dt [D]
		0  , sE ; ... % determines d/dt [E]
	];
% end stoichmatfunc
end

function forwardrates = forwardratefunc(x, parms, DAE)
		ks = parms;
		stoichmat = stoichmatfunc(DAE);

		sA1 = stoichmat(1,1); sA2 = stoichmat(1,2);
		sB  = stoichmat(2,1);
		sC1 = stoichmat(3,1); sC2 = stoichmat(3,2);
		sD  = stoichmat(4,2);
		sE  = stoichmat(5,2);

		k1 = ks(1); k2=ks(2); k3=ks(3); k4=ks(4);

		concA = x(1); concB = x(2); concC = x(3); concD = x(4);
		concE = x(5);

		rate1 = k1*concA^abs(sA1)*concB^abs(sB) ...
					- k2*concC^abs(sC1);
		rate2 = k3*concC^abs(sC2)*concD^abs(sD) ...
					- k4*concE^abs(sE)*concA^abs(sA2);

		forwardrates = [rate1; rate2];
% end forwardratesfunc
end

%%%%%%%%%%%%%%%% END INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%%

