%Device models in MAPP are described in ModSpec format.
%
%Available built-in devices
%--------------------------
%
%resModSpec                - resistor
%capModSpec                - capacitor
%indModSpec                - inductor
%vsrcModSpec               - voltage source
%isrcModSpec               - current source
%vcvsModSpec               - voltage-controlled voltage source
%vccsModSpec               - voltage-controlled current source
%cccsModSpec               - current-controlled current source
%ccvsModSpec               - current-controlled voltage source
%diodeModSpec              - diode
%EbersMoll_BJT_ModSpec     - BJT (Ebers Moll BJT model)
%SH_MOS_ModSpec            - MOSFET (Shichman Hodges model)
%MVS_1_0_1_ModSpec         - MOSFET (MVS model v1.0.1)
%
%
%More devices (described using ee_ModSpec_wrapper)
%-------------------------------------------------
%
%resistor_ModSpec_wrapper                   - resistor: linear, two-terminal,
%                                                 memoryless (has only f part)
%diode_ModSpec_wrapper                      - diode: nonlinear
%capacitor_ModSpec_wrapper                  - capacitor: has only q part
%mutualInductor_ModSpec_wrapper             - mutual inductor model
%diodeCapacitor_ModSpec_wrapper             - diode w/ cap: with both f/q
%basicSHMOS_ModSpec_wrapper                 - SH MOSFET: three-terminal
%SHMOSWithParasitics_ModSpec_wrapper        - SH MOSFET: with both f/q,
%                                                  with internal unknowns
%DSAwareSHMOSWithParasitics_ModSpec_wrapper - SH MOSFET
%vsrc_ModSpec_wrapper                       - voltage source: with input
%
%See also
%--------
% add_element, MAPPcktnetlists, ModSpecAPI, ModSpec_concepts
%
% resModSpec, capModSpec, indModSpec, vsrcModSpec, isrcModSpec, vcvsModSpec,
% vccsModSpec, cccsModSpec, ccvsModSpec, diodeModSpec, EbersMoll_BJT_ModSpec,
% SH_MOS_ModSpec, MVS_1_0_1_ModSpec
%
% resistor_ModSpec_wrapper, diode_ModSpec_wrapper, capacitor_ModSpec_wrapper,
% diodeCapacitor_ModSpec_wrapper, basicSHMOS_ModSpec_wrapper,
% SHMOSWithParasitics_ModSpec_wrapper,
% DSAwareSHMOSWithParasitics_ModSpec_wrapper, vsrc_ModSpec_wrapper,
% mutualinductor_ModSpec_wrapper
%
