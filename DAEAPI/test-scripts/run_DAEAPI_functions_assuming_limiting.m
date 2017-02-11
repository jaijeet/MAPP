function [filename, is_new] = run_DAEAPI_functions(DAE, name, lastarg)
%========================================================
% function run_DAEAPI_functions(DAE, name, lastarg)
% Author: Tianshi Wang, 2012-11-20
%
% Usage: (1) run_DAEAPI_functions(DAE, name)
% 	If no lastarg or lastarg is anything but 'update'
% 	run all functions in DAE, print test results 
% 	on screen.
%
%	 (2) run_DAEAPI_functions(DAE, name, 'update')
% 	Update test-data when you are satisfied with
% 	the current DAE.
%
% Inputs:  DAE 	    --> DAE to test
%          name     --> name of the function that generates
%			DAE. 
%			Consistent with .mat file
%	   lastarg  --> 'update' or nothing
%	  
% Outputs: filename --> name of the .mat file
%	   is_new   --> 1 the .mat is newly created by this function
%			0 the .mat exists before this function
%
%========================================================
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin < 1
	% help strings
	fprintf('Usage: (1) run_DAEAPI_functions(DAE, name)\n');
	fprintf('	Run all functions in DAE, print test results \n');
	fprintf('	on screen.\n');
	fprintf('       (2) run_DAEAPI_functions(DAE, name, ''update'')\n');
	fprintf('	Update test-data when you are satisfied with\n');
	fprintf('	the current DAE.\n');
	fprintf('Outputs: [filename, is_new] \n');
	fprintf('        is_new==1 if the .mat file is created by this function\n');
	return;
elseif nargin < 2
	% help strings
	fprintf('Usage: (1) run_DAEAPI_functions(DAE, name)\n');
	fprintf('       (2) run_DAEAPI_functions(DAE, name, ''update'')\n');
	fprintf('run:   run_DAEAPI_functions() for help strings\n');
	return;
elseif nargin < 3
	update = 0;
else
	update = is_equal(lastarg, 'update');
end
%
filename = sprintf('%s.mat', name);
if exist(filename) 
	load(filename); % get ref in workspace
	is_new = 0;
else
	is_new = 1;
	if ~update
		error(sprintf('Test-data file %s doesn''t exist, do update first!',filename));
	end
end

%===========================================================
fprintf(1, '--------------------------------------------\n');
fprintf(1, '               static testing               \n');
%
%===========================================================
% run nunks
test.nunks = feval(DAE.nunks, DAE);
if update
	fprintf(1, 'nunks: %d\n', test.nunks);
else
	if is_equal(test.nunks, ref.nunks)
		print_success('nunks');
	else
		print_failure('nunks', test.nunks, ref.nunks);
	end
end

%===========================================================
% run neqns
test.neqns = feval(DAE.neqns, DAE);
if update
	fprintf(1, 'neqns: %d\n', test.neqns);
else
	if is_equal(test.neqns, ref.neqns)
		print_success('neqns');
	else
		print_failure('neqns', test.neqns, ref.neqns);
	end
end

%===========================================================
% run ninputs
test.ninputs = feval(DAE.ninputs, DAE);
if update
	fprintf(1, 'ninputs: %d\n', test.ninputs);
else
	if is_equal(test.ninputs, ref.ninputs)
		print_success('ninputs');
	else
		print_failure('ninputs', test.ninputs, ref.ninputs);
	end
end

%===========================================================
% run noutputs
test.noutputs = feval(DAE.noutputs, DAE);
if update
	fprintf(1, 'noutputs: %d\n', test.noutputs);
else
	if is_equal(test.noutputs, ref.noutputs)
		print_success('noutputs');
	else
		print_failure('noutputs', test.noutputs, ref.noutputs);
	end
end

%===========================================================
% run nlimitedvars
test.nlimitedvars = feval(DAE.nlimitedvars, DAE);
if update
	fprintf(1, 'nlimitedvars: %d\n', test.nlimitedvars);
else
	if is_equal(test.nlimitedvars, ref.nlimitedvars)
		print_success('nlimitedvars');
	else
		print_failure('nlimitedvars', test.nlimitedvars, ref.nlimitedvars);
	end
end

%===========================================================
% run nparms
test.nparms = feval(DAE.nparms, DAE);
if update
	fprintf(1, 'nparms: %d\n', test.nparms);
