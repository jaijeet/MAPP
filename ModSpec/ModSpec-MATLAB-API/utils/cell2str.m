function out = cell2str(cellin)
%function out = cell2str(cellin)
%MATLAB function to convert cell elements to a string
	out = '{';
	n = length(cellin);
	for i = 1:n
		out = strcat(out, cellin{i});
		if i ~= n
			out = sprintf('%s, ', out);
		end
	end
	out = strcat(out, '}');
end
