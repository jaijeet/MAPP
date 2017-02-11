% This MATLAB script runs DC sweep (Vin vs. Vout) for a CMOS Inverter
% DAE described by a separate MATLAB script DAE_MOSinverter
user_input=input('Which version of Inverter DAE : (A) v1 (not working), (b) v2 (working):::  ','s');
if strcmpi(user_input,'A')==1 || isempty(user_input)
        % DAE implementation with one unknown
        DAE= DAE_MOSinverter_v1();
        oof=1;
else
        % DAE implementation with five unknowns
        DAE= DAE_MOSinverter_v2();
        oof=3;
end

% Newton-Raphson Parameters
NRparms.maxiter=100;
NRparms.reltol=1e-5;
NRparms.abstol=1e-10;
NRparms.residualtol=1e-12;


Vdd=5;
u=[Vdd,0]; % u=[Vdd;Vin]
% set the input of the DAE 
DAE=feval(DAE.set_uQSSvec,u,DAE);
% VOUTS=[] is the variable to store NR solutions (various Vout values
% corresponding to Vin values given in VINS
VOUTS = []; VINS =0:0.05:Vdd;

if oof == 1 % First (one unknown) DAE implementation of the Inverter
        initguess=[Vdd];
else  % Second (larger # of unknows) DAE implementation of the Inverter
        initguess=[0,Vdd,Vdd,0,0]';
end


for Vin=VINS
        % Set the input values. Vdd is constant through out, only Vin
        % changes. 
        u=[Vdd;Vin]; % u=[Vdd;Vin]
        % set the input of the DAE
        DAE=feval(DAE.set_uQSSvec,u,DAE);
        NR_results=NR_Tutorial(DAE.f,DAE.Jf,initguess,DAE,NRparms);
        solution = NR_results.solution;
        iters = NR_results.iters;
        success = NR_results.success;
        initguess=solution;
        VOUTS=[VOUTS,solution(oof)];
end

figure(100)
plot(VINS,VOUTS,'r.--','MarkerFaceColor','b');
xlabel('V_{in} (V) \rightarrow');
ylabel('V_{out} (V) \rightarrow');
axis([0 5 0 5]); 
title('DC sweep characteristics of a MOS Inverter');
