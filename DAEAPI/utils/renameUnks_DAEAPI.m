function DAE = renameUnks_DAEAPI(DAE, rename_from, rename_to)
%function DAE = renameUnks_DAEAPI(DAE, rename_from, rename_to)
%This function calls rename_names_DAEAPI function to rename the DAE unknown
%names of an input DAE.
%INPUT args:
%   DAE                 - DAE object
%   rename_from         - the list of unknown names to be changed (cell array)
%   rename_to           - the list of new unknown names (cell array)
%OUTPUT:
%   DAE                 - DAE with updated unknown names
%See rename_names_DAEAPI for more info.

	DAE.unknameList = rename_names_DAEAPI(DAE.unknameList, rename_from, rename_to);
% end renameUnks
