%Writing and simulating electrical circuits in MAPP
%--------------------------------------------------
%
%vsrcRCL_demo    - creates a simple circuit consisting of a voltage source,
%                  resistor, capacitor and inductor (these devices are amongst
%                  those pre-defined in MAPP) and runs DC and transient
%                  analyses on it.
%
%                - to see the schematic of this circuit, run:
%                  >> showimage(which('vsrcRCL_demo.jpg'));
%
%                - to start creating the circuit, run:
%                  >> vsrcRCL_demo;
%
%MVS_curves_demo - computes and plots the DC characteristic curves of MIT's MVS
%                  MOS model using DC sweep analysis. The internal series 
%                  resistors in the model are accounted for in the calculation.
%                  Also, the demo runs small-signal AC analysis to examine
%                  the dynamical effects caused by MVS' charge model.
%
%                - run:
%                  >> showimage(which('MVS_curves_demo.jpg'));
%                  >> MVS_curves_demo;
%
%See also
%--------
%
% vsrcRCL_demo, MVS_curves_demo, MAPPquickstart

help MAPPquickstart_cktdemos;
