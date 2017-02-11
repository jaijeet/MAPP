function alltests = allMAPPtests(tags)
%function alltests = allMAPPtests(tags)
%
%Introduction
%------------
%
%   All available tests under MAPPtest are listed in this function. 
%
%   When no tags are specified, allMAPPtests() returns a cell array of test
%   structs for all tests defined within the MAPPtest system. The tests are
%   comprehensive, but time consuming; they are used during, eg, automatic
%   nightly testing, to try to ensure that nothing is broken.
%   
%   Alternatively, you can specify tags to filter the tests you want to run.
%   
%   Input argument "tags" is a cell array of strings or a single string.
%   
%   Examples:
%     tests = allMAPPtests('AC');
%     tests = allMAPPtests({'AC'});
%     tests = allMAPPtests({'AC', 'DC'});
%     tests = allMAPPtests({'LTE'});
%     tests = allMAPPtests({'MNA', 'slow'});
%   
%   Available tags (case-insensitive):
%     'AC', 'DC', 'TRAN'
%     'slow', 'quick'
%     'LTE'
%     'MNA', 'STA'
%     'external', 'vecvalder', 'ModSpec', 'DAEAPI'
%     'vv4'
%
%Test Groups
%-----------
%
%   The available tests are organized into a number of groups:
%       - allMAPPtests:          all existing MAPPtests.
%       - allMAPPtests_DC:       all MAPPtests that involve DC analysis.
%       - allMAPPtests_AC:       all MAPPtests that involve AC analysis.
%       - allMAPPtests_TRAN:     all MAPPtests that involve transient analysis.
%       - allMAPPtests_MNAEqnEngine: all MAPPtests that use MNA_EqnEngine.
%       - allMAPPtests_STAEqnEngine: all MAPPtests that use STA_EqnEngine.
%       - allMAPPtests_LTE:      all MAPPtests for LTE-based timestep control.
%       - allMAPPtests_slow:     MAPPtests that take a long time to run.
%       - allMAPPtests_quick:    MAPPtests that run quickly, while still
%                                covering a wide range of different aspects of
%                                MAPP. 
%   
%   When creating new tests, add their names as well as tags in this file.
%   If new tags are used, update the "Available tags" section in Introduction of
%   this file.
%
%See also
%--------
%
%   defaultMAPPtests, MAPPtest, MAPPtest_transient, MAPPtest_DCSweep,
%   MAPPtest_AC, allMAPPtests_LTE, allMAPPtests_DC, allMAPPtests_AC,
%   allMAPPtests_TRAN, allMAPPtests_slow, allMAPPtests_quick,
%   allMAPPtests_MNAEqnEngine, allMAPPtests_STAEqnEngine, print_test_names
%   MAPPtesting
%


    testnames = {};
    testtags = {};
    i = 0;

    %===========================================================================
    % external tests
    %---------------------------------------------------------------------------
    i = i+1; testnames{i} = 'MAPPtest_ALL_vecvalder_tests';
             testtags{i} = {'external', 'vecvalder', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_ALL_ModSpec_tests';
             testtags{i} = {'external', 'ModSpec', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_ALL_DAEAPI_tests';
             testtags{i} = {'external', 'DAEAPI', 'quick'};
    % JR: commented out for defaults - python dependencies cause too much trouble
    %i = i+1; testnames{i} = 'MAPPtest_check_for_vv4_python_dependencies';
    %         testtags{i} = {'external', 'vecvalder', 'vv4'};
    %i = i+1; testnames{i} = 'MAPPtest_vv4_MVS_9_stage_ring_oscillator_transient';
    %         testtags{i} = {'external', 'vecvalder', 'vv4', 'slow'};
    %===========================================================================

    %===========================================================================
    % AC tests
    %---------------------------------------------------------------------------
    i = i+1; testnames{i} = 'MAPPtest_MNAEqnEngine_vsrc_diode_AC';
             testtags{i} = {'AC', 'MNA', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_BJTdiffpair_DAEAPIv6_AC';
             testtags{i} = {'AC', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_current_mirror_AC';
             testtags{i} = {'AC', 'MNA', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_RCline_wrapper_AC';
             testtags{i} = {'AC', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_BJTdiffpair_cktnetlist_AC';
             testtags{i} = {'AC', 'MNA', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_fullWaveRectifier_DAEAPIv6_AC';
             testtags{i} = {'AC', 'quick', 'realquick'};
    % i = i+1; testnames{i} = 'MAPPtest_MNA_DAAV6_AC';
    %          testtags{i} = {'AC', 'MNA', 'quick'};
    % i = i+1; testnames{i} = 'MAPPtest_MVSdiffpair_AC';
    %          testtags{i} = {'AC', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_MNA_DAAV6_AC';
             testtags{i} = {'AC', 'MNA', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_RClineDAEAPIv6_AC';
             testtags{i} = {'AC', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_SHdiffpair_AC';
             testtags{i} = {'AC', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_STA_current_mirror_AC';
             testtags{i} = {'AC', 'quick', 'STA', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_STA_SHdiffpair_AC';
             testtags{i} = {'AC', 'quick', 'STA', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_STA_vsrc_diode_AC';
             testtags{i} = {'AC', 'quick', 'STA', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_STA_vsrcRC_AC';
             testtags{i} = {'AC', 'quick', 'STA', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_STA_vsrcRCL_AC';
             testtags{i} = {'AC', 'quick', 'STA', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_vsrc_diode_AC';
             testtags{i} = {'AC', 'quick', 'realquick'};
    %===========================================================================

    %===========================================================================
    % DC tests
    %---------------------------------------------------------------------------
    i = i+1; testnames{i} = 'MAPPtest_charge_pump_DC';
             testtags{i} = {'DC', 'MNA', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_current_mirror_DC';
             testtags{i} = {'DC', 'MNA', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_BJTdiffpair_DAEAPIv6_DCsweep';
             testtags{i} = {'DC', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_inverter_DCsweep';
             testtags{i} = {'DC', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_BJTdiffpair_DCsweep';
             testtags{i} = {'DC', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_reducedRRE_QSS';
             testtags{i} = {'DC', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_diode_mixer_DCsweep';
             testtags{i} = {'DC', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_SH_MOS_char_curves_DCsweep';
             testtags{i} = {'DC', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_BJTdiffpair_cktnetlist_DCsweep';
             testtags{i} = {'DC', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_delay_line_DC';
             testtags{i} = {'DC', 'MNA', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_inverterchain_DCsweep';
             testtags{i} = {'DC', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_MNA_BJTdiffpair_cap_oldcktformat_DCsweep';
             testtags{i} = {'DC', 'quick', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_MNA_BJTdiffpair_old_cktformat_DCsweep';
             testtags{i} = {'DC', 'quick', 'MNA'};
    % i = i+1; testnames{i} = 'MAPPtest_MNA_MVS_char_curves_DCsweep';
    %          testtags{i} = {'DC', 'quick', 'MNA'};
    % i = i+1; testnames{i} = 'MAPPtest_MVS_dc_inverter_DCsweep';
    %          testtags{i} = {'DC', 'slow', 'MNA'};
    % i = i+1; testnames{i} = 'MAPPtest_MVSdiffpair_DCsweep';
    %          testtags{i} = {'DC', 'slow', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_MNA_DAAV6_char_curves_DCsweep';
             testtags{i} = {'DC', 'quick', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_MNA_MVS_1_0_1_char_curves_DCsweep';
             testtags{i} = {'DC', 'quick', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_MNA_MVS_1_0_1_inverter_DCsweep';
             testtags{i} = {'DC', 'quick', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_MNA_MVS_1_0_1_amp_DCsweep';
             testtags{i} = {'DC', 'quick', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_OptoCoupler_DCsweep';
             testtags{i} = {'DC', 'MNA', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_res_divider_DC';
             testtags{i} = {'DC', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_SHdiffpair_DCsweep';
             testtags{i} = {'DC', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_SH_PMOS_curves_DCsweep';
             testtags{i} = {'DC', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_STA_charge_pump_DC';
             testtags{i} = {'DC', 'quick', 'STA', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_STA_current_mirror_DC';
             testtags{i} = {'DC', 'quick', 'STA', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_STA_delay_line_DC';
             testtags{i} = {'DC', 'quick', 'STA'};
    i = i+1; testnames{i} = 'MAPPtest_STA_SHdiffpair_DCsweep';
             testtags{i} = {'DC', 'slow', 'STA'};
    i = i+1; testnames{i} = 'MAPPtest_STA_vsrc_diode_DC';
             testtags{i} = {'DC', 'quick', 'STA', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_STA_vsrcRC_DC';
             testtags{i} = {'DC', 'quick', 'STA'};
    i = i+1; testnames{i} = 'MAPPtest_STA_vsrcRCL_DC';
             testtags{i} = {'DC', 'quick', 'STA'};
    i = i+1; testnames{i} = 'MAPPtest_vsrc_diode_DC';
             testtags{i} = {'DC', 'quick'};
    % i = i+1; testnames{i} = 'MAPPtest_MNA_MVS_no_int_nodes_char_curves';
    %          testtags{i} = {'DC', 'quick', 'MNA'};
    %===========================================================================

    %===========================================================================
    % transient tests
    %---------------------------------------------------------------------------
    i = i+1; testnames{i} = 'MAPPtest_BJTdiffpairRelaxationOsc_transient';
             testtags{i} = {'TRAN', 'slow'};
    i = i+1; testnames{i} = 'MAPPtest_OptoCoupler_transient';
             testtags{i} = {'TRAN', 'slow', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_charge_pump_transient';
             testtags{i} = {'TRAN', 'slow', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_delay_line_transient';
             testtags{i} = {'TRAN', 'slow', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_BJTdiffpair_DAEAPIv6_transient';
             testtags{i} = {'TRAN', 'slow'};
    % i = i+1; testnames{i} = 'MAPPtest_BJTdiffpairSchmittTrigger_transient';
    %          testtags{i} = {'TRAN', 'slow'};
    i = i+1; testnames{i} = 'MAPPtest_BSIM3_ringosc_transient';
             testtags{i} = {'TRAN', 'slow', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_parallelRLCdiode_transient';
             testtags{i} = {'TRAN', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_inverter_transient';
             testtags{i} = {'TRAN', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_RCline_transient';
             testtags{i} = {'TRAN', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_UltraSimplePLL_transient';
             testtags{i} = {'TRAN', 'slow'};
    i = i+1; testnames{i} = 'MAPPtest_resistive_divider_transient';
             testtags{i} = {'TRAN', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_vsrcRC_transient';
             testtags{i} = {'TRAN', 'quick'};
    % Disabled due to ill-conditioned matrix. 
    % i = i+1; testnames{i} = 'MAPPtest_vsrcRCL_transient';
    %          testtags{i} = {'TRAN', 'quick'};
    % i = i+1; testnames{i} = 'MAPPtest_vsrc_diode_transient';
    %          testtags{i} = {'TRAN', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_RCline_wrapper_tran';
             testtags{i} = {'TRAN', 'slow'};
    i = i+1; testnames{i} = 'MAPPtest_tworeactionchain_wrapper_tran';
             testtags{i} = {'TRAN', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_inverterchain_transient';
             testtags{i} = {'TRAN', 'slow'};
    % i = i+1; testnames{i} = 'MAPPtest_fullWaveRectifier_DAEAPIv6_transient';
    %          testtags{i} = {'TRAN', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_BJTdiffpair_cktnetlist_transient';
             testtags{i} = {'TRAN', 'slow', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_coupledRCdiodeSpringMasses_transient';
             testtags{i} = {'TRAN', 'slow'};
    i = i+1; testnames{i} = 'MAPPtest_LTE_inverter_transient';
             testtags{i} = {'TRAN', 'LTE', 'slow'};
    i = i+1; testnames{i} = 'MAPPtest_LTE_MNA_vsrcRC_transient';
             testtags{i} = {'TRAN', 'LTE', 'MNA', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_LTE_RCline_transient';
             testtags{i} = {'TRAN', 'LTE', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_LTE_SHdiffpair_transient';
             testtags{i} = {'TRAN', 'LTE', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_LTE_UltraSimplePLL_transient';
             testtags{i} = {'TRAN', 'LTE', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_MNA_DAAV6_ringosc_transient';
             testtags{i} = {'TRAN', 'MNA', 'slow'};
    i = i+1; testnames{i} = 'MAPPtest_ModSpec_wrapper_CMOSinverter_tran';
             testtags{i} = {'TRAN', 'quick'};
    % i = i+1; testnames{i} = 'MAPPtest_MVSdiffpair_transient';
    %          testtags{i} = {'TRAN', 'slow'};
    i = i+1; testnames{i} = 'MAPPtest_MVS_1_0_1_amp_transient';
             testtags{i} = {'TRAN', 'slow', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_MVS_1_0_1_inverter_transient';
             testtags{i} = {'TRAN', 'slow', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_MVS_1_0_1_ringOsc3_transient';
             testtags{i} = {'TRAN', 'slow', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_parallelLC_transient';
             testtags{i} = {'TRAN', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_parallelLRC_transient';
             testtags{i} = {'TRAN', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_resVsrcDiodeRLC_transient';
             testtags{i} = {'TRAN', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_SHdiffpair_transient';
             testtags{i} = {'TRAN', 'quick', 'MNA'};
    i = i+1; testnames{i} = 'MAPPtest_SoloveichikABCosc_RRE_tran';
             testtags{i} = {'TRAN', 'quick'};
    i = i+1; testnames{i} = 'MAPPtest_SoloveichikABCoscStabilized_RRE_tran';
             testtags{i} = {'TRAN', 'slow'};
    i = i+1; testnames{i} = 'MAPPtest_STA_SHdiffpair_transient';
             testtags{i} = {'TRAN', 'quick', 'STA'};
    i = i+1; testnames{i} = 'MAPPtest_STA_vsrc_diode_transient';
             testtags{i} = {'TRAN', 'quick', 'STA'};
    i = i+1; testnames{i} = 'MAPPtest_STA_vsrcRCL_tran';
             testtags{i} = {'TRAN', 'quick', 'STA'};
    i = i+1; testnames{i} = 'MAPPtest_STA_vsrcRC_tran';
             testtags{i} = {'TRAN', 'quick', 'STA', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_tworeactionchain_transient';
             testtags{i} = {'TRAN', 'quick', 'realquick'};
    i = i+1; testnames{i} = 'MAPPtest_vsrc_diode_tran';
             testtags{i} = {'TRAN', 'quick'};
    %===========================================================================

    if 0 == nargin
        alltests = create_tests(testnames, testtags);
    else
        alltests = create_tests(testnames, testtags, tags);
    end
end

function tests = create_tests(testnames, testtags, tags)
%function tests = create_tests(testnames, testtags, tags)
% This function create MAPP test structures with testnames.
% When tags are specified, it also filter tests based on tags and testtags
% (cellarray that contains tags of all tests)
%
% all tags comparisons are case-insensitive
%
    if nargin < 3 % tags not specified
        notags = 1;
    else
        tags = upper(tags); % for case-insensitive comparison
        notags = 0;
    end
    ntest = length(testnames);
    tests= {};
    i = 0;
    for c = 1:ntest
        include_test = 0; % a little redundant, but it makes logic clearer
        if notags
            include_test = 1;
        else
            testtag = testtags{c}; % cellarray
            testtag = upper(testtag); % for case-insensitive comparison
            ntags = length(testtag);
            for d = 1:ntags
                the_tag = testtag{d};
                found = 0;
                if isstr(tags)
                    found = strcmp(the_tag, tags);
                else % is cellarray of strings
                    found = ismember(the_tag, tags);
                end
                if found
                    break;
                end
            end
            if found
                include_test = 1;
            end
        end
        if include_test
            testname = testnames{c};
            i = i+1; tests{i} = eval(testname);
        end
    end
end
