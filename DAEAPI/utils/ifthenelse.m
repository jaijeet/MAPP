function result = ifthenelse(test,trueVal,falseVal)
%function result = ifthenelse(test,trueVal,falseVal)
% from http://www.mathworks.com/matlabcentral/newsreader/view_thread/147044
	%fprintf(1, 'ifthenelse: test=%d\n', test);
        try
            if test
                result = trueVal;
            else
                result = falseVal;
            end
        catch
            result = false;
        end
end
