function out = finish_ee_model (MOD)
%function out = finish_ee_model (MOD)
%
% This function gets an EE model ready for use (for example, in a circuit data
% structure). It takes an EE model as input, performs a number of checks on it,
% defines essential fields if they are not already defined, and returns the
% resulting model as output.
%
%See also
%--------
%
%  add_to_ee_model, ee_model, diode_ModSpec_wrapper
%
%Author: Karthik V Aadithya, 2013/11

% Changelog
% ---------
%2016/10/14: JR <jr@berkeley.edu>: updates to support {f,q}{e,i}_xy[u]
%2014/06/26: Tianshi Wang, <tianshi@berkeley.edu>: modified default fe/qe/fi/qi
%          from zeros to fe/qe/fi/qi_from_fqei when fqei_of_S is present in MOD
%2014/02/09: Tianshi Wang, <tianshi@berkeley.edu>: added vecLim in fqei
%2013/11: Karthik V Aadithya, <aadithya@berkeley.edu>

    MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

    num_explicit_equations = length(MOD.explicit_output_names);
    num_implicit_equations = length(MOD.NIL.node_names) - 1 + length(MOD.internal_unk_names) - num_explicit_equations;

    if isfield (MOD, 'fqei_of_S') && strcmp(class(MOD.fqei_of_S), 'function_handle')
		% fqei is present in MOD
		if ~isfield (MOD, 'fe_of_S') || ~strcmp(class(MOD.fe_of_S), 'function_handle')
			MOD.fe = @fe_from_fqei;
		end

		if ~isfield (MOD, 'qe_of_S') || ~strcmp(class(MOD.qe_of_S), 'function_handle')
			MOD.qe = @qe_from_fqei;
		end

		if ~isfield (MOD, 'fi_of_S') || ~strcmp(class(MOD.fi_of_S), 'function_handle')
			MOD.fi = @fi_from_fqei;
		end

		if ~isfield (MOD, 'qi_of_S') || ~strcmp(class(MOD.qi_of_S), 'function_handle')
			MOD.qi = @qi_from_fqei;
		end
	else
		if (~isfield (MOD, 'fe_of_S') || ~strcmp(class(MOD.fe_of_S), 'function_handle')) && (~isfield (MOD, 'fe_xyu') || ~strcmp(class(MOD.fe_xyu), 'function_handle'))
			if 0 == num_explicit_equations
				MOD.fe = @(vecX, vecY, vecLim, vecU, MOD) ( [] );
			else
				MOD.fe = @(vecX, vecY, vecLim, vecU, MOD) ( zeros(num_explicit_equations, 1) );
			end
		end

		if (~isfield (MOD, 'qe_of_S') || ~strcmp(class(MOD.qe_of_S), 'function_handle')) && (~isfield (MOD, 'qe_xy') || ~strcmp(class(MOD.qe_xy), 'function_handle'))
			if 0 == num_explicit_equations
				MOD.qe = @(vecX, vecY, vecLim, MOD) ( [] );
			else
				MOD.qe = @(vecX, vecY, vecLim, MOD) ( zeros(num_explicit_equations, 1) );
			end
		end

		if (~isfield (MOD, 'fi_of_S') || ~strcmp(class(MOD.fi_of_S), 'function_handle')) && (~isfield (MOD, 'fi_xyu') || ~strcmp(class(MOD.fi_xyu), 'function_handle'))
			if 0 == num_implicit_equations
				MOD.fi = @(vecX, vecY, vecLim, vecU, MOD) ( [] );
			else
				MOD.fi = @(vecX, vecY, vecLim, vecU, MOD) ( zeros(num_implicit_equations, 1) );
			end
		end

		if (~isfield (MOD, 'qi_of_S') || ~strcmp(class(MOD.qi_of_S), 'function_handle')) && (~isfield (MOD, 'qi_xy') || ~strcmp(class(MOD.qi_xy), 'function_handle'))
			if 0 == num_implicit_equations
				MOD.qi = @(vecX, vecY, vecLim, MOD) ( [] );
			else
				MOD.qi = @(vecX, vecY, vecLim, MOD) ( zeros(num_implicit_equations, 1) );
			end
		end
	end
	
	if length(MOD.implicit_equation_names) == 0
		MOD.implicit_equation_names = {};
		for idx = 1:1:num_implicit_equations
			MOD.implicit_equation_names = [MOD.implicit_equation_names, ['implicit_equation_', num2str(idx)]];
		end
	end

    out = MOD;
end

function feout = fe_from_fqei(vecX, vecY, vecLim, vecU, MOD)
	if 4 == nargin
		MOD = vecU; vecU = vecLim;
		vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end
    flag.fe = 1; flag.qe = 0; flag.fi = 0; flag.qi = 0;
	[feout, qeout, fiout, qiout] = feval(MOD.fqei, vecX, vecY, vecLim, vecU, flag, MOD);
end

function qeout = qe_from_fqei(vecX, vecY, vecLim, MOD)
	if 3 == nargin
		MOD = vecLim;
		vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end
    flag.fe = 0; flag.qe = 1; flag.fi = 0; flag.qi = 0;
	vecU = [];
	[feout, qeout, fiout, qiout] = feval(MOD.fqei, vecX, vecY, vecLim, vecU, flag, MOD);
end

function fiout = fi_from_fqei(vecX, vecY, vecLim, vecU, MOD)
	if 4 == nargin
		MOD = vecU; vecU = vecLim;
		vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end
    flag.fe = 0; flag.qe = 0; flag.fi = 1; flag.qi = 0;
	[feout, qeout, fiout, qiout] = feval(MOD.fqei, vecX, vecY, vecLim, vecU, flag, MOD);
end

function qiout = qi_from_fqei(vecX, vecY, vecLim, MOD)
	if 3 == nargin
		MOD = vecLim;
		vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end
    flag.fe = 0; flag.qe = 0; flag.fi = 0; flag.qi = 1;
	vecU = [];
	[feout, qeout, fiout, qiout] = feval(MOD.fqei, vecX, vecY, vecLim, vecU, flag, MOD);
end
