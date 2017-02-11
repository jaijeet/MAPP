function PMOSobj = DSintSH_Ptype
%function PMOSobj = DSintSH_Ptype
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	PMOSobj.f = @f;
% end "constructor"

function [ID, dID_dVGS, dID_dVDS] = f(VGS, VDS, beta, VT)
%function [ID, dID_dVGS, dID_dVDS] = f(VGS, VDS, beta, VT)
%
%P-type SH model with drain-source inversion. The code is vectorized.
%
%Simply calls the N-type model with massaged arguments; massages its
%outputs and returns.
% 
%For a P-type MOSFET, the schematic convention is show the source on top and
%the drain at the bottom. "Correct" biassing for a P-type MOSFET has the
%source at a higher potential than both the gate and the drain. Therefore,
%for current to flow into the source and out of the drain, VGS and VDS
%should both be negative.
%
%The current, ID, that is returned is the current that _enters_ the drain. Ie,
%in normal operation, ID should be negative.
%
% so we have: IDP = - SH_N_ID(-VGS,-VDS)
% d/dVGS IDP = + d/dVGS SH_N_ID(-VGS,-VDS)
% d/dVDS IDP = + d/dVDS SH_N_ID(-VGS,-VDS)

NMOS = DSintSH_Ntype;

[IDN, dID_dVGS, dID_dVDS] = feval(NMOS.f, -VGS, -VDS, beta, VT);
ID = -IDN;
