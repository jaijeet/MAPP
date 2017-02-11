function DAE = DAEAPI_common_skeleton()
%function DAE = DAEAPI_common_skeleton()
%This is a virtual base class for DAEAPI.
% it defines member/data functions adhering to the official API,
%(using DAEAPI_skeleton_core) and augments it with
%data members (and redefines functions using them)
%that are commonly used (from DAEAPI_input_add_ons and
%DAEAPI_common_add_ons).
%
%This (or a similar virtual base class) should be called
%first thing in the constructor of every DAEAPI object,
%prior to specializing the functions/data to the specific
%DAEAPI being defined.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	DAE = DAEAPI_skeleton_core;
	DAE = DAEAPI_input_add_ons(DAE);
	DAE = DAEAPI_common_add_ons(DAE);
	DAE = DAEAPI_derivative_add_ons(DAE);
end
% end DAEAPI_common_skeleton constructor
