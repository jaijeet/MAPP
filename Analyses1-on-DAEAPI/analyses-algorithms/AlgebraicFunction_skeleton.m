function AFO = AlgebraicFunction_skeleton()
%function AFO = AlgebraicFunction_skeleton()
% This function is used to set up common skeletons of algebraic function
% objects. For more information about algebraic function objects:
% >> help AlgebraicFunction
%
%See also
%--------
% AlgebraicFunction
%
	AFO = AlgebraicFunction_skeleton_core();
	AFO = AlgebraicFunction_add_ons(AFO);
end

function AFO = AlgebraicFunction_skeleton_core()
    AFO.DAE = 'undefined';
    AFO.do_limit = 'undefined';
    AFO.do_init = 'undefined';

    AFO.nunks = 'undefined';
    AFO.neqns = 'undefined';
    AFO.f_df_rhs = 'undefined';
    AFO.f_and_df = 'undefined';
    AFO.f = 'undefined';
    AFO.df = 'undefined';
    AFO.rhs = 'undefined';

    AFO.set_limit = 'undefined';
    AFO.set_init = 'undefined';
    AFO.set_xlimOld = 'undefined';
    AFO.get_limit = 'undefined';
    AFO.get_init = 'undefined';
    AFO.get_xlimOld = 'undefined';

    AFO.LMS_add_on = 'undefined';
    AFO.PreComputedStuff = 'undefined';
end

function AFO = AlgebraicFunction_add_ons(AFO)
    AFO.do_limit = 0;
    AFO.do_init = 0;
    AFO.xlimOld = [];

    AFO.nunks = @(inAFO) inAFO.n_unks;
    AFO.neqns = @(inAFO) inAFO.n_eqns;
    AFO.nlimitedvars = @(inAFO) inAFO.n_limitedvars;

    AFO.f = @AF_f;
    AFO.df = @AF_df;
    AFO.rhs = @AF_rhs;
    AFO.f_and_df = @AF_f_and_df;
    AFO.f_df_rhs = @AF_f_df_rhs;

    AFO.set_limit = @set_limit;
    AFO.set_init = @set_init;
    AFO.set_xlimOld = @set_xlimOld;
    AFO.get_limit = @(inAFO) inAFO.do_limit; 
    AFO.get_init = @(inAFO) inAFO.do_init; 
    AFO.get_xlimOld = @(inAFO) inAFO.xlimOld; 

    AFO.LMS_add_on = []; 
    AFO.PreComputedStuff = []; 
end

function AFO = set_limit(signal, inAFO)
    AFO = inAFO;
    AFO.do_limit = signal;
end

function AFO = set_init(signal, inAFO)
    AFO = inAFO;
    AFO.do_init = signal;
end

function AFO = set_xlimOld(xlimOld, inAFO)
    AFO = inAFO;
    AFO.xlimOld = xlimOld;
end

function [out_f, xlimOld, success] = AF_f(x, AFO)
    [out_f, out_df, out_rhs, xlimOld, success] = feval(AFO.f_df_rhs, x, AFO);
end

function [out_df, xlimOld, success] = AF_df(x, AFO)
    [out_f, out_df, out_rhs, xlimOld, success] = feval(AFO.f_df_rhs, x, AFO);
end

function [out_rhs, xlimOld, success] = AF_rhs(x, AFO)
    [out_f, out_df, out_rhs, xlimOld, success] = feval(AFO.f_df_rhs, x, AFO);
end

function [out_f, out_df, xlimOld, success] = AF_f_and_df(x, AFO)
    [out_f, out_df, out_rhs, xlimOld, success] = feval(AFO.f_df_rhs, x, AFO);
end

function [out_f, out_df, out_rhs, xlimOld, success] = AF_f_df_rhs(x, AFO)
    [out_f, xlimOld, success] = feval(AFO.f, x, AFO);
    [out_df, xlimOld, success] = feval(AFO.df, x, AFO);
    [out_rhs, xlimOld, success] = feval(AFO.rhs, x, AFO);
end
