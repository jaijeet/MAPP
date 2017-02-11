function DAE = RCline_wrapper()
	% Build DAE skeleton
	DAE = init_DAE();

	% two unknowns of DAE, e1 and e2
	DAE = add_to_DAE(DAE, 'unkname(s)', {'e1'});
	DAE = add_to_DAE(DAE, 'unkname(s)', {'e2'});
	% DAE = add_to_DAE(DAE, 'unkname(s)', {'e1', 'e2'});
	% two equations of DAE, KCL_1 and KCL_2
	DAE = add_to_DAE(DAE, 'eqnname(s)', {'KCL_1', 'KCL_2'});
	% one input, u(t)
	DAE = add_to_DAE(DAE, 'inputname(s)', {'u'});
	% one output, e2(t)
	DAE = add_to_DAE(DAE, 'outputname(s)', {'e2'});
	% parameters: R, Cl
	DAE = add_to_DAE(DAE, 'parm(s)', {'R',1e3, 'C', 1e-6});
	
	% Input is not included by f, so f_takes_inputs == 0
	% Note that f_takes_inputs should be defined before f
	DAE = add_to_DAE(DAE, 'f_takes_inputs', 0);

	% B will be defined below
	DAE = add_to_DAE(DAE, 'B', @Bee);
	% C will be defined below
	DAE = add_to_DAE(DAE, 'C', @Cee);
	% D will be defined below
	DAE = add_to_DAE(DAE, 'D', @Dee);

	% f function will be defined below
	DAE = add_to_DAE(DAE, 'f', @f);
	% q function will be define below
	DAE = add_to_DAE(DAE, 'q', @q);

	% finish building DAEAPI
	DAE = finish_DAE(DAE);
end

function fout = f(S)
	% unpack struct
	v2struct(S);
	%	KCL_1: Cl de1/dt + (e1(t) - u(t))/R + (e1(t) - e2(t))/R = 0
	out(1,1) = e1/R + e1/R - e2/R;
	%	KCL_2: Cl de2/dt + (e2(t) - e1(t))/R = 0
	out(2,1) = e2/R - e1/R;

	fout = out;
end

function qout = q(S)
	% unpack struct
	v2struct(S);
	%	KCL_1: Cl de1/dt + (e1(t) - u(t))/R + (e1(t) - e2(t))/R = 0
	out(1,1) = C*e1;
	%	KCL_2: Cl de2/dt + (e2(t) - e1(t))/R = 0
	out(2,1) = C*e2;

	qout = out;
end

function out = Bee(S)
	% unpack struct
	v2struct(S);
	%	KCL_1: Cl de1/dt + (e1(t) - u(t))/R + (e1(t) - e2(t))/R = 0
	%	KCL_2: Cl de2/dt + (e2(t) - e1(t))/R = 0
	out = [-1/R;0];
end

% e2(t) is the only output, so C returns the vector [0,1]
function out = Cee(DAE)
	out = [0,1];
end

% u(t) has no effect on output, so D returns the scalar [0]
function out = Dee(DAE)
	out = [0];
end


