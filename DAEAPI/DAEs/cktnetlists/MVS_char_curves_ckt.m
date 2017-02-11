function cktnetlist = MVS_char_curves_ckt()
%function cktnetlist = MVS_char_curves_ckt()
% This function returns a cktnetlist structure for a circuit that drives
% an MVS NMOS with default parameters to generate characteristic curves.
% 
%The circuit
%    An N-type MOS (MVS model) driven by Vgg and Vdd voltage sources
%    to generate characteristic curves.
%
%To see the schematic of this circuit, run:
%
% showimage('MVS_char_curves.jpg');
%
%Examples
%--------
%
% % set up DAE
% DAE = MNA_EqnEngine( MVS_char_curves_ckt);
% 
% % DC analysis
% dcop = dot_op(DAE);
% dcop.print(dcop);
% qssSol = dcop.getSolution(dcop);
% 
% % double DC sweep using a for loop
% VGBs = 0:0.1:1;
% VDBs = -0.5:0.1:1.5;
% IDs = zeros(length(VGBs), length(VDBs));
%
% % list all circuit unknowns
% DAE.unknames(DAE)
%
% % find out Id's index (current through vsrc) in solution vector %
% idx = unkidx_DAEAPI('Vdd:::ipn', DAE)
% 
% % run DC sweep in a for loop
% for c = 1:length(VGBs)
%     DAE = DAE.set_uQSS('Vgg:::E', VGBs(c), DAE);
%     swp = dcsweep(DAE, [], 'Vdd:::E', VDBs);
%     [pts, Sols] = swp.getsolution(swp);
%     IDs(c, :) = - Sols(idx, :);
% end % Vgg
%
% % plot characteristic curves
% figure; hold on; xlabel('Vdb'); ylabel('Idb');
% title 'MVS NMOS characteristic curves';
% i = 0; legends = {};
% for c = 1:length(VGBs)
%     col = getcolorfromindex(gca(), c); marker = getmarkerfromindex(c);
%     plot(VDBs, IDs(c,:), sprintf('%s-', marker), 'Color', col);
%     legends{c} = sprintf('VGB=%0.2g', VGBs(c));
% end
% legend(legends, 'Location', 'SouthEast'); grid on; box on; 
% 
% % 3-D plot
% figure; surf(VDBs, VGBs, IDs);
% xlabel('Vdb'); ylabel('Vgb'); zlabel('Idb');
% 
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts
%

    % MVS_Model = MVS_1_0_1_ModSpec();
    MVS_Model = MVS_1_0_1_ModSpec_vv4();

    % ckt name
    cktnetlist.cktname = 'MVS MOS model: characteristic-curves';

    % nodes (names)
    cktnetlist.nodenames = {'drain', 'gate'};
    cktnetlist.groundnodename = 'gnd';

    % vddElem
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd',...
        {'drain', 'gnd'}, {}, {{'DC', 1}});

    % vggElem
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vgg', {'gate', 'gnd'});

    % mosElem
    cktnetlist = add_element(cktnetlist, MVS_Model, 'NMOS',...
        {'drain', 'gate', 'gnd', 'gnd'});
end
