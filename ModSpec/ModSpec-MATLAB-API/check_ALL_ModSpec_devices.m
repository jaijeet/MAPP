% All ModSpec devices are consistent with ModSpecAPI if the code terminates
% successfully

MOD = BSIM3v3_2_4_ModSpec;
check_ModSpec(MOD);

MOD = capModSpec;
check_ModSpec(MOD);

MOD = cccsModSpec;
check_ModSpec(MOD);

MOD = ccvsModSpec;
check_ModSpec(MOD);

MOD = DAAV6ModSpec;
check_ModSpec(MOD);

MOD = diodeModSpec;
check_ModSpec(MOD);

MOD = EbersMoll_BJT_ModSpec;
check_ModSpec(MOD);

MOD = EbersMoll_BJT_With_Capacitor_ModSpec;
check_ModSpec(MOD);

MOD = example_initlimiting_ModSpec;
check_ModSpec(MOD);

MOD = exampleModSpec;
check_ModSpec(MOD);

MOD = indModSpec;
check_ModSpec(MOD);

MOD = isrcModSpec;
check_ModSpec(MOD);

MOD = MVS_1_0_1_ModSpec;
check_ModSpec(MOD);

MOD = MVS_1_0_1_ModSpec_wrapper;
check_ModSpec(MOD);

MOD = resModSpec;
check_ModSpec(MOD);

MOD = SH_MOS_ModSpec;
check_ModSpec(MOD);

MOD = SH_MOS_ModSpec_nolimiting;
check_ModSpec(MOD);

MOD = vccs_for_optocoupler_ModSpec;
check_ModSpec(MOD);

MOD = vccsModSpec;
check_ModSpec(MOD);

MOD = vcvsModSpec;
check_ModSpec(MOD);

MOD = vsrcModSpec;
check_ModSpec(MOD);

%----------------------------------
MOD = basicSHMOS_ModSpec_wrapper;
check_ModSpec(MOD);

MOD = capacitor_ModSpec_wrapper;
check_ModSpec(MOD);

MOD = diodeCapacitor_ModSpec_wrapper;
check_ModSpec(MOD);

MOD = diode_ModSpec_wrapper;
check_ModSpec(MOD);

MOD = DSAwareSHMOSWithParasitics_ModSpec_wrapper;
check_ModSpec(MOD);

MOD = resistor_ModSpec_wrapper;
check_ModSpec(MOD);

MOD = SHMOSWithParasitics_ModSpec_wrapper;
check_ModSpec(MOD);

MOD = tunnelDiode_ModSpec_wrapper;
check_ModSpec(MOD);

MOD = vsrc_ModSpec_wrapper;
check_ModSpec(MOD);
