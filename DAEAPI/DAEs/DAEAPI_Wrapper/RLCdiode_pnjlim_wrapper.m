function DAE = RLCdiode_pnjlim_wrapper()
	DAE = init_DAE();

	DAE = add_to_DAE(DAE, 'unkname(s)', {'e1', 'iL'});
	DAE = add_to_DAE(DAE, 'eqnname(s)', {'KCL1', 'BCR_L'});
	DAE = add_to_DAE(DAE, 'inputname(s)', {'I'});
	DAE = add_to_DAE(DAE, 'outputname(s)', {'e1'});
	DAE = add_to_DAE(DAE, 'limitedvarname(s)', {'e1lim'});
	DAE = add_to_DAE(DAE, 'limited_matrix', [1, 0]);
	DAE = add_to_DAE(DAE, 'parm(s)', {'R', 1, 'Cl', 1e-6, 'L', 1e-9, 'Is', 1e-12, 'Vt', 0.025});

	DAE = add_to_DAE(DAE, 'B', @B);
	DAE = add_to_DAE(DAE, 'C', @C);
	DAE = add_to_DAE(DAE, 'D', @D);

	DAE = add_to_DAE(DAE, 'f_takes_inputs', 0);
	DAE = add_to_DAE(DAE, 'f', @f);
	DAE = add_to_DAE(DAE, 'q', @q);
	DAE = add_to_DAE(DAE, 'initguess', @initguess);
	DAE = add_to_DAE(DAE, 'limiting', @limiting);

	DAE = finish_DAE(DAE);
end

function out = B(S)
	out = [1;0];
end

function out = C(DAE)
	out = [1,0];
end

function out = D(DAE)
	out = [0];
end

function fout = f(S)
	v2struct(S);

	dobj = diode;

	%	C de1/dt + e1/R + iL + diode(e1,Is,Vt) + I(t) = 0
	out(1,1) = e1/R + iL + feval(dobj.f,e1lim,Is,Vt);

	% 	L diL/dt - e1 = 0
	out(2,1) = -e1;
	fout = out;
% end f(...)
end

function qout = q(S)
	v2struct(S);

	%	C de1/dt + e1/R + iL + diode(e1,Is,Vt) + I(t) = 0
	out(1,1) = Cl*e1;

	% 	L diL/dt - e1 = 0
	out(2,1) = L*iL;

	qout = out;
% end q(...)
end

function xlimInit = initguess(S)
	v2struct(S);
	Vcrit = Vt*log(Vt/(sqrt(2)*Is));
	xlimInit = Vcrit;
end

function xlimNew = limiting(S)
	v2struct(S);
	Vcrit = Vt*log(Vt/(sqrt(2)*Is));
	xlimNew = pnjlim(e1lim, e1, Vt, Vcrit);
	% Note that e1lim is xlimOld here
end
