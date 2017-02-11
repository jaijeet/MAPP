try 
        setuppaths_MAPP
        diary('MAPPtest_Commandline_output.txt');
        disp('------------------------------------------------------------------------------');
        disp('TEST SCRIPTS RUN:');
        disp(' - MAPPtest(''compare'')');
        disp('------------------------------------------------------------------------------');

        disp('TEST RESULTS:');
        disp('------------------------------------------------------------------------------');
        MAPPtest('compare'); %MAPPtest_transient
        disp('CODE TERMINATED SUCCESSFULLY.');
        disp(' ');
catch err
        disp(err.message);
        disp('CODE DID NOT TERMINATE SUCCESSFULLY.');
        diary off
        exit
end

