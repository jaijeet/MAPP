function MOD = ee_model()
%function MOD = ee_model()
%
% This function creates and returns a basic MATLAB model of an electronic
% component in MAPP. This basic model is just a skeleton structure, and to
% define a real model, the user is expected to augment this skeleton structure
% by repeatedly calling add_to_ee_model().
%
%See also
%--------
%
%  add_to_ee_model, finish_ee_model, diode_ModSpec_wrapper
%
%

%Author: Karthik V Aadithya, 2013/11

% Changelog
% ---------
%2014/02/09: Tianshi Wang, <tianshi@berkeley.edu>: added limited_var_names field
%2013/11: Karthik V Aadithya, <aadithya@berkeley.edu>

    MOD = ModSpec_common_skeleton();

    MOD.parm_names = {};
    MOD.parm_defaultvals = {};
    MOD.parm_vals = {};
    MOD.parm_types = {};
    MOD.explicit_output_names = {};
    MOD.internal_unk_names = {};
    MOD.implicit_equation_names = {};
    MOD.u_names = {};
    MOD.IO_names = {};
    MOD.OtherIO_names = {};
    MOD.NIL.node_names = {};
    MOD.NIL.refnode_name = '';
    MOD.NIL.io_types = {};
    MOD.NIL.io_nodenames = {};
    MOD.limited_var_names = {};
    MOD.vecXY_to_limitedvars_matrix = [];

	MOD.support_initlimiting = 1;

end