else
	if is_equal(test.nparms, ref.nparms)
		print_success('nparms');
	else
		print_failure('nparms', test.nparms, ref.nparms);
	end
end

%===========================================================
% run uniqID
test.uniqID = feval(DAE.uniqID, DAE);
if update
	fprintf(1, 'uniqID: %s\n', test.uniqID);
else
	if is_equal(test.uniqID, ref.uniqID)
		print_success('uniqID');
	else
		print_failure('uniqID', test.uniqID, ref.uniqID);
	end
end

%===========================================================
% run daename
test.daename = feval(DAE.daename, DAE);
if update
	fprintf(1, 'daename: %s\n', test.daename);
else
	if is_equal(test.daename, ref.daename)
		print_success('daename');
	else
		print_failure('daename', test.daename, ref.daename);
	end
end

%===========================================================
% run unknames
test.unknames = feval(DAE.unknames, DAE);
if update
	fprintf(1, 'unknames: %s\n', cell2str(test.unknames));
else
	if is_equal(test.unknames, ref.unknames)
		print_success('unknames');
	else
		print_failure('unknames', test.unknames, ref.unknames);
	end
end

%===========================================================
% run eqnnames
test.eqnnames = feval(DAE.eqnnames, DAE);
if update
	fprintf(1, 'eqnnames: %s\n', cell2str(test.eqnnames));
else
	if is_equal(test.eqnnames, ref.eqnnames)
		print_success('eqnnames');
	else
		print_failure('eqnnames', test.eqnnames, ref.eqnnames);
	end
end

%===========================================================
% run inputnames
test.inputnames = feval(DAE.inputnames, DAE);
if update
	fprintf(1, 'inputnames: %s\n', cell2str(test.inputnames));
else
	if is_equal(test.inputnames, ref.inputnames)
		print_success('inputnames');
	else
		print_failure('inputnames', test.inputnames, ref.inputnames);
	end
end

%===========================================================
% run outputnames
test.outputnames = feval(DAE.outputnames, DAE);
if update
	fprintf(1, 'outputnames: %s\n', cell2str(test.outputnames));
else
	if is_equal(test.outputnames, ref.outputnames)
		print_success('outputnames');
	else
		print_failure('outputnames', test.outputnames, ref.outputnames);
	end
end

%===========================================================
% run limitedvarnames
test.limitedvarnames = feval(DAE.limitedvarnames, DAE);
if update
	fprintf(1, 'limitedvarnames: %s\n', cell2str(test.limitedvarnames));
else
	if is_equal(test.limitedvarnames, ref.limitedvarnames)
		print_success('limitedvarnames');
	else
		print_failure('limitedvarnames', test.limitedvarnames, ref.limitedvarnames);
	end
end

%===========================================================
% run parmnames
test.parmnames = feval(DAE.parmnames, DAE);
if update
	fprintf(1, 'parmnames: %s\n', cell2str(test.parmnames));
else
	if is_equal(test.parmnames, ref.parmnames)
		print_success('parmnames');
	else
		print_failure('parmnames', test.parmnames, ref.parmnames);
	end
end

%===========================================================
% getparms and setparms 
parmvals = feval(DAE.parmdefaults, DAE);

if length(parmvals) > 0
	% setparms
	parmvals{end} = 100;
	DAE = feval(DAE.setparms, parmvals, DAE);

	% getparms
	newpvals = feval(DAE.getparms, DAE);
	err = parmvals{end} - newpvals{end};
	if 0 == err
		print_success('setparms');
	else
		print_failure('setparms');
	end
end % if

%===========================================================
test.B = feval(DAE.B, DAE);
if update
	test.B
else
	if is_equal(test.B, ref.B)
		print_success('B');
	else
		print_failure('B', test.B, ref.B);
	end
end

%===========================================================
test.C = feval(DAE.C, DAE);
if update
	test.C
else
	if is_equal(test.C, ref.C)
		print_success('C');
	else
		print_failure('C', test.C, ref.C);
	end
end

%===========================================================
test.D = feval(DAE.D, DAE);
if update
	test.D
else
	if is_equal(test.D, ref.D)
		print_success('D');
	else
		print_failure('D', test.D, ref.D);
	end
end

%===========================================================
%   dynamic tests: test f, q on different cases
%		   test init/limiting
%   random  tests: test f, q on random cases
%		   test init/limiting
%===========================================================

if update && ~exist(filename)
	n_dtests = 2;
	n_rtests = 1;
	[test.dtests, test.rtests] = generate_cases_DAEAPI...
 		(n_dtests, n_rtests, DAE);
