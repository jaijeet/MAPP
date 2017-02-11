%In MAPP, device models (i.e., mathematical models for the core components that
%make up circuits and systems) are specified using an API called ModSpec. In this
%API, a device is viewed as something that has inputs and outputs (or more
%generally, I/O ports). The ModSpec API gives you a structured way to specify the
%relationships between the signals (e.g., voltages and currents) at these I/O
%ports. For details, type 'help MAPPdevicemodels'.
%
%Now we'll tell you how to quickly create a ModSpec model.
%
%A ModSpec object is a MATLAB structure with several fields defined by ModSpec
%API to represent a device model in the MAPP framework. The default fields of
%this structure contain various data members and function handles as mandated
%by ModSpec API. These fields with their default values can be set up by making
%a call to the function ModSpec_common_skeleton() as follows:
%
%               MOD = ModSpec_common_skeleton();
%
%The above command sets up a ModSpec object named 'MOD' with appropriate fields
%in the MATLAB workspace. The function ModSpec_common_skeleton() makes a call
%to three other functions: ModSpec_skeleton_core(), ModSpec_common_add_ons()
%and ModSpec_derivative_add_ons(). See help topics on those three functions to
%learn more about the fields that are set up by them. Alternatively, you can
%type 'help ModSpec-API' to find out all the data members and function handles
%supported by ModSpec (and set up by ModSpec_common_skeleton()).
%
%To learn about the concept of a device in the MAPP framework and familiarize
%with some of the device modeling related terminologies, please type 'help
%MAPPDeviceConcepts' at the MATLAB command line.
% 
%The following is a partial list of important data members and functions that
%need to be defined while creating a new ModSpec model.
%
% 1. MOD.version                     - (string) model version number/identifier 
%       EXAMPLE: MOD.version = 'DAAV_0_1_23';
%
% 2. MOD.uniqID                      - (string) model identification
%                                      This string is optionally passed to the
%                                      model.
%       EXAMPLE:
%           if nargin < 1
%               MOD.uniqID = '';
%           else
%               MOD.uniqID = uniqID;
%           end
%
% 3. MOD.model_name                 - (string) model name
%       EXAMPLE: MOD.model_name = 'resistor';
%   
% 4. MOD.spice_key                  - (string) spice key
%       EXAMPLE: MOD.spice_key = 'R';
%   
% 5. MOD.model_description          - (string) model description
%       EXAMPLE: MOD.model_description = 'basic linear resistor';
%   
% 6. MOD.parm_names                 - (cell array of strings) parameter names
%       EXAMPLE: MOD.parm_names = {'R'};
%   
% 7. MOD.parm_defaultvals           - (cell array) parameter _default_ values 
%       EXAMPLE: MOD.parm_defaultvals = {'1e3'};
%   
% 8. MOD.parm_types                 - (cell array) parameter types
%                                     This could be any legitimate MATLAB
%                                     variable type, e.g., 'double', 'int',
%                                     'string', etc.
%       EXAMPLE: MOD.parm_types = {'double'};
%   
% 9. MOD.parm_vals                  - (cell array) parameter values 
%                                     It could be initialized to default
%                                     parameter values.
%       EXAMPLE: MOD.parm_vals = MOD.parm_defaultvals;
%   
%10. MOD.explicit_output_names      - (cell array of string) explicit output
%                                     names
%       EXAMPLE: MOD.explicit_output_names = {'ipn'}; 
%   
%11. MOD.internal_unk_names         - (cell array of string) internal unknown 
%                                     names
%       EXAMPLE: MOD.internal_unk_names = {};
%   
%12. MOD.implicit_equation_names    - (cell array of string) implicit equation
%                                     names
%       EXAMPLE: MOD.internal_unk_names = {};
%   
%13. MOD.u_names                    - (cell array of string) u names
%       EXAMPLE: MOD.u_names = {};
%   
%14. MOD.NIL.nodenames              - (cell array of string) NIL node names
%       EXAMPLE: MOD.NIL.nodenames = {'p', 'n'};
%   
%15. MOD.NIL.refnode_name           - (string) NIL reference node
%       EXAMPLE: MOD.NIL.refnode_name = 'n';
%
%16. MOD.fi                         - (function handle) returns a _column_
%                                     vector of doubles equal to fi of the
%                                     model DAE
%       EXAMPLE: MOD.fi = @fi;
%
%17. MOD.fe                         - (function handle) returns a _column_
%                                     vector of doubles equal to fe of the
%                                     model DAE
%       EXAMPLE: MOD.fe = @fe;
%
%18. MOD.qi                         - (function handle) returns a _column_
%                                     vector of doubles equal to qi of the
%                                     model DAE
%       EXAMPLE: MOD.qi = @qi;
%
%19. MOD.qe                         - (function handle) returns a _column_
%                                     vector of doubles equal to qe of the
%                                     model DAE
%       EXAMPLE: MOD.qe = @qe;
%
%19. MOD.initGuess                  - (function handle) returns a _column_
%                                     vector of doubles (size 1 x no. of
%                                     unknowns) of the model DAE. This function
%                                     is useful for Newton-Raphson
%                                     initialization support.
%
%19. MOD.limiting                  - (function handle) returns a _column_
%                                     vector of doubles (size 1 x no. of
%                                     unknowns) of the model DAE. This function
%                                     is useful for Newton-Raphson limiting
%                                     support.
%
%--------------------------------------------------------------
%HOW TO CREATE A NEW ModSpec DEVICE MODEL IN THE MAPP FRAMEWORK:
%--------------------------------------------------------------
%
%The easiest way To specify a device model in ModSpec is to call
%Modspec_common_skeleton() and modify the object returned by this function.
%
%
%EXAMPLE 1: Shichmann-Hodges Model
%In this example, we will create a ModSpec object representing a MOSFET using
%simple Shichmann-Hodges model.
%
%
%       
%                           | PMOS                                | NMOS 
%                || s       |                                     |
%         g      |+---------|                          || d       |
%       +-------O|+---------+                          |+---------+
%                |+---------+                 +--------|+----------+ 
%                || d       |                   g      |+---------+|
%                           |                          ||  s       |
%                           |                                      | 
%- The Model
%   - Shichmann-Hodges (SH) model is a simple three terminal
%       - s: source, d:drain, and g: gate (Node names)
%               - So we will have NIL.NodeNames = {'s', 'd', 'g'}
%       - g: reference node     (a choice made by modeler)
%               - So we will have NIL.RefNodeName = 'g'
%       - 2 branch voltages (Vgs, Vds)
%       - 2 branch currents (Ig, Id)
%               - So we will have 
%                       - NIL.IOnames = {'vsg', 'vdg', 'isg', 'ids'}
%                       - NIL.IOtypes = {'v', 'v', 'i', 'i'}
%                       - NIL.IOnodeNames = {'s', 'd', 's', 'd'}
%               - NOTE: NIL.IOnames is auto-generated, the modeler does not
%                 need to specify it.
%   - SH model expresses Ig and Id in terms of Vgs and Vds. It also depends on
%     three parameters: beta, Vth and type of MOSFET
%   - So, for SH model
%       - n = 2
%       - No. of IOs = 2n = 4 (two branch currents and two branch voltages)
%   - Because we can explicitly express Id and Is as function of Vds and Vgs,
%     two explicit outputs, i.e., l = 2.
%       - So we have NIL.ExplicitOutputNames = {'isg', 'idg'};
%   - This model does not have any internal unknowns or u. 
%       - So we have NIL.InternalUnkNames ={};
%                    NIL.ImplicitEquationNames ={};
%                    NIL.uNames ={};
%                                  
%- Writing the code
%Let us first create a MATLAB file 'ModSpecExample1_ShichmannHodeges.m' and
%open the file to edit it. The first line of the file will be the MATLAB
%function definition.
%
% 1:    function MOD = ModSpecExample1_ShichmannHodeges(uniqID)
%
%Essentially, the function accepts an optional string argument and returns a
%ModSpec object 'MOD'. The input string 'uniqID' uniquely will uniquely
%define the object instance in MATLAB workspace.
%
% 2:        MOD = ModSpec_common_skeleton();
%
%Above line sets up default fields of 'MOD' structure with some default
%values.  Next, we will create two fields manually: 'version' and 'Usage'. The
%first field will hold information about the ModSpec object version and the
%second one will contain the help message about the object.
%
% 3:        MOD.version = 'ShichmannHodges-ver-0.0.1';
% 4:        MOD.Usage = help('ModSpecExample1_ShichmannHodges');
%
%Now, let us add the provision to handle the cases where the function is called
%without a uniqID string.
%
% 5:        if nargin < 1
% 6:            MOD.uniqID = '';
% 7:        else
% 8:            MOD.uniqID = uniqID;
% 9:        end
%
%Next, let us define the following three fields: model_name, spice_key, and
%model_description.
%
% 10:       MOD.model_name = 'Shichmann Hodges';
% 11:       MOD.spice_key = 'M'; 
% 12:       MOD.model_description = 'A simple SH model for MOSFET';
%
%Next, define the parameter names of the SH model.
%
% 13:       MOD.parm_names = {...
% 14:                           bet,    % beta 
% 15:                           V_th,   % Vth
% 16:                           tipe,   % Type of MOSFET: 'N', 'P'
% 17:                        };
%
%In next few lines we will define the default values of the model parameters
%and their type. We will also set the parameter values to be equal to their
%default values.
%
% 18:       MOD.parm_defaultvals = {...
% 19:                               1e-5,   % beta
% 20:                               0.25,   % Vth (volt)
% 21:                               'N',    % Type of MOSFET
% 22:                              };
% 23:       MOD.parm_types ={ ...
% 24:                         'double', % beta
% 25:                         'double', % V_th 
% 25:                         'char',   % Type of MOSFET
% 26:                       }
%
%Next, we will define the fields for the explicit output names, internal
%unknown names, implicit unknown names, u names, NIL node names and NIL
%reference node name.
%
% 27:       MOD.explicit_output_names = {'ice', 'ibe'};
% 28:       MOD.internal_unk_names = {};
% 29:       MOD.implicit_equation_names = {};
% 30:       MOD.u_names = {};
% 31:       MOD.NIL.node_names = {'c', 'b', 'e'};
% 32:       MOD.NIL.refnode_name = 'e';
%
%For defining IO names, other IO names, NIL IO types and NIL IO node names, we
%will make a call to the function
%'setup_IOnames_OtherIOnames_IOtypes_IOnodenames'.
%
% 33        MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);
%
%The core functions to compute fi, fe, qi and qe are defined as follows:
%
% 34:       MOD.fi = @fi; % fi(vecX, vecY, vecU, MOD)
% 35:       MOD.fe = @fe; % fe(vecX, vecY, vecU, MOD)
% 36:       MOD.qi = @qi; % qi(vecX, vecY, MOD)
% 37:       MOD.qe = @qe; % qe(vecX, vecY, MOD)
% 38:   end
%
%In the above, we created a standard fields of an ModSpeb object. Next, we need
%to write functions to compute fi, fe, qi and qe. We will define one local
%function which computes all the four quantities and will call that function with
%appropriate arguments depending upon what we want to compute. Let us first
%write this function. We will call this function 'fqei'.
%
% 39:   function fqout = fqei(vecX, vecY, u, MOD, forq, eroi)
%
%The input arguments and output of the function will be as below:
%INPUT args:
%       vecX            - 1 x 1 vector
%       vecY            - empty vector (e.g., [])
%       u               - scalar
%       MOD             - ModSpec model object
%       forq            - string (allowable values: 'f', 'q')
%       eori            - string (allowable values: 'e', 'i')
%
%OUPUT:
%       fqout           - if forq == 'f' and eori == 'i'
%                               fi function output of the ModSpec object
%                         if forq == 'f' and eori == 'e'
%                               fe function output of the ModSpec object
%                         if forq == 'q' and eori == 'i'
%                               qi function output of the ModSpec object
%                         if forq == 'q' and eori == 'e'
%                               qe function output of the ModSpec object
%
%Before we implement the above functionality, we first want to define scalar
%variables for parms, vecX, vecY and u for ease of coding.
%
% 39:       pnames = feval(MOD.parmnames,MOD);
% 40:       for i = 1:length(pnames)
% 41:           evalstr = sprintf('%s = MOD.parm_vals{i};', pnames{i});
% 42:           eval(evalstr);
% 43:       end
%
%The code in Lines [39-43] will set up MATLAB variables: 'bet', 'V_th', and
%'tipe'. Now we will set up scalar variables for vecX.
%
% 44:       oios = feval(MOD.OtherIONames,MOD);
% 45:       for i = 1:length(oios)
% 46:           evalstr = sprintf('%s = vecX(i);', oios{i});
% 47:           eval(evalstr); 
% 48:       end
%
%The code in Lines [39-43] will set up MATLAB variables: 'bet', 'V_th', and
%'tipe'. Now we will set up scalar variables for vecY.
%
% 49:       iunks = feval(MOD.InternalUnkNames,MOD);
% 50:       for i = 1:length(iunks)
% 51:           evalstr = sprintf('%s = vecY(i);', iunks{i});
% 52:           eval(evalstr); 
% 53:       end
%
%Now, we are finally ready to code up fi, fe, qi and qe as follows:
% 54:       if 1 == strcmp(eori,'e') % e
% 55:           if 1 == strcmp(forq, 'f') % f
% 56:               fqout(1,1) = vpn/R;
% 57:           else % q
% 58:               fqout(1,1) = 0;
% 59:           end
% 60:       else % i
% 61:           if 1 == strcmp(forq, 'f') % f
% 62:               fqout = [];
% 63:           else % q
% 64:               fqout = [];
% 65:           end
% 66:       end
% 67:   end 
%
%Now we see that by making a call to function fqei() with appropriate we can
%compute fi, fe, qi, and qe. Let us define the functions fi, fe, qi, and qe to
%do that.
%
% 68:   function fiout = fi(vecX, vecY, u, MOD)
% 69:       fiout = fqei(vecX, vecY, u, MOD, 'f', 'i');
% 70:   end 
%
% 71:   function feout = fe(vecX, vecY, u, MOD)
% 72:       feout = fqei(vecX, vecY, u, MOD, 'f', 'e');
% 73:   end 
%
% 74:   function qiout = qi(vecX, vecY, u, MOD)
% 75:       qiout = fqei(vecX, vecY, u, MOD, 'q', 'i');
% 76:   end 
%
% 77:   function qeout = qe(vecX, vecY, u, MOD)
% 78:       qeout = fqei(vecX, vecY, u, MOD, 'q', 'e');
% 79:   end 

	
