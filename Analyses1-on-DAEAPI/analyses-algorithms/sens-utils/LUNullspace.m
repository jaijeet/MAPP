function [luObj] = LUNullspace(A, pivotEpsilon)
%function [luObj] = LUNullspace(A, pivotEpsilon)
%Structure/object used to compute the nullspace of A efficiently using LU
%factorization, and to solve matrix-vector equations where the matrix is not
%full-rank.
%
%Arguments:
%
% - A:            The matrix on which to perform LU factorization / compute the
%                 nullspace.
%
% - pivotEpsilon: Cutoff value for a pivot value to be considered nonzero.
%
%Output
%
% - luObj: a LUNullspace object, with which you can compute the nullspace of A
%          or solve the equation Ax = b, where b is in the columnspace of A.
    if nargin < 2
        pivotEpsilon = 1e-9;
    end
    luObj.pivotEpsilon = pivotEpsilon;

    luObj.A = A;

    Asize = size(luObj.A);
    luObj.n = Asize(1);

    luObj.rank = 0;
    % Performs LU factorization on A and sets luObj.rank to the rank of A.
    luObj = luFactor(luObj);

    luObj.computeNullspace = @computeNullspace;
    luObj.solve = @solve;

    function nullspace = computeNullspace(luObj)
    %function nullspace = computeNullspace(luObj)
    %Compute the nullspace of luObj.A via LU factorization.
    %
    %Arguments:
    %
    % - luObj: the LUNulspace structure/object
    %
    %Output
    %
    % - nullspace: a matrix representing the nullspace of A
        nullspace = zeros(luObj.n, luObj.n - luObj.rank);

        % A has already been factored into A = LU
        L = tril(luObj.A, -1);
        U = triu(luObj.A, 1);

        % Solve Ax = 0
        for col=luObj.rank+1:luObj.n
            % Past the first luObj.rank columns, the pivot will be zero.
            % WLOG, we can set the element of the nullspace vector that will be
            % multiplying the pivot to 1, and then solve for the rest of the vector.
            nullspace(col, col) = 1;
            for i=luObj.rank:-1:1
                nullspace(i, col) = nullspace(i, col) - U(i, :) * nullspace(:, col);
            end
            if col > luObj.rank+1
                % Perform Gram-Schmidt to orthonormalize the nullspace
                nullspace(:, col) = nullspace(:, col) -...
                                    nullspace(:, 1:col-1) * nullspace(:, 1:col-1)' * nullspace(:, col);
                nullspace(:, col) = nullspace(:, col) ./ norm(nullspace(:, col));
            end
        end

        % The column swaps on A translate to row swaps on the nullspace vectors.
        % Left-multiply the nullspace by Q to perform these swaps.
        nullspace = luObj.Q * nullspace;
        nullspace = nullspace(:, luObj.rank+1:end);
    %end nullspace

    function x = solve(b, luObj)
    %function x = solve(b, luObj)
    %Solves Ax = b, where A may not be full-rank.  Assumes x is in the columnspace
    %of A, otherwise x will be inaccurate
    %
    %Arguments:
    %
    % - b:     the column vector on the right-hand side of Ax = b
    %
    % - luObj: the LUNulspace structure/object
    %
    %Output
    %
    % - x: the solution to the matrix-vector equation
        % Perform row permutations on b     
        b = luObj.P * b;
        L = tril(luObj.A, -1);
        U = triu(luObj.A, 1);
        for i=1:luObj.rank
            b(i) = (b(i) - L(i, :) * b) / luObj.A(i, i);
        end
        for i=luObj.rank:-1:1
            b(i) - b(i) - U(i, :) * b;
        end
        % Column permutations on A --> we must left-multiply x by the
        % column permutation matrix.
        x = luObj.Q * b;
    % end solve

    function luObjOUT = luFactor(luObj)
    %function luObjOUT = luFactor(luObj)
    %Performs LU factorization on luObj.A, in place (the lower triangle of A holds
    %L and the upper triangle holds U).
    %
    %Arguments:
    %
    % - luObj: the LUNulspace structure/object
    %
    %Output
    %
    % - luObjOUT: the LUNullspace structure/object, with A factored.
        % Column swaps of A
        luObj.Q = eye(luObj.n);
        % Row swaps of A
        luObj.P = eye(luObj.n);

        for i=1:luObj.n
            % If the current pivot is 0, try to perform row and column swaps to find a new pivot
            if abs(luObj.A(i, i) - luObj.A(i, 1:i-1) * luObj.A(1:i-1, i)) < luObj.pivotEpsilon
                possiblePivots = luObj.A(i:end, i:end) - luObj.A(i:end, 1:i-1) * luObj.A(1:i-1, i:end);
                possiblePivots = reshape(possiblePivots, 1, []);
                % Find the largest possible pivot
                [pivot, pivotIdx] = max(abs(possiblePivots));
                if abs(pivot) < luObj.pivotEpsilon
                    % No pivot is suitable, so the matrix is singular
                    luObj.A(i:end, i:end) = 0;
                    luObjOUT = luObj;
                    return;
                end
                % swap rows or columns to move the pivot to position (i, i)
                colIdx = i + floor((pivotIdx-1)/(luObj.n-i+1));
                rowIdx = i + mod(pivotIdx-1, luObj.n-i+1);
                
                % Column swaps
                luObj.A(:, [i, colIdx]) = luObj.A(:, [colIdx, i]);
                luObj.Q(:, [i, colIdx]) = luObj.Q(:, [colIdx, i]);

                % Row swaps
                luObj.A([i, rowIdx], :) = luObj.A([rowIdx, i], :);
                luObj.P([i, rowIdx], :) = luObj.P([rowIdx, i], :);
            end
            luObj.rank = luObj.rank + 1;
            % LU factorization step
            luObj.A(i:end, i) = luObj.A(i:end, i) - luObj.A(i:end, 1:i-1) * luObj.A(1:i-1, i);
            luObj.A(i, i+1:end) = (luObj.A(i, i+1:end) - luObj.A(i, 1:i-1) * luObj.A(1:i-1, i+1:end)) / luObj.A(i, i);
        end

        luObjOUT = luObj;
    %end luFactor
%end LUNullspace