else
	n_dtests = length(ref.dtests);
	n_rtests = ref.rtests{1};
	test.dtests = ref.dtests;
	test.rtests = ref.rtests;
end
%
random = 0;
%
for c = 1 : (n_dtests+n_rtests)
	if c > n_dtests
		random = 1;
		rand('seed',  etime(clock, [1900, 1, 1, 0, 0, 0]));
	end
	if random
		fprintf(1, '--------------------------------------------\n');
		fprintf(1, '      random testing on case %d             \n', c-n_dtests);
		x = rand(test.nunks,1); 
		xlim = rand(test.nlimitedvars,1); 
		xlimOld = rand(test.nlimitedvars,1); 
		u = rand(test.ninputs,1); 
	else 
		fprintf(1, '--------------------------------------------\n');
		fprintf(1, '      dynamic testing on case %d            \n', c);
		testc = test.dtests{c};
		x = testc.x;
		xlim = testc.xlim;
		xlimOld = testc.xlimOld;
		u = testc.u;
		if exist(filename)
			refc = ref.dtests{c};
		end
	end

	%===========================================================
	% run f
	if 0 == DAE.f_takes_inputs
		testc.f_of_x = feval(DAE.f, x, xlim, DAE);
	else
		testc.f_of_x = feval(DAE.f, x, xlim, u, DAE);
	end
	if update
		fprintf(1, 'running f_of_x=f(x, xlim, u):\n\t');
		testc.f_of_x
	else
		if ~random && is_equal(testc.f_of_x, refc.f_of_x) || ...
		   random  && ~is_nan(testc.f_of_x)
			print_success('f');
		else
			print_failure('f');
			x, xlim
			if 1 == DAE.f_takes_inputs
			u
			end
		end
	end

	%===========================================================
	% run df_dx
	if 0 == DAE.f_takes_inputs
		testc.df_dx = feval(DAE.df_dx, x, xlim, DAE);
	else
		testc.df_dx = feval(DAE.df_dx, x, xlim, u, DAE);
	end
	if update
		fprintf(1, 'running df_dx=df_dx(x, xlim, u):\n\t');
		testc.df_dx
	else
		if ~random && is_equal(testc.df_dx, refc.df_dx) || ...
		   random  && ~is_nan(testc.df_dx)
			print_success('df_dx');
		else
			print_failure('df_dx');
			x, xlim
			if 1 == DAE.f_takes_inputs
			u
			end
		end
	end

	%===========================================================
	% run df_dxlim
	if 0 == DAE.f_takes_inputs
		testc.df_dxlim = feval(DAE.df_dxlim, x, xlim, DAE);
	else
		testc.df_dxlim = feval(DAE.df_dxlim, x, xlim, u, DAE);
	end
	if update
		fprintf(1, 'running df_dxlim=df_dxlim(x, xlim, u):\n\t');
		testc.df_dxlim
	else
		if ~random && is_equal(testc.df_dxlim, refc.df_dxlim) || ...
		   random  && ~is_nan(testc.df_dxlim)
			print_success('df_dxlim');
		else
			print_failure('df_dxlim');
			x, xlim
			if 1 == DAE.f_takes_inputs
			u
			end
		end
	end

	%===========================================================
	% run df_du 
	if 1 == DAE.f_takes_inputs
		testc.df_du = feval(DAE.df_du, x, xlim, u, DAE);
		if update
			fprintf(1, 'running df_du=df_du(x, xlim, u):\n\t');
			testc.df_du
		else
			if ~random && is_equal(testc.df_du, refc.df_du) || ...
			   random  && ~is_nan(testc.df_du)
				print_success('df_du');
			else
				print_failure('df_du');
				x, xlim
				if 1 == DAE.f_takes_inputs
				u
				end
			end
		end % if update
	end

	%===========================================================
	% run q
	testc.q_of_x = feval(DAE.q, x, xlim, DAE);
	if update
		fprintf(1, 'running q_of_x=q(x, xlim, u):\n\t');
		testc.q_of_x
	else
		if ~random && is_equal(testc.q_of_x, refc.q_of_x) || ...
		   random  && ~is_nan(testc.q_of_x)
			print_success('q');
		else
			print_failure('q');
			x, xlim
		end
	end % if update

	%===========================================================
	% run dq_dx
	testc.dq_dx = feval(DAE.dq_dx, x, xlim, DAE);
	if update
		fprintf(1, 'running dq_dx=dq_dx(x, xlim, u):\n\t');
		testc.dq_dx
	else
		if ~random && is_equal(testc.dq_dx, refc.dq_dx) || ...
		   random  && ~is_nan(testc.dq_dx)
			print_success('dq_dx');
		else
			print_failure('dq_dx');
			x, xlim
		end
	end % if update

	%===========================================================
	% run dq_dxlim
	testc.dq_dxlim = feval(DAE.dq_dxlim, x, xlim, DAE);
	if update
		fprintf(1, 'running dq_dxlim=dq_dxlim(x, xlim, u):\n\t');
		testc.dq_dxlim
	else
		if ~random && is_equal(testc.dq_dxlim, refc.dq_dxlim) || ...
		   random  && ~is_nan(testc.dq_dxlim)
			print_success('dq_dxlim');
		else
			print_failure('dq_dxlim');
			x, xlim
		end
	end % if update

	%===========================================================
	% run NRlimiting
	testc.NRlimiting_of_x = feval(DAE.NRlimiting, x, xlimOld, u, DAE);
	if update
		fprintf(1, 'running NRlimiting=NRlimiting(x, xlimOld, u):\n\t');
		testc.NRlimiting_of_x
	else
		if ~random && is_equal(testc.NRlimiting_of_x, refc.NRlimiting_of_x) || ...
		   random  && ~is_nan(testc.NRlimiting_of_x)
			print_success('NRlimiting');
		else
			print_failure('NRlimiting');
			x, u
		end
	end % if update

	%===========================================================
	% run dNRlimiting_dx
	testc.dNRlimiting_dx = feval(DAE.dNRlimiting_dx, x, xlimOld, u, DAE);
	if update
		fprintf(1, 'running dNRlimiting_dx=dNRlimiting_dx(x, xlimOld, u):\n\t');
		testc.dNRlimiting_dx
	else
		if ~random && is_equal(testc.dNRlimiting_dx, refc.dNRlimiting_dx) || ...
		   random  && ~is_nan(testc.dNRlimiting_dx)
			print_success('dNRlimiting_dx');
		else
			print_failure('dNRlimiting_dx');
			x, u
		end
	end % if update

	if ~random
		test.dtests{c} = testc;
	end
