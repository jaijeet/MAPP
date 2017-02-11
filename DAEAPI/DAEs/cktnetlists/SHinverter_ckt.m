function cktnetlist = SHinverter_ckt()
%function cktnetlist = SHinverter_ckt()
%This function returns a cktnetlist structure for an inverter made of Shichman
%Hodges MOS devices.
%
%The circuit
%   An CMOS inverter made of N-type and P-type Shichman Hodges MOS devices.
%
%To see the schematic of this circuit, run:
%
% showimage('SHinverter.jpg');
%
%Examples
%--------
%
% % set up DAE
% DAE = MNA_EqnEngine(SHinverter_ckt);
%
% % DC sweep
% swp = dcsweep(DAE, [], 'Vin:::E', 0:5/60:5);
% % feval(swp.plot, swp); % this will plot all DAE states
%
% % get DC sweep solutions and plot Vout-Vin curve
% [Vins, sols] = swp.getSolution(swp);
% outidx = DAE.unkidx('e_out', DAE);
% plot(Vins, sols(outidx, :), '-r.', 'LineWidth', 2);
% xlabel('Vin'); ylabel('Vout'); title('DC sweep results of SH inverter');
% grid on; box on;
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts,
% dcsweep
%

%
% Author: Tianshi Wang, 2013/09/29


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % ckt name
    cktnetlist.cktname = 'Shichman-Hodges MOS inverter';

    % nodes (names)
    cktnetlist.nodenames = {'vdd', 'in', 'out'};
    cktnetlist.groundnodename = 'gnd';

    VddDC = 5;
    VinDC = 1;
    CL = 1e-6;

    % vddElem
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, {{'E',...
    {'DC', VddDC}}});

    % vinElem
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin', {'in', 'gnd'}, {}, {{'E',...
    {'DC', VinDC}}});

    % nmosElem
    cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'NMOS', {'out', 'in', 'gnd'}, ...
    {{'Beta', 1.8e-3}, {'VT', 0.3}}, {});

    % pmosElem
    cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'PMOS', {'out', 'in', 'vdd'}, ...
    {{'Type', 'P'}, {'Beta', 1.8e-3}, {'VT', 0.3}}, {});

    % clElem
    cktnetlist = add_element(cktnetlist, capModSpec(), 'CL', {'out', 'gnd'}, ...
    {{'C', CL}}, {});

    cktnetlist = add_output(cktnetlist, 'out');
    cktnetlist = add_output(cktnetlist, 'i(Vdd)', 1000);

end

