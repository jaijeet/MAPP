function DAE = init_DAE()
%function DAE = init_DAE()
%
%Initialize an empty DAE. Should be used to set up a DAE before calling 
%add_to-DAE() to populate it. help add_to_DAE provides examples.
%
%See also
%--------
%
%add_to_DAE, finish_DAE, check_DAE, DAEAPI_wrapper, DAEAPI, MAPPdaes.
%

% Author: Bichen Wu <bichen@berkeley.edu> 2014/02/03
	DAE = DAEAPI_common_skeleton();
	DAE.B = @(arg) [];
	DAE.C = @(arg) [];
	DAE.D = @(arg) [];
	DAE.support_initlimiting = 1;
    DAE.f_has_been_specified = 0;
    DAE.q_has_been_specified = 0;
end