end % for c

fprintf(1, '--------------------------------------------\n');

if update
	ref = test;
	save(filename, 'ref');
end
	
end % function

function print_success(name)
	blanks = repmat(' ', 1, abs(30-length(name)));
	fprintf(1, 'testing %s...%s pass \n', name, blanks);
end % print_success

function print_failure(name, test_results, reference_results)
	blanks = repmat(' ', 1, 30-length(name));
	fprintf(1, 'testing %s...%s_fail_\n', name, blanks);
	if nargin ==  3
		% fprintf(1, 'testing results \n');
		test_results
		% fprintf(1, 'reference results \n');
		reference_results
	elseif nargin ==  2
		fprintf(1, 'testing results \n');
		test_results
	end
end % print_failure

function out = is_nan(a)
% check whether a contains NaN entry
% inputs can be scalars, vectors or matrices
index = isnan(a);
out = ~(0== nnz(index));
end % is_nan

function out = is_equal(a, b)
% compares whether two inputs are equal to each other
% inputs can be strings, scalars, vectors or matrices
%
abstol = 1e-14;
reltol = 1e-6;
%
classa = class(a);
classb = class(b);
%
if ~strcmp(classa, classb)
	out = 0;
	return; 
end % if class
%
if strcmp('char', classa)
	out = strcmp(a, b);
elseif strcmp('cell', classa)
	index = [];
	for c = 1:length({a{1:end}})
		index(c) = 1 - is_equal(a{c}, b{c});
	end
	out = 0== nnz(index);
else
	% out = isequal(a, b);
	if size(a, 1) == size(b, 1) && ...
	   size(a, 2) == size(b, 2)
		index = [];
		index = abs(a - b) > reltol * max(abs(a),abs(b)) + abstol;
		out = 0== nnz(index);
	elseif 0 == size(a, 1) * size(a, 2) && ...
	       0 == size(b, 1) * size(b, 2) 
		% when a=[], b=sparse([]), a is 0-by-0, b is 1-by-0
		% a-b will return error. But actually a==b
		out = 1;
	else
		out = 0;
	end
end % if class is char

end % is_equal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

