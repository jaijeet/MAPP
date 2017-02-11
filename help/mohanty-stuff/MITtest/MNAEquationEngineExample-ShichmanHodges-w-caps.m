%This help file shows you how to build a DAEAPI-based circuit DAE using MNA
%equation engine. 
%
%In this example, we will define a MATLAB function that returns an object (DAE)
%that conforms to the DAEAPI format and captures the underlying DAE of a
%circuit which consists of an NMOS, three capacitors (capacitance between drain
%and source (Cds), capacitance between drain and gate (Cdg) and capacitance
%between gate and source (Cgs)), and two voltage sources (drain voltage (Vd)
%and gate voltage (Vg)): 
%
%function DAE = MNAEqnEngine_SH_NMOS_w_caps()
%
%Give your circuit a name. To do that, create a variable and store the circuit
%name string in it. For example, let us call our circuit
%'mySH_NMOS_circuit_w_capacitors' and store it in a variable called 'cktname'.
%
%    cktname = 'mySH_NMOS_circuit_w_capacitors';
%
%The circuit has two nodes (call them 'D' and 'G') and one ground (reference
%node, call it 'S'). Define the nodes of the circuit as follows.
%
%    ckt_nodes = {'D', 'G'};
%    ground = 'S'; 
%
%The drain, gate and source node of the NMOS are connected to 'D' , 'G' and
%'S', respectively. The underlying ModSpec model behind the NMOS device can be
%invoked by making a call to the MATLAB function in the file
%'ShichmanHodgesNMOSModel()'. We would also like to change the default values
%of the model parameters. All the above requirements are captured by defining a
%MATLAB structure as follow:
%
%    NMOS_Element.name = 'SH_NMOS';
%    NMOS_Element.model = ShichmanHodgesNMOSModel('myNMOS');
%    NMOS_Element.nodes = {'D', 'G', ground}; 
%    NMOS_Element.parms = {1e-9, 0.3};
%
%Similarly let us define the capacitors by making a call to function
%'capModSpec' and appropriately assigning the nodes and parameters to them.
%
%    C1_Element.name = 'Cdg';
%    C1_Element.model = capModSpec('Cdg');
%    C1_Element.nodes = {'D', 'G'}; 
%    C1_Element.parms = {1e-22}; 
%
%    C2_Element.name = 'Cds';
%    C2_Element.model = capModSpec('Cds');
%    C2_Element.nodes = {'D', ground}; 
%    C2_Element.parms = {1e-22}; 
%
%    C3_Element.name = 'Cgs';
%    C3_Element.model = capModSpec('Cgs');
%    C3_Element.nodes = {'D', ground};
%    C3_Element.parms = {1e-22}; 
%
%Similarly let us define the voltage sources by making a call to function
%'vsrcModSpec'.
%
%    v1_Element.name = 'Vd'; 
%    v1_Element.model = vsrcModSpec('vsrc'); 
%    v1_Element.nodes = {'D', ground}; v1_Element.parms = {};
%
%    v2_Element.name = 'Vg'; v2_Element.model = vsrcModSpec('vsrc'); 
%    v2_Element.nodes = {'G', ground}; v2_Element.parms = {};
%
%Now finally we put everything together and create a data structure
%(circuitdata) to store all the necessary information about the circuits as
%follows:
%
%    circuitdata.cktname = cktname; 
%    circuitdata.nodenames = ckt_nodes; 
%    circuitdata.groundnodename = ground;
%    circuitdata.elements = {v1_Element, v2_Element, C1_Element, C2_Element, C3_Element,NMOS_Element};
%
%Finally we create the circuit DAE by passing the circuitdata structure to the
%MNA equation engine defined in the MATLAB function 'MNAEqnEngine()'.
%
%    DAE = MNA_EqnEngine('NMOS', circuitdata);
%end
%
%Now putting everything together, we have the following:
%
%function DAE = MNAEqnEngine_SH_NMOS_w_caps()
%    cktname = 'SH-NMOS-with-caps';
%    ckt_nodes = {'D', 'G'}; 
%    ground = 'S'; % source node of the NMOS
%
%    NMOS_Element.name = 'SH_NMOS';
%    NMOS_Element.model = ShichmanHodgesNMOSModel('myNMOS');
%    NMOS_Element.nodes = {'D', 'G', ground}; % D, G and S 
%    NMOS_Element.parms = {1e-9, 0.3};
%
%    C1_Element.name = 'Cdg';
%    C1_Element.model = capModSpec('Cdg');
%    C1_Element.nodes = {'D', 'G'}; 
%    C1_Element.parms = {1e-22}; 
%
%    C2_Element.name = 'Cds';
%    C2_Element.model = capModSpec('Cds');
%    C2_Element.nodes = {'D', ground}; 
%    C2_Element.parms = {1e-22}; 
%
%    C3_Element.name = 'Cgs';
%    C3_Element.model = capModSpec('Cgs');
%    C3_Element.nodes = {'D', ground};
%    C3_Element.parms = {1e-22}; 
%
%    v1_Element.name = 'Vd'; 
%    v1_Element.model = vsrcModSpec('vsrc'); 
%    v1_Element.nodes = {'D', ground}; v1_Element.parms = {};
%
%    v2_Element.name = 'Vg'; v2_Element.model = vsrcModSpec('vsrc'); 
%    v2_Element.nodes = {'G', ground}; v2_Element.parms = {};
%
%    circuitdata.cktname = cktname; 
%    circuitdata.nodenames = ckt_nodes; 
%    circuitdata.groundnodename = ground;
%    circuitdata.elements = {v1_Element, v2_Element, C1_Element, C2_Element, C3_Element, NMOS_Element};
%
%    DAE = MNA_EqnEngine('NMOS', circuitdata);
%end
