function DAE = mixerfilter_DAEwrapper()
%function DAE = mixerfilter_DAEwrapper()
%
%This is a DAE for an ideal mixer followed by an RC filter.
%
%The circuit:
%                     __
%          ----->----/x \-->---<R>---- e1
%          |         \__/            |
%          | E(t)     |              |
%        -----        |            ----- C
%         ---       vLO(t)         ----- 
%          |                         |
%         ---                       ---
%         ///                       ///
%
% This is a scalar equation in the voltage of node 1. The voltage inputs
% nodes are eliminated.
%
% The equations are: d/dt (C*e1) + (e1-E(t)*vLO(t))/R = 0.
%
% C = 1e-6, R = 1e3;
%
% No inputs are set. 
%
%Example simulations:
%
% DAE = mixerfilter_DAEwrapper();
% 
% if 1 == have_Shooting
%    A = 3;
%    DAE = feval(DAE.set_utransient, @(t,args) A*sin(2*pi*1000*t), [], DAE);
%    T = 1e-3;
%    SH = Shooting(DAE);
%    SH = feval(SH.solve, SH, 0, T);
%    fval(SH.plot, SH);
%    sol = feval(SH.getsolution, SH);
% end
%

	DAE = init_DAE();

	DAE = add_to_DAE(DAE, 'unkname(s)', {'e1'});
	DAE = add_to_DAE(DAE, 'eqnname(s)', {'KCL1'});
	DAE = add_to_DAE(DAE, 'inputname(s)', {'E', 'vLO'});
	DAE = add_to_DAE(DAE, 'outputname(s)', {'e1'});
	DAE = add_to_DAE(DAE, 'parm(s)', {'R', 1000, 'C', 1e-6});

	DAE = add_to_DAE(DAE, 'C', @C);
	DAE = add_to_DAE(DAE, 'D', @D);

	DAE = add_to_DAE(DAE, 'f_takes_inputs', 1);
	DAE = add_to_DAE(DAE, 'f', @f);
	DAE = add_to_DAE(DAE, 'q', @q);

	DAE = finish_DAE(DAE);
end

function out = C(DAE)
	out = 1;
end

function out = D(DAE)
	out = [0, 0];
end

function fout = f(S)
    fout = (S.e1-S.E*S.vLO)/S.R;
end % f()

function qout = q(S)
	qout = S.C*S.e1;
end %q(...)
