function out = finish_DAE(DAE, skipfqzeroevals)
%function out = finish_DAE(DAE, skipfqzeroevals)
%
% Used to complete the definition of a DAE using DAEAPI wrapper (ie, started
% with init_DAE() and populated with add_to_DAE()). help add_to_DAE for
% details.
%
% The second argument skipfqzeroevals is optional, with default 0. If set to
% 1, DAE f/q function evaluations  with all zero arguments (used for checking)
% are skipped. This is useful if these functions blow up at zero, as in simple
% EM/gravitational models.
%
%See also
%--------
%
%init_DAE, add_to_DAE, check_DAE, DAEAPI_wrapper, DAEAPI, MAPPdaes.
%

% JR, 2017/02/09 - documentation.
% JR, 2016/10/03 - added skipfqzeroevals argument (useful for Argon atom system, which blows up with zero arguments)
% Author: Bichen Wu <bichen@berkeley.edu> 2014/02/03
	
	num_unk = feval(DAE.nunks, DAE);
	num_limitedvar = feval(DAE.nlimitedvars, DAE);
	num_eqn = feval(DAE.neqns, DAE);
	num_input = feval(DAE.ninputs, DAE);
	num_output = feval(DAE.noutputs, DAE);
	f_takes_inputs = DAE.f_takes_inputs;

	test_X = zeros(num_unk,1);
	test_Xlim = zeros(num_limitedvar,1);
	test_U = zeros(num_input,1);

	if num_unk ~= num_eqn
        error(['ERROR in finish_DAE(): number of unkowns isn''t equal to number of equations ']);
	end

	if num_output == 0
		DAE = add_to_DAE(DAE, 'outputname(s)', DAE.unknameList);
		num_output = feval(DAE.noutputs, DAE);
	end
	
	if f_takes_inputs ~= 1 && f_takes_inputs ~= 0
        error(['ERROR in finish_DAE(): Please define .f_takes_inputs correctly']);
	end

    dontskipfq = (nargin < 2) || (nargin > 1 && skipfqzeroevals ~= 0);

    if dontskipfq && (~isfield (DAE, 'f') | ~strcmp(class(DAE.f), 'function_handle'))  && (~isfield (DAE, 'fq') | ~strcmp(class(DAE.fq), 'function_handle'))
		if f_takes_inputs == 1
        	DAE.f = @(X, XLim, U, DAE) ( zeros(num_eqn, 1) );
		elseif f_takes_inputs == 0
        	DAE.f = @(X, XLim, DAE) ( zeros(num_eqn, 1) );
		end
	else
		if f_takes_inputs == 1
			fout = feval(DAE.f, test_X, test_Xlim, test_U, DAE);
		elseif f_takes_inputs == 0
			fout = feval(DAE.f, test_X, test_Xlim, DAE);
		end
		
		if size(fout,1) ~= num_eqn
        	error(['ERROR in finish_DAE(): number of equations doesn''t match with dimension of .f']);
		end
    end

    if dontskipfq && (~isfield (DAE, 'q') | ~strcmp(class(DAE.q), 'function_handle'))  && (~isfield (DAE, 'fq') | ~strcmp(class(DAE.fq), 'function_handle'))
        DAE.q = @(X, XLim, DAE) ( zeros(num_eqn, 1) );
	else
		qout = feval(DAE.q, test_X, test_Xlim, DAE);

		if size(qout,1) ~= num_eqn
        	error(['ERROR in finish_DAE(): number of equations doesn''t match with dimension of .q']);
		end
    end

	if f_takes_inputs == 0
		if (~isfield (DAE, 'B') | ~strcmp(class(DAE.B), 'function_handle')) | isempty(DAE.B(DAE))
    	    DAE.B = @(DAEarg) ( sparse(num_eqn, num_input) );
		else
			Bee = DAE.B(DAE);
			[m n] = size(Bee);
			if m ~= num_eqn
        		error(['ERROR in finish_DAE(): number of equations doesn''t match with dimension of .B']);
			end
			if n ~= num_input
        		error(['ERROR in finish_DAE(): number of inputs doesn''t match with dimension of .B']);
			end
    	end
	end

	if ~isfield (DAE, 'C') | ~strcmp(class(DAE.C), 'function_handle') | isempty(DAE.C(DAE))
		unknames = DAE.unknameList;
		outputnames = DAE.outputnameList;
		for i=1:length(outputnames)
			idx = find(strcmp(outputnames{i}, unknames));
			if isempty(idx)
	    		error(['ERROR in finish_DAE(): ', outputnames{i}, ' not found in unkown name list.']);
			end
			idx = find(strcmp(outputnames{i}, unknames));
		end
        DAE.C = @C_builder;
	else
		Cee = DAE.C(DAE);
		[m n] = size(Cee);
		if m ~= num_output
    		error(['ERROR in finish_DAE(): number of outputs doesn''t match with dimension of .C']);
		end
		if n ~= num_unk
    		error(['ERROR in finish_DAE(): number of unkowns doesn''t match with dimension of .C']);
		end
    end

	if ~isfield (DAE, 'D') | ~strcmp(class(DAE.D), 'function_handle') | isempty(DAE.D(DAE))
        DAE.D = @(DAEarg) ( sparse(num_output,num_input));
	else
		Dee = DAE.D(DAE);
		[m n] = size(Dee);
		if m ~= num_output
    		error(['ERROR in finish_DAE(): number of outputs doesn''t match with dimension of .D']);
		end
		if n ~= num_input
    		error(['ERROR in finish_DAE(): number of inputs doesn''t match with dimension of .D']);
		end
    end
	out = DAE;
end

function out = C_builder(DAE)
	num_unk = feval(DAE.nunks, DAE);
	num_output = feval(DAE.noutputs, DAE);

	unknames = DAE.unknameList;
	outputnames = DAE.outputnameList;

	Cee = sparse(num_output, num_unk);
	for i=1:length(outputnames)
		idx = find(strcmp(outputnames{i}, unknames));
		Cee(i,idx) = 1;
	end
	out = Cee;
end
