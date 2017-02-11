function out = add_to_ee_model (MOD, field_name, field_value)
%function out = add_to_ee_model (MOD, field_name, field_value)
%
% This function can be used to augment the skeleton model returned by
% ee_model().
% For example, you can say add_to_ee_model(MOD, 'terminals', {'p', 'n'}) to add 
% two terminals 'p' and 'n' to a ModSpec model. Similarly, you can add
% parameters, internal unknowns, explicit and implicit functions fi, fe, qi,
% and qe, and internal voltage/current sources to your model -- all by just
% calling this function multiple times.
%
% Available field_names (case insensitive) and field_values:
%
% 1. names:
%
%    modelname or name
%      - string (name of the model)
%    description or desc
%      - string (short description of the model)
%    external_nodes or terminals:
%      - cell array of strings
%    internal_unks:
%      - cell array of strings
%    implicit_eqn_names:
%      - cell array of strings
%    explicit_outs:
%      - cell array of strings
%    parm, parms, param or params:
%      - cell array of strings
%        - e.g. add_to_ee_model(MOD, 'parms', {'a', 1.0, 'b', 0.1});
%    internal_srcs or u_names: variables that should be set up outside of the device,
%        - e.g. 'E' in a voltage source
%      - cell array of strings
%
% 2. functions:
%
%    fe or f:
%      - function handle (v2struct arg), returns a col vector with the size of explicit_outs
%    fe_xyu:
%      - function handle (arg are x, y, u and MOD), returns a col vector with the size of explicit_outs
%    qe or q:
%      - function handle (v2struct arg), returns a col vector with the size of explicit_outs
%    qe_xy:
%      - function handle (arg are x, y and MOD), returns a col vector with the size of explicit_outs
%    fi:
%      - function handle (v2struct arg), returns a col vector with the size n-m+l
%          n -> num of terminals
%          m -> num of explicit outputs,
%          l -> num of internal unks
%    fi_xyu:
%      - function handle (args are x, y, u and MOD), returns a col vector with the size n-m+l
%    qi (v2struct arg):
%      - function handle, returns col vector with size n-m+l
%    qi_xy:
%      - function handle (args are x, y and MOD), returns a col vector with the size n-m+l
%    fqei (v2struct arg):
%      - cell array of 4 function handles, fe, qe, fi, qi
%    fqi (v2struct arg):
%      - cell array of 2 function handles, fi, qi
%    fqe or fq (v2struct arg):
%      - cell array of 2 function handles, fe, qe
%	 fqei_all (v2struct arg):
%	   - function handle, returns values of fe, qe, fi, qi all together
%
% 3. init/limiting related fields: 
%
%    limited_vars, limited_var_names, limited_var or limited_var_name:
%      - cell array of strings
%    limited_var_matrix, limited_matrix, vecXY_to_limitedvars_matrix or
%        vecXY_to_limitedvars:
%      - matrix
%      - limited variables = this matrix * [otherIOs; internal_unks]
%        otherIOs are IO properties except explicit outputs
%    limiting:
%      - function handle, returns a col vector with the size of limited_vars
%    init or initguess:
%      - function handle, returns a col vector with the size of limited_vars
% 
%See also
%--------
%
%  ee_model, finish_ee_model, diode_ModSpec_wrapper
%

%Author: Karthik V Aadithya, 2013/11
    
