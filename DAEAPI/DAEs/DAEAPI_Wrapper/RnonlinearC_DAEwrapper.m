function DAE = RnonlinearC_DAEwrapper()
%function DAE = RnonlinearC_DAEwrapper()
%
%This is DAE for an RC circuit with a nonlinear C.
%
%The circuit:
%
%          ----<R>---- e1
%          |         |
%          | E(t)    |
%        -----     -----
%         ---      ===== q=qC(v) = C*(v+k*tanh(v)), k=0.5
%          |         |
%         ---       ---
%         ///       ///
%
% This is a scalar equation in the voltage of node 1. The voltage input node
% is eliminated.
%
% The equations are: d/dt q(e1) + (e1-E(t))/R = 0.
%
% No inputs are set.
%
%Example simulations:
%
% DAE = RnonlinearC_DAEwrapper();
% for A = [5 20];
%   DAE = feval(DAE.set_utransient, @(t,args) A*sin(2*pi*1000*t), [], DAE);
%   TR = transient(DAE, 0, 0, 0.5e-5, 5e-3);
%   TR.plot(TR);
%   title(sprintf('A=%g', A));
% end
% 
% have_Shooting = 1;
% if 1 == have_Shooting
%    A = 30;
%    DAE = feval(DAE.set_utransient, @(t,args) A*sin(2*pi*1000*t), [], DAE);
%    T = 1e-3;
%    SH = Shooting(DAE);
%    SH = feval(SH.solve, SH, 0, T);
%    feval(SH.plot, SH);
%    sol = feval(SH.getsolution, SH);
% end
%

	DAE = init_DAE();

	DAE = add_to_DAE(DAE, 'unkname(s)', {'e1'});
	DAE = add_to_DAE(DAE, 'eqnname(s)', {'KCL1'});
	DAE = add_to_DAE(DAE, 'inputname(s)', {'E'});
	DAE = add_to_DAE(DAE, 'outputname(s)', {'e1'});
	DAE = add_to_DAE(DAE, 'parm(s)', {'R', 1000, 'C', 1e-6, 'k', 0.5});

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
	out = 0;
end

function fout = f(S)
    fout = (S.e1-S.E)/S.R;
end % f()

function qout = q(S)
	qout = S.C*(S.e1 + S.k*tanh(S.e1));
end %q(...)
