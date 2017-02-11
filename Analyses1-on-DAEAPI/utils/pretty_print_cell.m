function pretty_print_cell(mycell)
%function pretty_print_cell(mycell)
%prints out the contents of my arr in a readable way, 1 entry per line, with
%numbering. Currently, works only for string and numeric types.
%
%Examples
%--------
%
% tests = ALL_transient_tests();
% pretty_print_cell(tests);
%
%See also
%--------
%
% run_ALL_A1oDAEAPI_tests, ALL_DC_tests, ALL_transient_tests, ALL_AC_tests
% 
%
%Author: J. Roychowdhury, 2013/09/21
%

	for i=1:length(mycell)
		if isnumeric(mycell{i})
			fprintf(1,'%d.\t %g\n', i, mycell{i});
		elseif ischar(mycell{i})
			fprintf(1,'%d.\t %s\n', i, mycell{i});
		else 
			fprintf(1,'%d.\t <data type %s not supported>\n', i, ...
				class(mycell{i}));
		end
	end
end
