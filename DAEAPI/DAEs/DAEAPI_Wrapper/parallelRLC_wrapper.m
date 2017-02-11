function DAE = parallelRLC_wrapper()
% function DAE = parallelRLC_wrapper
% provides a DAE for a parallel RLC circuit (with no inputs)
% - default parameters: R=1, C=1uF, L=1nH (resonant freq = 5.0329 MHz)
%
%Example
%-------
%
% DAE = parallelRLC_wrapper();
% %feval(DAE.unknames, DAE);
% T = 2*pi*sqrt(1e-6*1e-9);
% tr = transient(DAE, [1;0], 0, T/50, 3*T); feval(tr.plot, tr);
%
%
	% Build DAE skeleton
	DAE = init_DAE();
	% two unkowns in DAEs, e1 and iL
	DAE = add_to_DAE(DAE, 'unkname(s)', {'e1', 'iL'});
	% two equations in DAE, KCL_e1 and BCR_L
	DAE = add_to_DAE(DAE, 'eqnname(s)', {'KCL_e1', 'BCR_L'});
	% one input, I(t)
	DAE = add_to_DAE(DAE, 'inputname(s)', {'I'});
	% one output, e1(t)
	DAE = add_to_DAE(DAE, 'outputname(s)', {'e1'});
	% parameters: R, C, L
	DAE = add_to_DAE(DAE, 'parm(s)', {'R',1, 'Cl', 1e-6, 'L', 1e-9});
	
	% Input is not included by f, so f_takes_inputs is 0
	% Note that f_takes_inputs should be defined before f
	DAE = add_to_DAE(DAE, 'f_takes_inputs', 0);

	% B will be defined below
	DAE = add_to_DAE(DAE, 'B', @B);
	% C will be defined below
	DAE = add_to_DAE(DAE, 'C', @C);
	% D will be defined below
	DAE = add_to_DAE(DAE, 'D', @D);

	% f function will be defined below
	DAE = add_to_DAE(DAE, 'f', @f);
	% q function will be define below
	DAE = add_to_DAE(DAE, 'q', @q);

	% finish building DAEAPI
	DAE = finish_DAE(DAE);
end

% I(t) effect only KCL_e1, so B returns the vector [1;0]
function out = B(S)
	out = [1;0];
end

% e1(t) is the only output, so C returns the vector [1;0]'
function out = C(DAE)
	out = [1,0];
end

% I(t) has no effect on output, so D returns the scalar [0]
function out = D(DAE)
	out = [0];
end

function fout = f(S)
	% unpack struct
	v2struct(S);
	%	C de1/dt + e1/R + iL + I(t) = 0
	out(1,1) = e1/R + iL;
	% 	L diL/dt - e1 = 0
	out(2,1) = -e1;

	fout = out;
end

function qout = q(S)
	% unpack struct
	v2struct(S);
	%	C de1/dt + e1/R + iL +  I(t) = 0
	out(1,1) = Cl*e1;
	% 	L diL/dt - e1 = 0
	out(2,1) = L*iL;

	qout = out;
end

