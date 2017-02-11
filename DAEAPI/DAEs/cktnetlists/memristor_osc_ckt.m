function ckt = memristor_osc_ckt()
%function ckt = memristor_osc_ckt()
% This function returns a cktnetlist structure for an oscillator made with a
% unipolar memristor device.
% 
%The circuit
%    A unipolar memristor device (between node 2 and ground) connected in
%    series with a resistor (between 1 and 2) and a voltage source (between 1
%    and ground); a capacitor is connected in parallel with the memristor
%    (between 1 and ground).
%
%    DC value of the voltage source is 1V.
%
%Examples
%--------
%
% % set up DAE
% DAE = MNA_EqnEngine(memristor_osc_ckt);
% 
% % DC OP analysis
% dcop = dot_op(DAE, [0;0;0;0.5]);
% dcop.print(dcop); dcSol = dcop.getSolution(dcop);
% 
% % transient simulation
% tstart = 0; tstep = 1e-4; tstop = 5e-2;
% xinit = [0; 0; 0; 1];
% LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
% LMSobj.plot(LMSobj);
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts
%
    memristor = memristorModSpec(2, 5);
    ckt.cktname = 'Memristor Relaxation Oscillator Circuit';
    ckt.nodenames = {'1', '2'};
    ckt.groundnodename = 'gnd';
    tranfunc = @(t, args) 1;
    % tranargs.offset = 0; tranargs.A = 1; tranargs.T = 1e-2; tranargs.phi=0;
    ckt = add_element(ckt, vsrcModSpec(), 'Vin', ...
       {'1', 'gnd'}, {}, {{'DC', 1}, {'TRAN', tranfunc, []}});
    ckt = add_element(ckt, resModSpec(), 'R1', ...
       {'1', '2'}, {{'R', 625}});
    ckt = add_element(ckt, memristor, 'M1', {'2', 'gnd'}, {{'Vp', 0.8}, {'Vn', -0.2}});
    ckt = add_element(ckt, capModSpec, 'C1', {'2', 'gnd'}, {{'C', 1e-5}});
end % memristor_osc_ckt
