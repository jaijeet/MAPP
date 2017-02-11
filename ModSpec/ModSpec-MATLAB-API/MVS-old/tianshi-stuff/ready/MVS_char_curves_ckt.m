function cktnetlist = MVS_char_curves_ckt()
    MVS_Model = MVS_ModSpec();

	% ckt name
	cktnetlist.cktname = 'MVS MOS model: characteristic-curves';

	% nodes (names)
	cktnetlist.nodenames = {'drain', 'gate'};
	cktnetlist.groundnodename = 'gnd';

	% vddElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'drain', 'gnd'});

	% vggElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vgg', {'gate', 'gnd'});

	% mosElem

	%{
	optim_params_45=dlmread('coeff_op_final_45nm.txt');

	%% UNCOMMENT appropriate file from the following two lines
	%optim_params = optim_params_32; % change to optim_params_45 for 45 nm
	optim_params = optim_params_45; % change to optim_params_45 for 45 nm

	Rs0=optim_params(1);     % *** Access resistance for terminal "x" [ohm-micron] (Typically Rs)  
	Rd0=optim_params(1);     % *** Access resistance for terminal "y" (Typically assume Rs=Rd)
	delta=optim_params(3);   % *** DIBL [V/V] 
	n0 = optim_params(4);    % *** subthreshold swing factor [unit-less]
	nd=optim_params(5);      % *** Factor allowing for modest punchthrough.  
							 % *** Normally, nd=0.  If some punchtrhough 0<nd<0.4

	vxo = optim_params(6);   % *** Virtual source velocity [cm/s]    
	mu = optim_params(7);    % *** Mobility [cm^2/V.s]
	Vt0 = optim_params(8);   % Threshold voltage [V]

	%'version'    'Type'    'W'    'Lgdr'    'dLg'    'Cg'    'etov'    'delta'
 	%'n0'    'Rs0'    'Rd0' 'Cif'    'Cof'    'vxo'    'Mu'    'Beta'    'Tjun'
 	%'phib'    'Gamma'    'Vt0'    'Alpha'    'mc' 'CTM_select'    'CC'    'nd'

	cktnetlist = add_element(cktnetlist, MVS_Model, 'NMOS', {'drain', 'gate', 'gnd', 'gnd'}, ...
	{{'Rs0', Rs0}, ...
	{'Rd0', Rd0}, ...
	{'delta', delta}, ...
	{'n0', n0}, ...
	{'nd', nd}, ...
	{'vxo', vxo}, ...
	{'Mu', mu}, ...
	{'Vt0', Vt0}});
	%}
	cktnetlist = add_element(cktnetlist, MVS_Model, 'NMOS', {'drain', 'gate', 'gnd', 'gnd'});
end
