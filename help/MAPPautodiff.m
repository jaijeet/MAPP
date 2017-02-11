%Automatic Differentiation facilities in MAPP
%--------------------------------------------
%
%MAPP contains facilities for automatic differentiation. What this means
%is that if you write a MATLAB function y = f(x), MAPP can compute dy/dx
%without resorting to finite differences. For example, if you define 
%f = @(x) x^2, MAPP's automatic differentation facilities will, in essence,
%figure out that df/dx is 2*x and compute it using this formula, not as
%((x+delta)^2-x^2)/delta for some small value of delta. Using exact formulae
%for derivatives is important because numerical errors from finite-difference
%based derivative calculations can, in many cases, be significant enough to
%break simulation algorithms.
%
%MAPP has several automatic differentiation packages within (currently,
%vv1 and vv2); one of these is selected during installation by Makefile.in and
%is called vecvalder - a Matlab/Octave class that performs automatic
%differentiation of Matlab code. See near the end of this help for notes on
%different implementations of vecvalder.
%
%Basic use of vecvalder
%----------------------
%
%Here is how you would use vecvalder for the simple example above:
%
% f = @(t) t^2; % simple scalar function of a scalar variable
% x = 2; y = f(x)            % confirm that f(x) "works": you should see y=4
%
% % now use vecvalder to compute the derivative of f(x) automatically:
%
% vvx = vecvalder(x, 'indep'); % creates a vecvalder representation of x and
%                            % declares it to be an independent variable (ie,
%                            % derivatives of other dependent quantities will be
%                            % calculated with respect to x). Displaying
%                            % vvx shows a value of 2 and a derivative of 1 
%                            % (ie, d_vvx/dx = 1).
% vvx % see what vvx looks like: it has a val=1 and a der=2
% vvy = f(vvx);                % calls f with vecvalder argument vvx
%                            % this automatically computes df(x)/dx in
%                            % the der field of vvy.
% vvy                        % val=4 (ie, x^2) and der=4 (ie, 2*x)
% fx = val(vvy);            % val() gets you the value as a normal numerical
%                            % value (ie, not vecvalder)
% dy_dx = jac(vvy);            % jac() gets you the derivative as a normal 
%                            % numeric value
%
%You can compose vecvalder objects to find derivatives of, eg, functions
%of functions. For example, suppose you now define z = sin(y), with
%y=x^2 as defined above, and you wish to find dz/dx. You would simply do this:
%
% g = @(t) sin(t); % define the function
% vvz = g(vvy);
%
% vvz % display vvz
%
% z = val(vvz); % the value of z=sin(y) = sin(x^2) at x=2
% dz_dx = jac(vvz); % the derivative dz/dx at x=2
%
%Note that above computes dz/dx (not dz/dy) because you had defined x to be 
%the independent variable. If you had wanted dz/dy instead (at y=4), you would
%have run:
% vvy = vecvalder(fx, 'indep'); % makes vvy the indep. var. for
%                                % differentiation, with value fx=4
% vvz = g(vvy)         % the val field of vvz is dz/dy
%
%
%Using vecvalder for vector functions
%------------------------------------
%
%vecvalder also works for vector functions of vector arguments (note: all
%vectors must be _column_ vectors and not row vectors; vecvalder DOES NOT WORK
%for general matrix functions of matrix arguments). Here is an example:
%
% A = [1 2 3 4 5; 6 7 8 9 10];    % A is a 2x5 matrix
% myfn = @(x) A*x + [11; 12];    % defines a vector function: R^5 -> R^2
%
% x = (1:5).'; % size 5 input vector: [1;2;3;4;5] = [x1;x2;x3;x4;x5];
%
% vvx = vecvalder(x, 'indep');    % make a vecvalder object of x, with value
%                               % [1;2;3;4;5]; and make each entry an 
%                                % independent variable for the purposes of
%                                % differentiation -- ie, each one of x(1), 
%                                % x(2), ..., x(5) is an independent variable.
% vvx % display vvx
%
% vvy = myfn(vvx);        % running myfn() on vvx now computes
%                       % derivatives of each of the two outputs with respect 
%                        % to each of the five independent variables.
%                       % [Note that myfn should only contain primitive
%                       % operations that are supported by vecvalder (see 
%                       % the list below); many matrix/vector operations are
%                       % not supported yet.]
% vvy % display vvy 
%                       % vvy is a vecvalder object, with the der 
%                       % component containing the numerical values of the
%                       % derivatives as a 2x5 matrix.
% %now pick out the function values and the derivatives.
% y = val(vvy);            % a size-2 column vector with the values
% JacobianMatrix = jac(vvy) % the derivatives (Jacobian matrix) wrt 
%                           % the independent variables. Retains sparsity
%                            % if there is sparse dependence.
%
%
%
%More examples of the use of vecvalder
%-------------------------------------
%
%Further simple examples and tests can be found under the vecvalder/tests/
%directory (under your top-level MAPP installation directory).
%You can run all these tests using the MAPP command
%
% run_ALL_vecvalder_tests()
%
%More complicated examples of vecvalder, for finding derivatives of functions
%with many arguments, can be found in the files:
%  ModSpec-MATLAB/d*_d*_auto.m (eg, ModSpec-MATLAB/dfe_dvecX_auto.m)
%and
%  DAEAPI-MATLAB/d*_d*_DAEAPI_auto.m (DAEAPI-MATLAB/df_dx_DAEAPI_auto.m)
%  
%
%
%
%How vecvalder works
%-------------------
% A vecvalder variable is essentially a matrix (vv1 stores it internally
% as a cell array). The first col is the value of the variable. The remaining
% columns contain derivatives with respect to any number of independent
% variables.
%
% operators and functions -- such as +, -, *, /, =, exp(), sin(), cos(), 
% tan(), etc. -- are overloaded in the vecvalder class so that they work not
% only on on the values, but also compute the derivatives at the same time,
% using the chain rule for differentiation.
%
% TODO: illustrate with a simple example.
%
% For more information on automatic differentiation, see
%
% - Richard D. Neidinger, "Introduction to Automatic Differentiation
%   and MATLAB Object-Oriented Programming", SIAM Review, Vol. 52, No. 3,
%   pp. 545–563, 2010.
%   - available at http://www.davidson.edu/math/neidinger/SIAMRev74362.pdf.
%
% - http://www.autodiff.org/
%
%Implementations of vecvalder
%----------------------------
%
%vv1 is built on top of the @valder package by Richard D. Neidinger. See:
%---
% - Richard D. Neidinger, "Introduction to Automatic Differentiation
%   and MATLAB Object-Oriented Programming", SIAM Review, Vol. 52, No. 3,
%   pp. 545–563, 2010.
%   - available at http://www.davidson.edu/math/neidinger/SIAMRev74362.pdf.
%
% - vv1 Authors
%   -----------
%   - TODO: Bichen, Aadithya, etc.: add your names if you have made
%           contributions
%   - Tianshi Wang <tianshi@berkeley.edu> (small improvements, implemented
%           cross, dot, min, max, abs, length, etc. 2012-present)
%   - Jaijeet Roychowdhury <jr@berkeley.edu> (misc improvements, 2011-present)
%   - David Amsallem <amsallem@berkeley.edu> (original version, ~2011/10/01)
%
% - Functions currently supported by vv1
%   ------------------------------------
%   - vecvalder(...) - constructor
%   - display
%   - double
%   - exp
%   - log
%   - log10
%   - minus, uminus
%   - plus, uplus
%   - mpower
%   - power (soft link to mpower, needs fixing)
%   - mrdivide - 1/vv - probably needs fixing
%   - rdivide (soft link to mrdivide, may need fixing)
%   - times (vv/num .* vv/num) - just calls mtimes, may need fixing
%   - mtimes (A*vv)
%   - sin
%   - asin
%   - cos
%   - tan
%   - atan
%   - cosh
%   - tanh
%   - asinh
%   - uminus
%   - sqrt
%   - dot
%   - cross
%   - logical
%   - eq (==)
%   - ne (~=)
%   - gt (>)
%   - lt (<)
%   - ge (>=)
%   - le (<=)
%   - and (&)  - derivative irrelevant (just to support vvs in boolean tests)
%   - or (|)   - derivative irrelevant (just to support vvs in boolean tests)
%   - mod(a,b) - not a differentiable function, but the derivatives 
%                should be correct at values of a, b where differentiable.
%   - numel
%   - subsref
%   - subsasgn
%   - vertcat
%   - abs      - derivative at 0 forced to be 0
%   - sign     - derivative at 0 forced to be 0
%   - max(a,b) - defined as 0.5*(abs(a-b) + a + b)
%   - min(a,b) - defined as 0.5*(-abs(a-b) + a + b)
%   - val()
%   - jac()
%   - val2mat() - same as val(), for backward compatibility
%   - der2mat() - same as jac(), for backward compatibility
%   - get()
%   - set()
%
%
%vv2 was written from scratch to attempt to fix the extreme slowness of vv1.
%---
% - It uses a matrix, vv2.valder, to store the vector and Jacobian matrix (vv1
%   uses a cell array and calls num2cell, cell2mat, etc, which are very slow).
%
% - The Jacobian matrix in x.valder is NOT stored sparsely. This is to avoid
%   the overhead inherent in representing small matrices sparsely. valder,
%   though dense, should be efficient for small (size 2-3) vecvalder because
%   the underlying computations should be BLAS-accelerated by matlab.
%
% - Speedup/cleanliness changes:
%   - avoids using repmat (very slow); instead uses diag() and matrix mult
%   - avoids calling the constructor (many checks) in overloaded functions
%   - repeats code if necessary to avoid function calls (slower)
%   - avoids using function handles (slower than calling functions directly)
%   - matrix/vector operations are used as much as possible.
%   - minimal argument type/size checking in overloaded functions (for speed)
%     - tries to rely on the corresponding builtin numeric functions for checks
%
% - vv2 Authors
%   -----------
%   - Jaijeet Roychowdhury <jr@berkeley.edu> (2014/06/16-19)
%   - Karthik Aadithya <aadithya@berkeley.edu> (started vv2, 2014/06/14-15)
%
% - Functions currently supported by vv2
%   ------------------------------------
%   - vecvalder - constructor - Aadithya, 2014/06/14
%   - display   - JR, 2014/06/16
%   - double    - JR, 2014/06/16
%   - exp       - Aadithya, 2014/06/14
%   - log       - Aadithya, 2014/06/14; cleaned up: JR, 2014/06/16.
%   - log10     - JR, 2014/06/16
%   - minus     - JR, 2014/06/16
%   - plus      - JR, 2014/06/16
%   - uminus    - JR, 2014/06/16
%   - uplus     - JR, 2014/06/16
%   - mpower    - JR, 2014/06/16
%   - power     - JR, 2014/06/16
%   - mrdivide  - JR, 2014/06/16
%   - rdivide   - JR, 2014/06/16
%   - mtimes    - JR, 2014/06/16
%   - times     - JR, 2014/06/16
%   - sin       - JR, 2014/06/16
%   - cos       - JR, 2014/06/16
%   - tan       - JR, 2014/06/16
%   - asin      - JR, 2014/06/16
%   - atan      - JR, 2014/06/16
%   - cosh      - JR, 2014/06/16
%   - tanh      - JR, 2014/06/16
%   - asinh     - JR, 2014/06/16
%   - sqrt      - JR, 2014/06/16
%   - dot       - JR, 2014/06/16
%   - cross     - JR, 2014/06/17
%   - logical   - JR, 2014/06/17 (derivatives ignored)
%   - eq (==)   - JR, 2014/06/17 (derivative equality _is_ checked)
%   - ne (~=)   - JR, 2014/06/17 (derivative equality _is_ checked)
%   - gt (>)    - JR, 2014/06/17 (derivatives ignored)
%   - lt (<)    - JR, 2014/06/17 (derivatives ignored)
%   - ge (>=)   - JR, 2014/06/17 (derivatives ignored)
%   - le (<=)   - JR, 2014/06/17 (derivatives ignored)
%   - and (&)   - JR, 2014/06/17 (derivatives ignored)
%   - or (|)    - JR, 2014/06/17 (derivatives ignored)
%   - mod(a,b)  - JR, 2014/06/17 not a differentiable function, but the 
%                 derivatives should be correct at values of a, b where
%                 mod is differentiable.
%   - numel     - JR, 2014/06/18; (needed for subsref{1:5} to work right)
%   - subsref   - JR, 2014/06/18 
%   - subsasgn  - JR, 2014/06/18 
%   - vertcat   - JR, 2014/06/18 
%   - horzcat   - JR, 2014/06/18 (horzcat is disabled, this emits an error)
%   - abs       - JR, 2014/06/18 (derivative at 0 defined as 0)
%   - sign      - JR, 2014/06/18 (derivative at 0 defined as 0)
%   - sign2     - JR, 2014/06/18 (derivative at 0 defined as 0)
%   - max(a,b)  - JR, 2014/06/18
%   - min(a,b)  - JR, 2014/06/18
%   - val()     - JR, 2014/06/18 - just a soft link to val2mat
%   - jac()     - JR, 2014/06/18 - just a soft link to der2mat
%   - valjac()  - JR, 2014/06/18 - just a soft link to valder
%   - valder()  - JR, 2014/06/18
%   - val2mat() - Aadithya, 2014/06/14. minor updates, JR 2014/06/18.
%                 - using val2mat() deprecated in favour of val()
%   - der2mat() - Aadithya, 2014/06/14. minor updates, JR 2014/06/18.
%                 - using der2mat() deprecated in favour of jac()
%   - get()     - JR, 2014/06/18
%   - set()     - JR, 2014/06/18
%   - length()  - Tianshi, 2014/08/06
%
%vecvalder test suite
%--------------------
%  - test_vecvalder_constructor     - JR, 2014/06/18
%  - test_vecvalder_exp             - JR, 2014/06/18
%  - test_vecvalder_log             - JR, 2014/06/18
%  - test_vecvalder_log10           - JR, 2014/06/18
%  - test_vecvalder_minus           - JR, 2014/06/18
%  - test_vecvalder_plus            - JR, 2014/06/18
%  - test_vecvalder_uminus          - JR, 2014/06/18
%  - test_vecvalder_uplus           - JR, 2014/06/18
%  - test_vecvalder_mpower          - JR, 2014/06/18
%  - test_vecvalder_power           - JR, 2014/06/18
%  - test_vecvalder_mrdivide        - JR, 2014/06/18
%  - test_vecvalder_rdivide         - JR, 2014/06/18
%  - test_vecvalder_mtimes          - JR, 2014/06/18
%  - test_vecvalder_sin             - JR, 2014/06/18
%  - test_vecvalder_cos             - JR, 2014/06/18
%  - test_vecvalder_tan             - JR, 2014/06/18
%  - test_vecvalder_asin            - JR, 2014/06/18
%  - test_vecvalder_atan            - JR, 2014/06/18
%  - test_vecvalder_cosh            - JR, 2014/06/18
%  - test_vecvalder_tanh            - JR, 2014/06/18
%  - test_vecvalder_asinh           - JR, 2014/06/18
%  - test_vecvalder_sqrt            - JR, 2014/06/18
%  - test_vecvalder_dot             - JR, 2014/06/18
%  - test_vecvalder_cross           - JR, 2014/06/18
%  - test_vecvalder_logical         - JR, 2014/06/18
%  - test_vecvalder_eq              - JR, 2014/06/18
%  - test_vecvalder_ne              - JR, 2014/06/18
%  - test_vecvalder_gt              - JR, 2014/06/18
%  - test_vecvalder_lt              - JR, 2014/06/18
%  - test_vecvalder_ge              - JR, 2014/06/18
%  - test_vecvalder_le              - JR, 2014/06/18
%  - test_vecvalder_and             - JR, 2014/06/18
%  - test_vecvalder_or              - JR, 2014/06/18
%  - test_vecvalder_mod             - JR, 2014/06/18
%  - test_vecvalder_subsref         - JR, 2014/06/18
%  - test_vecvalder_subsasgn        - JR, 2014/06/18
%  - test_vecvalder_vertcat         - JR, 2014/06/18
%  - test_vecvalder_abs             - JR, 2014/06/18
%  - test_vecvalder_sign            - JR, 2014/06/18
%  - test_vecvalder_sign2           - JR, 2014/06/18
%  - test_vecvalder_max             - JR, 2014/06/18
%  - test_vecvalder_min             - JR, 2014/06/18
%
%Shortcomings of vecvalder (and some workarounds)
%------------------------------------------------
%
%The vv1 and vv2 implementations of vecvalder have a number of shortcomings:
%    ---
%  - it does not work for general matrix functions of matrix arguments
%    - (for it to do so, MAPP would need tensor support, currently lacking)
%  - some matrix/vector-specific operations do not work directly on vecvalder
%     objects. For example:
%    n = 5; x = vecvalder((1:n).', 'indep');
%    x.' % does not work
%    x'  % does not work
%    sum(x) % does not work
%    reshape(x, n, m) % does not work
%    norm(x) % this does not work; implement it with elementary operations as
%    y=vecvalder(0);
%    for i=1:n
%       y = y + x(i)^2;
%    end
%    val(y) % returns 55
%    jac(y) % returns [2, 4, 6, 8, 10] = [dy/dx1, dy/dx2, ..., dy/dx5]
%
%  - the * operation between two vecvalders is always interpreted as .* 
%    x*x % works, returns x.*x. It would not work for a regular numeric vector
%    
%  - vecvalder is much slower than derivative code written by hand (estimated
%    5-6x slower than well-written hand-derived code). This is due in
%    part to MATLAB's intrinsic lack of pointers and its dependence on
%    interpreted code.
%    
%  % caution: the following will not work properly
%  z(1) = 0; % z will be created as double
%  z(2) = y; % y is a vecvalder, but double.subsasgn will be called for z(2)
%        % and it does not know how to deal with a vecvalder RHS
%        % there will be a Subscripted Assignment Dimension Mismatch error.
%  % The proper fix is to overload double.subsasgn to handle vecvalder RHS; 
%  % But this has not been done yet. 
%  % 
%  % For the moment there are a couple of workaround methods:
%  % 1. initiate z as a vecvalder first:
%       z = y; % create z as a vecvalder using this
%       z = 0; % now vecvalder.subsasgn is called for z(2) and it deals with
%           % a double RHS correctly.
%  % 2. exchange asignment orders of elements:
%       z(2) = y;
%       z(1) = 0;
%       % by asigning value to z(2) first, z is initiated as a vecvalder object
%
%Special features of vecvalder
%-----------------------------
%
% 1. convert a vecvalder object into a cell array of scalar vecvalders:
% [TODO]: EXAMPLES OF WHY THIS IS USEFUL
%
%  vv_cell = y{1:n} % or y{:}; vv_cell is a cell array
%  y_three = vv_cell{3}; % third entry of vv y 
%
%
%See also
%--------
%
% [TODO]
