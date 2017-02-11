%A ModSpec object is a MATLAB structure with several fields defined by ModSpec
%API to represent a device model in MAPP framework. The default fields of this
%structure contain various data members and function handles as mandated by
%ModSpec API. These fields can be set up by making a call to the function
%ModSpec_common_skeleton() as follows:
%
%               MOD = ModSpec_common_skeleton();
%
%The function ModSpec_common_skeleton() in turn makes a call to three
%functions: ModSpec_skeleton_core(), ModSpec_common_add_ons() and
%ModSpec_derivative_add_ons(). 
% 
%The following is the complete list of important data members and functions that
%are supported by ModSpec-API. 
%
% 1. MOD.version
%       - (string) model version number/identifier
%
% 2. MOD.Usage
%       - (character array) help text on the model.
% 3. MOD.name
%       - (string) short name for the device, e.g., 'MOS', 'diode'.
%
% 4. MOD.ModelName 
%       - (string) short name for the model, e.g., 'DAAV6', 'Shichmann-Hodges'.
%
% 5. MOD.SpiceKey
%       - (string) Spice key of the model, if available, e.g., 'M' for MOSFET
%
% 6. MOD.description              
%       - (string) brief description of the model
%
% 7. MOD.parmnames 
%       - (function handle) returns a cell array of of model parameter names.
%
% 8. MOD.pardefaults          
%       - (function handle) returns a cell array of _default_ parameter values
%
% 9. MOD.IOnames 
%       - (function handle) returns a cell array of strings with all IO names.
%         Its size should be 2n.
%
%10. MOD.ExplicitOutputNames
%       - (function handle) returns a cell array of strings with explicit output
%         names
%
%11. MOD.InternalUnkNames
%       - (function handle) returns a cell array of strings with internal
%         unknown names
%
%12. MOD.ImplicitEquationNames
%       - (function handle) returns a cell array of stringss with implicit
%         equation names 
%
%13. MOD.uNames 
%       - (function handle) returns a cell array of strings with u(t) names
%
%14. MOD.OtherIONames
%       - (function handle) returns a cell array of strings with other IO names
%15. MOD.nparms
%       - (function handle) returns a scalar equal to number of model
%         parameters
%
%16. MOD.fi
%       - (function handle) returns a column vector of doubles equal to fi of
%         the model DAE
%
%17. MOD.fe
%       - (function handle) returns a column vector of doubles equal to fe of
%         the model DAE
%
%18. MOD.qi
%       - (function handle) returns a column vector of doubles equal to qi of
%         the model DAE
%
%19. MOD.qe
%       - (function handle) returns a column vector of doubles equal to qe of
%         the model DAE
%
%20. MOD.NIL.NodeNames
%       - (function handle) returns a cell array of strings with names of the
%         device's nodes
%
%21. MOD.NIL.RefNodeName
%       - (function handle) returns a string with names of the device's
%         internal reference node, with respect to which branch voltages must
%         be calculated. This should be one of the NodeNames.
%
%22. MOD.NIL.IOnodeNames
%       - (function handle) returns a cell array of strings (corresponding to
%         IOnames) that list the node (from NodeNames) to which the IO (i.e.,
%         the branch voltage or branch current) corresponds. E.g., if the IO is
%         'vgb' or 'igb' (with 'b' being the reference node), then its
%         IOnodeName is 'g'.
%
%23. MOD.NIL.IOtypes
%       - (function handle) returns a cell array of strings 'v' or 'i', that
%         list the types ('v' or 'i') for the core device's IOs corresponding
%         to IOnames.
%
%The following fields are the data members of ModSpec API which are accessed by
%making a call to various function/methods members of ModSpec API. These data
%members should not be directly accessed.
%
%24. MOD.uniqID
%       - string containing an identifier for the model
%
%25. MOD.model_name
%       - string containing an identifier for the model
%
%26. MOD.spice_key
%       - string containing an identifier for the model
%
%27. MOD.model_description
%       - string containing an identifier for the model
%
%28. MOD.parm_names
%       - cell array of strings containing model parameter names
%
%29. MOD.parm_defaultvals
%       - cell array of strings/doubles/integer, etc. containing model _default_
%         parameter values
%
%30. MOD.parm_vals
%       - cell array of strings/doubles containing model parameter values
%
%31. MOD.parm_types
%       - cell array of strings containing types of all parameter values (e.g.,
%         'double', 'int', 'string') 
%
%32. MOD.explicit_output_names
%       - cell array of strings containing explicit output names 
%
%33. MOD.internal_unk_names
%       - cell array of strings containing internal unknown names
%
%34. MOD.implicit_equation_names
%       - cell array of strings containing implicit equation names 
%
%35. MOD.u_names
%       - cell array of strings containing u names
%
%36. MOD.NIL.node_names
%       - cell array of strings containing NIL node names
%
%37. MOD.NIL.refnode_name
%       - string containing NIL node name
%
%38. MOD.NIL.IO_names
%       - cell array of strings containing IO names 
%
%40. MOD.NIL.OtherIO_names
%       - cell array of strings containing other IO names 
%
%41. MOD.NIL.io_types
%       - cell array of strings denoting IO types ('v' or 'i')
%
%42. MOD.NIL.io_nodenames
%       - cell array of strings denoting IO node names
%
