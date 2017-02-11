%vecvalder is a Matlab/Octave class that performs automatic differentiation
%of Matlab code.
%
%- vecvalder is built on top of @valder by Richard D. Neidinger. See:
%  - Richard D. Neidinger, "Introduction to Automatic Differentiation 
%    and MATLAB Object-Oriented Programming", SIAM Review, Vol. 52, No. 3, 
%    pp. 545–563, 2010.
%    - available at http://www.davidson.edu/math/neidinger/SIAMRev74362.pdf.
%
%- vecvalder authors: 
%  - David Amsallem <amsallem@berkeley.edu> (original version, ~2011/10/01)
%  - Jaijeet Roychowdhury <jr@berkeley.edu>
%
%- License: [release-license.html GPLv3].
%
%- Version number and changelog
%   - see the file ./00-VERSION
%
%=============================================================================
%-- Quickstart, step 0: installing it from source (skip this step if you are 
%   using a binary release)
%   - autoconf
%   - ./configure [--prefix=/where/to/install/vecvalder]
%     # default location is $HOME/local/pkgs/vecvalder
%   - make
%   - make install
%   - follow the instructions at the end of make install to test
%
%-- Quickstart, step 1: running the included tests 
%   - cd ./tests/
%   - matlab
%     > addpath .. % ie, the directory containing @vecvalder
%     > run_ALL_vecvalder_tests
%
%-- Quickstart, step 2: using vecvalder within your own code
%
%   % include directory containing @vecvalder in PATH
%   addpath directory_containing_ATvecvalder;
%
%   % suppose you have a matlab function outvec = vecf(invec)
%   % outvec and invec are column vectors. You want to
%   % find the Jacobian matrix d vecf/d invec @ invec.
%   n = 5;
%   A = sprand(n,n,2/n);
%   vecf = @(x) A*x + rand(n,1);
%
%   invec = rand(n,1);
%
%   % first, make a vecvalder object from invec.
%   % speye(n) as the second argument indicates
%   % that these are the independent variables.
%   n = length(invec);
%   x = vecvalder(invec, speye(n));
%
%   % then, call vecf on x. vecf should only contain
%   % primitive operations that are supported by vecvalder.
%   % y will also be a vecvalder object, with the derivative
%   % columns containing the numerical values of the derivatives.
%
%   y = vecf(x);
%
%   % pick out the function values and the derivatives.
%   outvec = val2mat(y); % a column vector = vecf(invec)
%   JacobianMatrixSparse = der2mat(y) % derivatives (Jacobian matrix) wrt 
%   			%the inputs
%   full(JacobianMatrixSparse)
%   %
%
%   % special feature: convert a vecvalder object into a cell array of scalar
%   % vecvalders
%   vv_cell = y{1:n} % or y{:}; vv_cell is a cell array
%   y_three = vv_cell{3}; % third entry of vv y 
%
%   --------------------------------------
%   vecvalder SHORTCOMINGS AND WORK AROUND
%   --------------------------------------
%   Expand
%   % caution: the following will not work properly
%   z(1) = 0; % z will be created as double
%   z(2) = y; % y is a vecvalder, but double.subsasgn will be called for z(2)
%   	     % and it does not know how to deal with a vecvalder RHS
%	     % there will be a Subscripted Assignment Dimension Mismatch error.
%   %e proper fix is to overload double.subsasgn to handle vecvalder RHS; 
%   %t this has not been done yet. 
%   %workaround for the moment is:
%   z = y; % create z as a vecvalder using this
%   z = 0; % now vecvalder.subsasgn is called for z(2) and it deals with
%      % a double RHS correctly.
%
%
%==============================================================================
%
%-- How vecvalder works
%   A vecvalder variable is essentially a matrix (though stored internally
%   as a cell array). The first col is the value of the variable. The remaining
%   columns contain derivatives with respect to any number of independent
%   variables.
%
%   operators and functions -- such as +, -, *, /, =, exp(), sin(), cos(), 
%   tan(), etc. -- are overloaded in the vecvalder class so that they work not
%   only on on the values, but also compute the derivatives at the same time,
%   using the chain rule for differentiation.
%
%==============================================================================
%
%-- Functions supported by vecvalder:
%   - asin
%   - atan
%   - cosh
%   - cos
%   - display
%   - double
%   - exp
%   - log
%   - minus
%   - mpower
%   - power (soft link to mpower, needs fixing)
%   - mrdivide - 1/vv - probably needs fixing
%   - rdivide (soft link to mrdivide, may need fixing)
%   - times (vv/num .* vv/num) - just calls mtimes, may need fixing
%   - mtimes (A*vv)
%   - plus
%   - sin
%   - sqrt
%   - tanh
%   - tan
%   - uminus
%   - subsref
%   - eq (==)
%   - ne (~=)
%   - gt (>)
%   - lt (<)
%   - ge (>=)
%   - le (<=)
%   - and (&)
%   - or (|)
%   - mod(a,b) - not a differentiable function, but the derivatives should be correct at values of a, b where differentiable.
%   - subsasgn
%
%-- TODOs
%   - size checks seem to be missing for all binary operators
%   - overload the following operators: (see http://www.mathworks.com/help/techdoc/matlab_oop/br02znk-1.html)
%     - rdivide - currently missing
%     - power - currently linked to mpower
%     - we also need a matvalder class which interacts with vecvalder
%       - so that valders can be in matrix entries, too - useful for parameter
%         sensitivities.
%     - operator= ?
%     - copy constructor ?
%     - length - builtin seems to work
%     - size - builtin seems to work
%     - vertcat - builtin seems to work
%     - horzcat - builtin leads to error - this is how it should be
%     - subsindex - indexing with object indices; not needed
%
