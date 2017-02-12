%DAEAPI wrapper is a high-level wrapper that MAPP provides on top of its
%low-level DAE API (help DAEAPI). This wrapper makes it convenient to define a
%DAE using three functions (init_DAE, add_to_DAE and finish_DAE) with a
%simple calling syntax. To learn more, please see the help for these
%functions (particularly add_to_DAE). Please also see the DAEAPI documentation
%to understand the DAE object the wrapper commands produce.
%
%The flow of writing a DAE using DAEAPI wrapper is:
%
%1. Start with
%	    DAE = init_DAE();
%2. Then put in several
%	    DAE = add_to_DAE(DAE, 'field_name', field_value);
%   statements to augment the skeleton structure.
%3. Finally, end with
%	    DAE = end_DAE(DAE);
%
%help add_to_DAE for more information and examples.  
%
%See also
%--------
%  
%  init_DAE, add_to_DAE, finish_DAE, DAEAPI, MAPPdaes, ModSpec_wrapper.
%