% Changelog
% ---------
%2016/10/14: JR <jr@berkeley.edu>: added {f,q}{e,i}_xy[u] functions
%2016/10/13: JR <jr@berkeley.edu>: added u_names synonym for internal_srcs
%2014/05/21: Bichen Wu, <bichen@berkeley.edu>: added fqei_all
%2014/02/18: Tianshi Wang, <tianshi@berkeley.edu>: added documentation
%2014/02/09: Tianshi Wang, <tianshi@berkeley.edu>: added limited_vars field and vecLim in fqei
%2013/11: Karthik V Aadithya, <aadithya@berkeley.edu>

	field_name = lower(field_name);

    if strcmp (field_name, 'external_nodes') || strcmp (field_name, 'terminals')
        
        MOD.NIL.node_names = [MOD.NIL.node_names, field_value];
        MOD.NIL.refnode_name = field_value{end};

    elseif strcmp (field_name, 'internal_unks')

        MOD.internal_unk_names = [MOD.internal_unk_names, field_value];

    elseif strcmp (field_name, 'implicit_eqn_names') || strcmp (field_name, 'implicit_equation_names')

        MOD.implicit_equation_names = [MOD.implicit_equation_names, field_value];

    elseif strcmp (field_name, 'explicit_outs')

        MOD.explicit_output_names = [MOD.explicit_output_names, field_value];

    elseif strcmp (field_name, 'limited_vars') || strcmp (field_name, 'limited_var_names') ...
        || strcmp (field_name, 'limited_var') || strcmp (field_name, 'limited_var_name')

		MOD.limited_var_names = [MOD.limited_var_names, field_value];

    elseif strcmp (field_name, 'limited_var_matrix') || strcmp (field_name, 'limited_matrix') ...
        || strcmp (field_name, 'vecXY_to_limitedvars_matrix') || strcmp (field_name, 'vecXY_to_limitedvars') 

		MOD.vecXY_to_limitedvars_matrix = field_value;

    elseif strcmp (field_name, 'parms') || strcmp (field_name, 'parm') || ...
            strcmp (field_name, 'params') || strcmp (field_name, 'param')

        if 1 == mod(length(field_value), 2)
            error('Odd number of inputs for specifying parameter name/default value pairs.');
        end
        for idx = 1 : 1 : (length(field_value)/2)

            MOD.parm_names{end+1} = field_value{2*idx-1};
            MOD.parm_defaultvals{end+1} = field_value{2*idx};
            MOD.parm_vals{end+1} = field_value{2*idx};

        end

    elseif strcmp (field_name, 'internal_srcs') || strcmp (field_name, 'u_names')

        MOD.u_names = [MOD.u_names, field_value];

    elseif strcmp (field_name, 'fi')

        MOD.fi_of_S = field_value;
        MOD.fi = @MOD_fi;

    elseif strcmp (field_name, 'fi_xyu')

        MOD.fi_xyu = field_value;
        MOD.fi = @MOD_fi_xyu;

    elseif strcmp (field_name, 'fe') | strcmp (field_name, 'f')

        MOD.fe_of_S = field_value;
        MOD.fe = @MOD_fe;

    elseif strcmp (field_name, 'fe_xyu')

        MOD.fe_xyu = field_value;
        MOD.fe = @MOD_fe_xyu;

    elseif strcmp (field_name, 'qi')

        MOD.qi_of_S = field_value;
        MOD.qi = @MOD_qi;

    elseif strcmp (field_name, 'qi_xy')

        MOD.qi_xy = field_value;
        MOD.qi = @MOD_qi_xy;

    elseif strcmp (field_name, 'qe') | strcmp (field_name, 'q')

        MOD.qe_of_S = field_value;
        MOD.qe = @MOD_qe;

    elseif strcmp (field_name, 'qe_xy')

        MOD.qe_xy = field_value;
        MOD.qe = @MOD_qe_xy;

    elseif strcmp (field_name, 'fqei')

        MOD.fe_of_S = field_value{1};
        MOD.fe = @MOD_fe;

        MOD.qe_of_S = field_value{2};
        MOD.qe = @MOD_qe;

        MOD.fi_of_S = field_value{3};
        MOD.fi = @MOD_fi;

        MOD.qi_of_S = field_value{4};
        MOD.qi = @MOD_qi;

	elseif strcmp (field_name, 'fqei_all')
		MOD.fqei_of_S = field_value;
		MOD.fqei = @MOD_fqei;
		MOD.fqeiJ = @MOD_fqeiJ;

    elseif strcmp (field_name, 'fqi')

        MOD.fi_of_S = field_value{1};
        MOD.fi = @MOD_fi;

        MOD.qi_of_S = field_value{2};
        MOD.qi = @MOD_qi;

    elseif strcmp (field_name, 'fqe') | strcmp (field_name, 'fq')

        MOD.fe_of_S = field_value{1};
        MOD.fe = @MOD_fe;

        MOD.qe_of_S = field_value{2};
        MOD.qe = @MOD_qe;

    elseif strcmp (field_name, 'limiting')

        MOD.limiting = @(vecX, vecY, vecLimOld, vecU, MOD) ( feval ( field_value, ee_model_fstruct (vecX, vecY, vecLimOld, vecU, MOD) ) );
        MOD.limiting_of_S = field_value;

    elseif strcmp (field_name, 'init') | strcmp (field_name, 'initguess')

        MOD.initGuess = @(vecU, MOD) (feval ( field_value, ee_model_ustruct (vecU, MOD) ) );

    elseif strcmp(field_name, 'modelname') | strcmp(field_name, 'name')

        MOD.model_name = field_value;

    elseif strcmp(field_name, 'description') | strcmp(field_name, 'desc')

        MOD.model_description = field_value;

    else

        disp (['ERROR in add_to_ee_model(): Unrecognized field ', field_name]);

    end

    out = MOD;

