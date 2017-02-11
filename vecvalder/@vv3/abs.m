function h = abs(u)
  %VECVALDER/ABS overloads abs of a vecvalder object argument
  n = size(u(1).der,2); 
  h = vecvalder(abs(val2mat(u)), repmat(sign(val2mat(u)),[1 n]).*der2mat(u));
end

%{
% another version
function h = abs(u)
  %VECVALDER/ABS overloads abs of a vecvalder object argument
  n = size(u(1).der,2); 
  h = vecvalder(abs(val2mat(u)), repmat(newsign(val2mat(u)),[1 n]).*der2mat(u));
end

function b = newsign(a)
	b = sign(a);
	[row, col] = find(b == 0);
	b(row, col) = -1;
end
%}
