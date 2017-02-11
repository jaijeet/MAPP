function test = ModSpec_wrapper_CMOSinverter_tran()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_CMOSInverter_ModSpec_wrapper.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE

    DAE = CMOSInverter_CktEqns();
    xinit = zeros(DAE.nunks(DAE),1);
 

    test.DAE = DAE;
    test.name = 'ModSpec_wrapper_CMOSinverter_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'ModSpec_wrapper_CMOSinverter_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = xinit;



    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 1e-11;        % Time step
    test.args.tstop = 4e-9;         % Stop time
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms; % Transient simulation
    test.args.tranparms.NRparms.limiting = 1; 
    test.args.tranparms.doStepControl = 1;
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test.args.LMSMethod = 'GEAR2'; % {'BE','FE','TRAP','GEAR2'}
    % Update or testing/comparison
    % test.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end


function CktEqns = CMOSInverter_CktEqns()
    
    vdd = 2.5;

    ckt.cktname = 'CMOSInverter_Ckt';

    ckt.nodenames = {'dd', 'in', 'out'};
    ckt.groundnodename = 'gnd';

    ckt = add_element (ckt, DSAwareSHMOSWithParasitics_ModSpec_wrapper(), 'M1', {'out', 'in', 'dd'}, {{'Type', 'P'}});
    ckt = add_element (ckt, DSAwareSHMOSWithParasitics_ModSpec_wrapper(), 'M2', {'out', 'in', 'gnd'}, {{'Type', 'N'}});

    ckt = add_element (ckt, vsrc_ModSpec_wrapper(), 'vdd', {'dd', 'gnd'}, {}, {{'E', {'DC', vdd}}});
    vin_tranfunc = @(t, args) (bitsequence(t, args));
    vin_tranargs.low = 0;
    vin_tranargs.high = vdd;
    vin_tranargs.T = 1e-9;
    vin_tranargs.trf = 0.05e-9;
    vin_tranargs.bits = [1, 0, 1, 0];
    ckt = add_element (ckt, vsrc_ModSpec_wrapper(), 'vin', {'in', 'gnd'}, {}, {{'E', {'TRAN', vin_tranfunc, vin_tranargs}}});

    ckt = add_element (ckt, capacitor_ModSpec_wrapper(), 'C1', {'out', 'gnd'}, 5e-14);
    CktEqns = MNA_EqnEngine (ckt);

end

function bout = bitsequence (t, args)
    ts = t;
	bout = [];
	for i=1:length(ts)
		t = ts(i);
    	if isfield(args, 'tstart')
    	    tstart = args.tstart;
    	else
    	    tstart = 0;
    	end

    	num_periods_over = floor(t/args.T);
    	time_left = t - num_periods_over * args.T;

    	if num_periods_over >= size(args.bits, 2)
    	    out = ite(args.bits(1,end), args.low, args.high);
			bout = [bout, out];
    	    continue;
    	elseif num_periods_over == 0
    	    out = ite(args.bits(1,1), args.low, args.high);
			bout = [bout, out];
    	    continue;
    	end

    	if time_left < args.trf
    	    v1 = ite(args.bits(1,num_periods_over), args.low, args.high);
    	    v2 = ite(args.bits(1,num_periods_over+1), args.low, args.high);
    	    out = v1 + (v2 - v1)*(time_left/args.trf);
    	else
    	    out = ite(args.bits(1,num_periods_over+1), args.low, args.high);
    	end 
		bout = [bout, out];
	end

end

function out = ite (bit, low, high)
    out = bit*high + (1-bit)*low;
end

