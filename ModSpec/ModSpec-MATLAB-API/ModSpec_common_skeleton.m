function MOD = ModSpec_common_skeleton()
%function MOD = ModSpec_common_skeleton()
%This function sets up ModSpec default skeleton, common add-ons and derivative
%add-ons.
%INPUT args: (none)
%
%OUTPUT:
%   MOD         - ModSpec object with default skeleton, common add-ons and
%                 derivative add-ons.

%author: J. Roychowdhury.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	MOD = ModSpec_skeleton_core(); % no dependence on any NIL
	MOD = ModSpec_common_add_ons(MOD); % no dependence on any NIL
	MOD = ModSpec_derivative_add_ons(MOD); % no dependence on any NIL
	MOD = attach_ee_NIL(MOD); % ee NIL added
end %ModSpec_common_skeleton
