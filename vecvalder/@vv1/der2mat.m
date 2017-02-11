function A = der2mat(u)
% % Transforms the der fields of a vecvalder into a matrix
%   %A = zeros(size(u(1).der,2),size(u,1));
  n1 = size(u(1).der,2);
  n2 = size(u,1);
  A = sparse(n1,n2);
% 
% 
%   A(:) = cell2mat({u.der});
%   A=A';
% % A = u.der
% 


%3/2013 Juan changes, this uses a reduced code from cell2mat
    c={u.der};
    rows = size(c,1);
    m = cell(rows,1);
    % Concatenate one dim first
    for n=1:rows
        m{n} = cat(2,c{n,:});
    end
     % Now concatenate the single column of cells into a matrix
    A(:) = cat(1,m{:});
	A=A';
%end of Juan changes's

end
