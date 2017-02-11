function cktdata = diode_mixer_ckt()
%function cktdata = diode_mixer_ckt()
%This function returns a cktnetlist structure for a double balanced diode
%mixer.
%
%The circuit
%   This is a double balanced diode mixer feeding a load of a resistor and a
%   series capacitor.
%   - two inputs: 'Vlo:::E' and 'Vrf:::E'
%   - the output node is '8'
%
%To see the schematic of this circuit, run:
%
% showimage('diode_mixer.jpg'); [TODO]
%
%Examples
%--------
%
% % set up DAE %
% DAE =  MNA_EqnEngine(diode_mixer_ckt());
%
% % DC analysis %
% dcop = dot_op(DAE);
% % print DC operating point %
% feval(dcop.print, dcop);
% % get DC operating point solution vector %
% qssSol = feval(dcop.getsolution, dcop);
%
% % run transient and plot %
% tstart = 0; tstep = 5e-10; tstop = 5e-8;                     
% TransObj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
% feval(TransObj.plot, TransObj);
%
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI[TODO], DAE[TODO]
% dot_op, dot_transient 

% Author: Tianshi Wang, 2013/09/28
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Copyright (C) 2008-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights
%reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% ckt name
	cktdata.cktname = 'Double Balanced Diode Mixer with VCVS';
	% nodes (names)
	cktdata.nodenames = {'10', '1', '20', '4', '2', '3', '5', '6', '7', '8'};
	cktdata.groundnodename = '0';

	% circuit element values
	Rrf = 0.01;   % Rrf = 0.01ohm
	Ro  = 50;     % Ro  = 50ohm
	Cl  = 1e-10;  % Cl  = 100pF
	Rlo = 0.01;   % Rlo = 0.01ohm
	VrfDC =  -2;  % VrfDC = -2V
	VloDC = 2;    % VloDC = 2V
	% transient function of Vlo
	Vlofuncargs.f = 800e6; Vlofuncargs.A = 2;  Vlofuncargs.phi = 0;
	Vlofunc = @(t, args) args.A * cos(args.f*2*pi*t + args.phi);
	% transient function of Vrf
	Vrffuncargs.f = 600e6; Vrffuncargs.A = 2;  Vrffuncargs.phi = pi;
	Vrffunc = @(t, args) args.A * cos(args.f*2*pi*t + args.phi);

	% vlo
	cktdata = add_element(cktdata, vsrcModSpec(), 'Vlo', {'10', '0'}, {}, {{'E',...
	{'DC', VloDC}, {'tr', Vlofunc, Vlofuncargs}}});

	% vrf
	cktdata = add_element(cktdata, vsrcModSpec(), 'Vrf', {'20', '0'}, {}, {{'E',...
	{'DC', VrfDC}, {'tr', Vrffunc, Vrffuncargs}}});

	% rlo
	cktdata = add_element(cktdata, resModSpec(), 'Rlo', {'10', '1'}, ...
					  {{'R', Rlo}}, {});

	% rrf
	cktdata = add_element(cktdata, resModSpec(), 'Rrf', {'20', '4'}, ...
					  {{'R', Rrf}}, {});

	% e1
	cktdata = add_element(cktdata, vcvsModSpec(), 'E1', {'2', '4', '1', '0'}, ...
					  {{'gain', 0.5}}, {});

	% e2
	cktdata = add_element(cktdata, vcvsModSpec(), 'E2', {'0', '3', '1', '0'}, ...
					  {{'gain', 0.5}}, {});

	% e3
	cktdata = add_element(cktdata, vcvsModSpec(), 'E3', {'5', '6', '4', '0'}, ...
					  {{'gain', 0.5}}, {});

	% e4
	cktdata = add_element(cktdata, vcvsModSpec(), 'E4', {'6', '7', '4', '0'}, ...
					  {{'gain', 0.5}}, {});

	% d1
	cktdata = add_element(cktdata, diodeModSpec(), 'D1', {'2', '7'}, {}, {});

	% d2
	cktdata = add_element(cktdata, diodeModSpec(), 'D2', {'5', '2'}, {}, {});

	% d3
	cktdata = add_element(cktdata, diodeModSpec(), 'D3', {'7', '3'}, {}, {});

	% d4
	cktdata = add_element(cktdata, diodeModSpec(), 'D4', {'3', '5'}, {}, {});

	% ro
	cktdata = add_element(cktdata, resModSpec(), 'Ro', {'6', '8'}, ...
					  {{'R', Ro}}, {});

	% cl
 	cktdata = add_element(cktdata, capModSpec(), 'Cl', {'8', '0'}, ...
 					  {{'C', Cl}}, {});

end
