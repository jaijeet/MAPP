%MAPP has an in-built automated testing system which tests all the compact
%models, the circuit DAEs, the analysis algorithms, and the vecvalder package
%by running certain test scripts and comparing their output against previously
%stored corresponding test data.  The main purpose of this system is to make
%sure that any new code addition or modification by the user has not
%been compromised the integrity and the robustness of the MAPP code.
%
%
%The MAPPtest system consists of the following scripts:
%
%MAPPtest_analysis        - Runs the following MAPP test scripts:
%                           MAPPtest_transient, MAPPtest_AC, MAPPtest_DCsweep
%MAPPtest_transient       - Runs transient analysis test on all the circuit
%                           DAEs that natively come with a fresh MAPP
%                           installation
%MAPPtest_AC              - Runs AC analysis test on all the circuit DAEs that
%                           natively come with a fresh MAPP installation 
%MAPPtest_DCsweep         - Runs DC sweep test on all the circuit DAEs that
%                           natively come with a fresh MAPP installation 
%MAPPtest_DAEAPI          - Runs various sanity checks on all the circuit DAEs
%                           that natively come with a fresh MAPP installation 
%MAPPtest_ModSpec         - Runs various sanity checks on all the ModSpec
%                           API-based compact models that natively come with
%                           a fresh MAPP installation 
%MAPPtest_vecvalder       - Runs various sanity checks on all the available
%                           function calls in the vecvalder package 
%
%
%All the above test scripts can be run with two options: update and
%compare/test. With the update option enabled, the MAPP test scripts are
%executed and upon their successful execution, the input and the output data of
%the scripts are saved in apropriate MATLAB .mat files. These data are called
%reference test data.  In the test/compare mode, after the scripts are executed,
%their inputs/outputs are compared with the corresponding inputs/outputs from
%the reference test data. If the user tries to run the test scripts in the
%test/compare mode without first running them in the update mode, then the
%test scripts abort their execution asking the user to run them with the update
%mode enabled first. 
%
%To add a new test to these MAPPtest sub-modules, refer to their respective
%help pages.
%
%MAPPtest-ModSpec-new     - Documentation on how to add a new ModSpec API-based
%                           compact model to the MAPPtest system 
%MAPPtest-DAEAPI-new      - Documentation on how to add a new DAEAPI-based
%                           circuit DAE to the MAPPtest system 
%MAPPtest-Transient-new   - Documentation on how to add a new transient
%                           analysis test of a circuit DAE to the MAPP testing
%                           system
%MAPPtest-AC-new          - Documentation on how to add a new AC analysis test
%                           of a circuit DAE to the MAPPtest system
%MAPPtest-DCsweep-new     - Documentation on how to add a new DC sweep test of
%                           a circuit DAE to the MAPPtest system
%MAPPtest-vecvalder-new   - Documentation on how to add a new functionality
%                           check to the MAPPtest system for the vecvalder
%                           package
