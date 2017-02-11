function DAE = MNAEqnEngine_SH_NMOS_w_caps()
    cktname = 'SH-NMOS-with-caps';
    ckt_nodes = {'DR', 'D', 'G'}; % drain and gate of the NMOS
    ground = 'S'; % source node of the NMOS

    NMOS_Element.name = 'SH_NMOS';
    NMOS_Element.model = ShichmanHodgesNMOSModel('myNMOS');
    NMOS_Element.nodes = {'DR', 'G', ground}; % D, G and S 
    NMOS_Element.parms = {1e-4, 0.3};

    R_Element.name = 'resistor';
    R_Element.model = resModSpec('R');
    R_Element.nodes = {'DR', 'D'};
    R_Element.parms = {1e6};

    C1_Element.name = 'Cdg';
    C1_Element.model = capModSpec('Cdg');
    C1_Element.nodes = {'DR', 'G'}; 
    C1_Element.parms = {0}; 

    C2_Element.name = 'Cds';
    C2_Element.model = capModSpec('Cds');
    C2_Element.nodes = {'DR', ground}; 
    C2_Element.parms = {5e-16}; 

    C3_Element.name = 'Cgs';
    C3_Element.model = capModSpec('Cgs');
    C3_Element.nodes = {'DR', ground};
    C3_Element.parms = {0}; %1e-15}; 

    v1_Element.name = 'Vd'; 
    v1_Element.model = vsrcModSpec('vsrc'); 
    v1_Element.nodes = {'D', ground}; v1_Element.parms = {};

    v2_Element.name = 'Vg'; v2_Element.model = vsrcModSpec('vsrc'); 
    v2_Element.nodes = {'G', ground}; v2_Element.parms = {};

    circuitdata.cktname = cktname; 
    circuitdata.nodenames = ckt_nodes; 
    circuitdata.groundnodename = ground;
    circuitdata.elements = {v1_Element, v2_Element, C1_Element, C2_Element, C3_Element, R_Element, NMOS_Element}; 
    DAE = MNA_EqnEngine('NMOS', circuitdata);
end

