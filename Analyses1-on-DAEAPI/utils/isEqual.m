function [passOrFail, comparisonInfo] = isEqual (input1, input2, abstol, reltol)
%function [passOrFail, comparisonInfo] = isEqual (input1, input2, abstol, reltol)
%This function compares two scalars/vectors/matrices using a pair of abstol and
%reltol.
%INPUT args:
%   input1      - first scalar/vector/matrix
%   input2      - second scalar/vector/matrix
%   abstol      - absolute tolerance for comparison
%   reltol      - relative tolerance for comparison
%OUTPUT:
%   passOrFail            - 1, if two inputs are equal
%                           0, otherwise
%   comparisonInfo        - if passOrFail == 0, then additional debug message
%                           in comparisonInfo.msg

    comparisonInfo.msg = '';

    try
        diffs = input1 - input2;
    catch
        comparisonInfo.msg = 'Input sizes don''t match';
        passOrFail = 0;
        return;
    end

    diffs = abs(input1 - input2);
    thresholds = abstol + reltol * 0.5 * (abs(input1) + abs(input2));
    passOrFail = (max(max(abs(diffs >= thresholds))) <= 0.5);

end
