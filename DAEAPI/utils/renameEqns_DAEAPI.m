function DAE = renameEqns_DAEAPI(DAE, rename_from, rename_to)
%function DAE = renameEqns_DAEAPI(DAE, rename_from, rename_to)
%This function calls rename_names_DAEAPI function to rename the DAE equation
%names of an input DAE.
%INPUT args:
%   DAE                 - DAE object
%   rename_from         - the list of equation names to be changed (cell array)
%   rename_to           - the list of new equation names (cell array)
%OUTPUT:
%   DAE                 - DAE with updated equation names
%See rename_names_DAEAPI for more info.

	DAE.eqnnameList = rename_names_DAEAPI(DAE.eqnnameList, rename_from, rename_to);
% end renameEqns
