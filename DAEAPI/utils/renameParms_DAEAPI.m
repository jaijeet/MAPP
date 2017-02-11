function DAE = renameParms_DAEAPI(DAE, rename_from, rename_to)
%function DAE = renameParms_DAEAPI(DAE, rename_from, rename_to)
%This function calls rename_names_DAEAPI function to rename the DAE parm names
%of an input DAE.
%INPUT args:
%   DAE                 - DAE object
%   rename_from         - the list of parameter names to be changed (cell array)
%   rename_to           - the list of new parameter names (cell array)
%OUTPUT:
%   DAE                 - DAE with updated parameter names
%See rename_names_DAEAPI for more info.

	DAE.parmnameList = rename_names_DAEAPI(DAE.parmnameList, rename_from, rename_to);
% end renameParms
