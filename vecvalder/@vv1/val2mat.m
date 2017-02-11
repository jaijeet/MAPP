function A = val2mat(u)
% Transforms the val fields of a vecvalder into a matrix
  A = zeros(size(u));
%    A(:) = cell2mat({u.val});
%   %A(:) = u.val;
%   %A = u.val;
  
  
%3/2013 Juan changes, this uses a reduced code from cell2mat
    c={u.val};
    rows = size(c,1);
    m = cell(rows,1);
    % Concatenate one dim first
    for n=1:rows
        m{n} = cat(2,c{n,:});
    end
     % Now concatenate the single column of cells into a matrix
    A(:) = cat(1,m{:});
%end Juan's changes

end
