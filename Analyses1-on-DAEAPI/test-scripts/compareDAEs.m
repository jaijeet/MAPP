function [passOrFail, comparisonInfo] = compareDAEs (DAE1, DAE2)
    % function to run some sanity checks to compare 2 DAEs
    % make sure their number/names of inputs, number/names of unknowns, etc. match

    passOrFail = 1;
    comparisonInfo = '';

    DAE1_nunks = feval(DAE1.nunks, DAE1);
    %DAE2_nunks = feval(DAE2.nunks, DAE2);
    DAE2_nunks = DAE2.Nunks;
    [isequal_nunks, cinfo] = isEqual (DAE1_nunks, DAE2_nunks, 0.01, 0);

    if isequal_nunks <= 0.5
        passOrFail = 0;
        comparisonInfo.msg = 'DAE nunks don''t match';
        return;
    end

    DAE1_unknames = feval(DAE1.unknames, DAE1);
    %DAE2_unknames = feval(DAE2.unknames, DAE2);
    DAE2_unknames = DAE2.UnkNames;
    isequal_unknames = 1;
    for idx = 1 : 1 : DAE1_nunks
        if ~strcmp( char(DAE1_unknames{idx}), char(DAE2_unknames{idx}) )
            isequal_unknames = 0;
            break;
        end
    end
    
    if isequal_unknames <= 0.5
        passOrFail = 0;
        comparisonInfo.msg = 'DAE unknames don''t match';
        return;
    end

    DAE1_ninputs = feval(DAE1.ninputs, DAE1);
    %DAE2_ninputs = feval(DAE2.ninputs, DAE2);
    DAE2_ninputs = DAE2.Ninputs;
    [isequal_ninputs, cinfo] = isEqual (DAE1_ninputs, DAE2_ninputs, 0.01, 0);

    if isequal_ninputs <= 0.5
        passOrFail = 0;
        comparisonInfo.msg = 'DAE ninputs don''t match';
        return;
    end
    
    DAE1_inputnames = feval(DAE1.inputnames, DAE1);
    %DAE2_inputnames = feval(DAE2.inputnames, DAE2);
    DAE2_inputnames = DAE2.InputNames;
    isequal_inputnames = 1;
    for idx = 1 : 1 : DAE1_ninputs
        if ~strcmp(char(DAE1_inputnames{idx}), char(DAE2_inputnames{idx}))
            isequal_inputnames = 0;
            break;
        end
    end
    
    if isequal_inputnames <= 0.5
        passOrFail = 0;
        comparisonInfo.msg = 'DAE inputnames don''t match';
        return;
    end

    DAE1_nparms = feval(DAE1.nparms, DAE1);
    %DAE2_nparms = feval(DAE2.nparms, DAE2);
    DAE2_nparms = DAE2.Nparms;
    [isequal_nparms, cinfo] = isEqual (DAE1_nparms, DAE2_nparms, 0.01, 0);

    if isequal_nparms <= 0.5
        passOrFail = 0;
        comparisonInfo.msg = 'DAE nparms don''t match';
        return;
    end
 
    DAE1_parmnames = feval(DAE1.parmnames, DAE1);
    %DAE2_parmnames = feval(DAE2.parmnames, DAE2);
    DAE2_parmnames = DAE2.ParmNames;
    isequal_parmnames = 1;
    for idx = 1 : 1 : DAE1_nparms
        if ~strcmp(char(DAE1_parmnames{idx}), char(DAE2_parmnames{idx}))
            isequal_parmnames = 0;
            break;
        end
    end
    
    if isequal_parmnames <= 0.5
        passOrFail = 0;
        comparisonInfo.msg = 'DAE parmnames don''t match';
        return;
    end

    DAE1_parms = feval(DAE1.getparms, DAE1);
    %DAE2_parms = feval(DAE2.getparms, DAE2);
    DAE2_parms = DAE2.Parms;

    isequal_parms = 1;
    for idx = 1:1:DAE1_nparms
        [isequal_parms_idx, cinfo_idx] = isEqual (DAE1_parms{idx}, DAE2_parms{idx}, 1e-9, 1e-6);
        if isequal_parms_idx <= 0.5
            isequal_parms = 0;
        end
    end
    
    if isequal_parms <= 0.5
        passOrFail = 0;
        comparisonInfo.msg = 'DAE parms don''t match';
        return;
    end

end