end

function out = MOD_fe(vecX, vecY, vecLim, vecU, MOD)
	if 4 == nargin
		MOD = vecU; vecU = vecLim;
		vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end
	out = feval(MOD.fe_of_S, ee_model_fstruct(vecX, vecY, vecLim, vecU, MOD));
end % MOD_fe

function out = MOD_fe_xyu(vecX, vecY, vecLim, vecU, MOD)
    % ignores vecLim; does not use limitedvars
	if 4 == nargin
		MOD = vecU; vecU = vecLim;
		%vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end
	out = feval(MOD.fe_xyu, vecX, vecY, vecU, MOD);
end % MOD_fe_xyu

function out = MOD_fi(vecX, vecY, vecLim, vecU, MOD)
	if 4 == nargin
		MOD = vecU; vecU = vecLim;
		vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end
	out = feval(MOD.fi_of_S, ee_model_fstruct(vecX, vecY, vecLim, vecU, MOD));
end % MOD_fi

function out = MOD_fi_xyu(vecX, vecY, vecLim, vecU, MOD)
    % ignores vecLim; does not use limitedvars
	if 4 == nargin
		MOD = vecU; vecU = vecLim;
		%vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end
	out = feval(MOD.fi_xyu, vecX, vecY, vecU, MOD);
end % MOD_fi_xyu

function out = MOD_qe(vecX, vecY, vecLim, MOD)
	if 3 == nargin
		MOD = vecLim;
		vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end
	out = feval(MOD.qe_of_S, ee_model_qstruct(vecX, vecY, vecLim, MOD));
end % MOD_qe

function out = MOD_qe_xy(vecX, vecY, vecLim, MOD)
    % ignores vecLim; does not use limitedvars
	if 3 == nargin
		MOD = vecLim;
		% vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end
	out = feval(MOD.qe_xy, vecX, vecY, MOD);
end % MOD_qe_xy

function out = MOD_qi(vecX, vecY, vecLim, MOD)
	if 3 == nargin
		MOD = vecLim;
		vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end
	out = feval(MOD.qi_of_S, ee_model_qstruct(vecX, vecY, vecLim, MOD));
end % MOD_qi

function out = MOD_qi_xy(vecX, vecY, vecLim, MOD)
    % ignores vecLim; does not use limitedvars
	if 3 == nargin
		MOD = vecLim;
		%vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end
	out = feval(MOD.qi_xy, vecX, vecY, MOD);
end % MOD_qi_xy

function [fe, qe, fi, qi] = MOD_fqei(vecX, vecY, vecLim, vecU, flag, MOD)
	if 5 == nargin
		MOD = flag; flag = vecU; vecU = vecLim;
		vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end
	[fe, qe, fi, qi] = feval(MOD.fqei_of_S, ee_model_fqei_struct(vecX, vecY, vecLim, vecU, flag, MOD));
end % MOD_fqei

function [fqei, J] = MOD_fqeiJ(vecX, vecY, vecLim, vecU, flag, MOD)
	if 5 == nargin
		MOD = flag; flag = vecU; vecU = vecLim;
		vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end
	if flag.J == 0
		[fqei.fe, fqei.qe, fqei.fi, fqei.qi] = MOD_fqei(vecX, vecY, vecLim, vecU, flag, MOD);
		J = [];
	else
		[fqei J] = dfqei_dvecXYLimU_auto(vecX, vecY, vecLim, vecU, MOD);
	end
end % MOD_fqeiJ
