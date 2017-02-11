%cktnetlist data structure fields:
%
% .name:      a name for the circuit
%
% .nodenames: list of non-ground node names. Eg, {'n1', 'n2', '3'}
%
% .groundnodename: name of the ground node. Eg., 'gnd'
%
% .elements:  cell array of element structures {el1, el2, ...}. 
%             Each eli has the following fields:
%
%             .name:  string (name). Eg, 'vsrc1'
%
%             .model: a ModSpec model structure. Eg, vsrcModSpec()
%
%             .nodes: list of node names the element is connected to, in the
%                     order defined by the ModSpec model. Eg, {'n1', 'n2'}
%
%             .parms: ? cell array of parameter values in the same order
%                     as the parameter names returned by the model's 
%                     parmnames() function.
%
%             .udata: cell array {udata1, udata2, ...} of data for the
%                     element's u sources.  Each udatai has the following
%                     fields:
%
%                     .uname:   name of the u source. Eg, 'E' (for a voltage
%                               source), 'I' (for a current source)
%
%                     .QSSval: DC value of u source. Eg, 1.0
%
%                     .utransient: handle of a function ut(t, args) that
%                                  returns a scalar double number. Eg.,
%                                  .utransient = @(t, args) ...
%                                                args.A*sin(2*pi*args.f*t);
%                     .utransientargs: args argument for utransient.
%                                      will typically contain information
%                                      needed to evaluate utransient.
%                     .uLTISSS: handle of a function uf(f, args) that
%                               returns a scalar complex number. Eg.,
%                               .uLTISSS = @(f, args) (1+1i)/sqrt(2).
%                     .uLTISSSargs: the args argument for uLTISSS
%
%             ---------------------------------------------------------------
%             additional fields set up and used internally by MNA_EqnEngine
%             ---------------------------------------------------------------
%             .node_voltage_indices_into_x
%             .refnode_index_into_x
%             .refnodeKCL_index_into_fq
%             .v_otherIO_nodeindices_into_x
%             .i_otherIO_indices_into_x
%             .i_otherIO_KCL_index_into_fq
%             .intunk_indices_into_x
%             .limitedvar_indices_into_xlim
%             .u_indices_into_cktu
%             .i_ExplicitOutput_KCLindices_into_fq
%             .v_ExplicitOutput_KVLindices_into_fq 
%             .ImplicitEqn_indices_into_fq
%             .A_X
%             .A_Xlim
%             .A_Y
%             .A_U
%             .A_Zi
%             .A_Zv
%             .A_Zve
%             .A_W
%
% .outputs:   a cell array {output1, output2, ...}. Each outputi is a cell
%             array with two or three entries: 
%
%                 {oname scale op1 [op2]}
%
%                 - oname is the name of the output. Eg, 
%                   'differential output'
%
%                 - scale should be a real number; it scales the output.
%
%                 - op1 (and the optional op2) are cell arrays of the form
%
%                      { vori, name }, where
%
%                   - vori = 'e' (node voltage) or 'i' (branch current)
%
%                   - name identifies a node or element
%
%                     - if vori='e', then name is the name (from .nodenames)
%                       or .groundnodename of the node whose voltage is the output.
%
%                     - if vori='i', then name is the name of the element 
%                       whose branch current is the output.
%
%                   The output is defined as scale*op1.  If op2 is specified,
%                   the output is scale*(op1-op2).
%
%                 Note: use add_output or add_outputs to set up .outputs.
%                       They translate names of nodes/elements into the
%                       indices above and do some sanity checking.
%
%                 Note: cktnetlist.outputs is used by MNA_EqnEngine and
%                       STA_EqnEngine[TODO] to set up the DAE's system
%                       outputs, ie, its C() and outputnames(). These
%                       outputs are shown by various analyses' print() and
%                       plot() methods.
%                       
%                 Note: only 2-terminal elements are supported for specifying
%                       branch current outputs. If using MNA_EqnEngine, only
%                       elements that are not voltage controlled (ie, the
%                       branch current is not an explicit output) are
%                       supported. The equation engine should issue a warning
%                       and drop outputs that are not supported.
