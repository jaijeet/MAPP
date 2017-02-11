%
% For better presentation of this document, run:
% >> doc NRinitlimiting
% 
% Initialization and limiting are convergence aiding techniques specific to the
% Newton Raphson algorithm. They are implemented in SPICE and many other
% circuit simulators. Here we illustrate its implementation in MAPP:
%
% 0. The Newton Raphson algorithm:
%
%    Before discussing init/limiting, we first look at the basic NR iteration:
%       delta_x = - df(x_i) \ f(x_i) 
%       x_{i+1} = x_i + delta_x
%
%    See a demo of NR by copying and pasting the code section below into your
%    Matlab command window, 
%
% %-------------------------------- CODE ---------------------------------------
% % Consider a diode whose current can be calculated as Id = IS*(exp(Vd/VT)-1).
% % Drive this diode with a current source of 1A such that Id=1A, solve for Vd. 
% % The equation to solve for the DC operating point of this circuit will be
% % f(x) = IS*(exp(Vd/VT)-1) - 1 = 0.
%
% args.VT = 0.025;
% args.IS = 1e-12;
% f_handle = @(x, args) args.IS * (exp(x/args.VT)-1) - 1;
% df_handle = @(x, args) args.IS/args.VT * exp(x/args.VT);
%
% % plot f(x) = IS*(exp(Vd/VT)-1) - 1
% xs = 0.4:0.001:0.75;
% fs = f_handle(xs, args);
% figure;
% plot(xs, fs); hold on; line([0.4, 0.8], [0, 0], 'Color', 'k');
% xlabel('x'); ylabel('f(x)');
%
% % through inspection, solution is around 0.69
%
% % solve the equation using NR from initial guess 0.65
% sol = NR(f_handle, df_handle, 0.65, args)
%
% % show more detail about the progress of NR
% NRparms = defaultNRparms;
% NRparms.dbglvl = 2;
% [sol, iters, success, allNRpts] = NR(f_handle, df_handle, 0.65, args, NRparms);
% 
% % plot points of all iterations
% all_pts = allNRpts.allpts;
% all_fs = f_handle(all_pts, args);
% for c = 1:length(all_pts)-1
%     stem(all_pts(c), all_fs(c), 'Color', 'r');
%     line([all_pts(c), all_pts(c+1)], [all_fs(c), 0], 'Color', 'r');
% end
% %-----------------------------------------------------------------------------
% 
%    However, NR is not guaranteed to work. For the same diode equation, if we
%    start from an initial guess farther away from the final solution, NR may
%    not converge to the solution.
%
% %-------------------------------- CODE ---------------------------------------
% % initial guess == 0.6
% sol = NR(f_handle, df_handle, 0.6, args)
% % initial guess == 0.5
% sol = NR(f_handle, df_handle, 0.5, args)
% %-----------------------------------------------------------------------------
%
%
% 1. How init/limiting works (at a glance):
%
%    The main reason for the convergence failure in the diode example is
%    because exp() function doesn't have good numerical properties: when its
%    argument is too large, its output may overflow, or become 'Inf' in Matlab;
%    when its argument is too small, its derivative is also too small,
%    resulting in devision by small numbers in NR.
%
%    Let's run NR step by step to take a look at why NR fails with initial
%    guess 0.5
%
% %-------------------------------- CODE ---------------------------------------
% % run NR step by step
% x0 = 0.5;
% f0 = f_handle(x0, args);
% df0 = df_handle(x0, args);
% x1 = x0 - f0/df0
% f1 = f_handle(x1, args)
% % x1 is too large as the voltage across a diode, causing f_handle not to
% % evaluate properly
% %-----------------------------------------------------------------------------
%
%    Based on the observation above, two methods can aid convergence in this
%    example:
%    1) Initialization: start from a better x0, say 0.6 or 0.65;
%    2) Limiting: when NR updates its guess to x1, don't directly use it, but
%         use a limiting function to calculate a new x1lim based on both x1
%         (suggested NR guess) and x0 (the old value from last iteration) for
%         use in the next NR update.
%
%    The choice of limiting functions is more an art than a technique. For
%    diode equations, pnjlim() is commonly used.
% 
% %-------------------------------- CODE ---------------------------------------
% % run NR step by step
% x0 = 0.5;
% x0lim = x0; % no limiting for x0
% f0lim = f_handle(x0lim, args);
% df0lim = df_handle(x0lim, args);
% x1 = x0lim - f0lim/df0lim
% % x1 is the suggested NR guess, but instead of using it directly, an updated
% % x1lim is calculated using pnjlim and used in f/df evaluations
% VT = args.VT; IS = args.IS;
% VCRIT = VT*log(VT/(sqrt(2)*IS));
% x1lim = pnjlim(x0lim, x1, VT, VCRIT)
% f1lim = f_handle(x1lim, args);
% df1lim = df_handle(x1lim, args);
% x2 = x1lim - f1lim/df1lim
% % x2 is already very close to final solution and the numerical explosion in
% % exp() is avoided by limiting
% %-----------------------------------------------------------------------------
%
%
% 2. Formulate init/limiting mathematically:
%
%    As seen from the last example, limiting functions update NR guesses before
%    using them to evaluate flim/dflim. But several points are worth mentioning
%    before generalizing the technique in the example into NR algorithm:
%
%    a) Instead of substituting x1 completely with x1lim, x1lim and x1
%       are sometimes both used in f1lim/df1lim evaluations.
%
%       e.g. consider changing the diode system to include a resistor (1 Ohm)
%       connected with the diode in parallel. The diode and resistor are drived
%       together with the 1A source as usual. Then the equation to solve
%       becomes:
% 
%       f(x) = diode_Id(x) + x - 1 = 0
%
%       In this way, when evaluating f1lim/df1lim with limiting, x1lim may be
%       used in diode_Id(), but the resistor part of the equation can still use
%       the "unlimited" x1.
%
%    b) When the x1 is a vector, x1lim may not substitute all elements of x1.
%
%       e.g. suppose the diode in the example is just a part of the large
%       circuit with multiple unknowns, x0, x1 and so on are thus vectors and
%       x1lim may be dependent on only one element of x1:
% 
%       >> x1lim = pnjlim(x0lim, x1(some_index), VT, VCRIT);
%
%       It is also possible that x1lim is calculated using some combination of
%       elements of x1:
% 
%       >> x1lim = pnjlim(x0lim, x1(some_index1)-x1(some_index2), VT, VCRIT);
%
%    c) x1lim can also be a vector.
%
%       e.g. consider two diodes of different sets of parms connected in
%       parallel. The equation to solve becomes:
%
%       f(x) = diode_Id1(x) + diode_Id2(x) - 1 = 0
%
%       When limiting is used in f1/df1, different limiting functions (pnjlims
%       with different parms) are used:
%       >> x1lim1 = pnjlim(x0lim1, x1, VT1, VCRIT1);
%       >> x1lim2 = pnjlim(x0lim2, x1, VT2, VCRIT2);
%       then
%       >> f1lim = diode_Id1(x1lim1) + diode_Id2(x1lim2) - 1;
%       >> df1lim = diode_Gd1(x1lim1) + diode_Gd2(x1lim2);
%
%    In summary of a) b) c), at the {i+1}th NR iteration (i.e. when evaluating
%    flim_{i}/dflim_{i}), a vector of limited variables xlim_{i} can be
%    calculated from x_{i} and xlim_{i-1}, then both x{i} and xlim_{i} are used
%    to evaluate flim_{i}/dflim_{i}.
%
%    Limited variables (xlim) can be voltages across PN junctions, voltages
%    across MOSFETs' drains and sources, or whatever unknown variables that are
%    inputs to highly non-linear functions. Such non-linear functions normally
%    have poor numerical properties beyond a certain input range. By specifying
%    their inputs to be limited variables (xlim) and provide limiting functions
%    to recalculate xlim from NR guesses and their old values of the last
%    iteration, the chances of encountering numerical hazards are reduced.
%    This is the mechanism of limiting.
%
%    Limited variables, being voltages in most occasions, are assumed to be
%    subset of the unknowns or linear combinations of unknowns in the
%    equations. Therefore, when limiting is not in effect, the relationship
%    between xlim and x of the equation system can be expressed as a linear
%    matrix multiplication:
%
%    xlim = xTOxlimMatrix * x;
%
%    In this way, flim(x, xlim) is a variant of the f(x) we originally want to
%    solve. It takes both x and xlim as inputs and has very similar functions
%    as f(x), except that it substitutes inputs to highly non-linear functions'
%    (like diode_Id) inputs with xlim. If implemented correctly, flim(x, xlim)
%    should be equivalent to f(x) when limiting is not in effect, i.e. the
%    following must be satisfied:
%
%    flim(x, xTOxlimMatrix * x) == f(x)
%
%    Then an NR iteration with limiting can be expressed as:
%       xlim_{i} = limiting(x_{i}, xlim_{i-1})
%       delta_x = - dflim(x_{i}, xlim_{i}) \ flim(x_{i}, xlim_{i}) 
%       x_{i+1} = x_{i} + delta_x
%
%    where dflim(x_{i}, xlim_{i}) is a variant of df(x). Note that dflim(x,
%    xlim) is a function with two vector inputs, indicating it actual
%    derivatives consist of two partial derivatives: dflim/dx(x, xlim) and
%    dflim/dxlim(x, xlim). Here we define dflim(x, xlim) as
%
%    dflim(x, xlim) = dflim/dx(x, xlim) + dflim/dxlim(x, xlim) * xTOxlimMatrix 
%
%    such that when there is no limiting, the following is satisfied:
%
%    dflim(x, xTOxlimMatrix * x) == df(x)
%
%    At the first iteration, i = 0, no old limited variable values xlim_{-1}
%    are available and limiting function is not applicable, so xlim_{0} can be
%    calculated without limiting:
%    xlim_{0} = xTOxlimMatrix * x_{0};
%
%    Note that with bad choice of x_{0}, it is not guaranteed that xlim_{0}
%    calculated in this way results in good numerical properties in
%    flim/dflim(x, xlim). This observation leads to the understanding of
%    another convergence aiding technique: initialization.
%
%    Initialization provides xlim_{0}. For example, in the diode scenario it
%    sets xlim_{0} for the PN junction voltage to start at value VCRIT ~ 0.615
%    at the beginning of NR. From the next iteration, limiting function pnjlim
%    will be in effect for the diode function. So instead of letting the PN
%    junction voltage unknown jumping freely across the real axis,
%    initialization and limiting makes it more likely to stay within reasonable
%    range such that numerical hazards won't occur.
%
% 3. SPICE's NR and init/limiting implementation:
%    
%    It is worth mentioning that SPICE uses another form of NR algorithm. In
%    SPICE's NR iteration, instead of calculating delta_x, it calculates NR
%    guesses directly through a function called Right Hand Side (RHS) vector.
%
%    SPICE's NR iteration:
%       x_{i+1} = df(x_{i}) \ RHS(x_{i}) 
%
%    When there is no init/limiting, RHS is equivalent to
%    RHS(x) = df(x) * x - f(x)
%
%    When using init/limiting,
%    RHSlim(x) = dflim/dx(x,xlim)*x + dflim/dxlim(x,xlim)*xlim - flim(x,xlim)
%
% 4. Implementation in MAPP using Algebraic Function (AF) object:
%
%    Based on the discussion in the above sections, when NR is solving
%    non-linear equation f(x) = 0, it requires function handles that return
%    f(x), df(x), RHS(x). And when init/limiting is in effect, f/df/RHS should
%    be substituted with flim/dflim/RHSlim and the extra input xlim should be
%    calculated using initialiation of limiting functions. In the case of
%    limiting, xlim's old value, namely xlim_{i-1} or xlimOld, is needed for
%    the evaluation of limiting functions, and the current xlim should be
%    recorded and later be used in the next iteration.
%
%    In MAPP, We would like these procedures to happen in a more automatic
%    manner. For this purpose, instead of providing NR algorithm with only two
%    function handles: f and df, we provide NR with an object enclosing function
%    handles f/df/RHS together with all the data they need to evaluate, e.g.
%    xlimOld. This object is named Algebraic Function object, or in short AFobj.
%    An AF object should contain the following fields:
%
%    - f, df, RHS and function handles for returning combinations of them
%    - do_init and do_limit: flags to turn init/limiting on and off when
%        evaluating f/df/RHS
%    - xlimOld: data member to store old values of xlim
%    - access functions for flags and data members:
%        set_init, set_limit, get_init, get_limit, set_xlimOld, get_xlimOld,
%        etc.
%
%    For a complete description of AF object, run
%
% %-------------------------------- CODE ---------------------------------------
% help AlgebraicFunction
% %-----------------------------------------------------------------------------
%
%    The block of code below uses AF object to solve the same diode example in
%    Section 0.
%
% %-------------------------------- CODE ---------------------------------------
% AFO = AlgebraicFunction_skeleton();
% 
% % let this AF represent the same diode function
% AFO.n_unks = 1;
% AFO.n_eqns = 1;
% AFO.n_limitedvars = 0;
% VT = 0.025;
% IS = 1e-12;
% diode_Id = @(Vd) IS * (exp(Vd/VT)-1);
% diode_Gd = @(Vd) IS/VT * exp(Vd/VT);
%
% AFO.f_df_rhs = @(x, args) deal(diode_Id(x) - 1, ...
%         diode_Gd(x), ...
%         diode_Gd(x) * x - diode_Id(x) + 1, ...
%         [], 1);
% 
% % use NR to solve for the solution
% NRparms = defaultNRparms;
% NR(AFO, NRparms, 0.65)
% %-----------------------------------------------------------------------------
%
%    Without init/limiting, with an initial guess farther away from solution,
%    NR will fail just the same as in Section 0.
%
% %-------------------------------- CODE ---------------------------------------
% % use NR to solve for the solution from another initial guess
% NR(AFO, NRparms, 0.5)
%
% % like the previous demo, NR fails when there is no init/limiting
% %-----------------------------------------------------------------------------
% 
%    The block of code below updates AF object with limiting to aid convergence
%    in NR algorithm.
% 
% %-------------------------------- CODE ---------------------------------------
% % update AF object to use limiting, e.g. pnjlim
% AFO.n_limitedvars = 1;
% 
% VCRIT = VT*log(VT/(sqrt(2)*IS));
% AFO.f_df_rhs = @(x, args) deal(diode_Id(pnjlim(args.xlimOld, x, VT, VCRIT)) - 1, ...
%         diode_Gd(pnjlim(args.xlimOld, x, VT, VCRIT)), ...
%         diode_Gd(pnjlim(args.xlimOld, x, VT, VCRIT)) * pnjlim(args.xlimOld, x, VT, VCRIT) ...
%         - diode_Id(pnjlim(args.xlimOld, x, VT, VCRIT)) + 1, ...
%         pnjlim(args.xlimOld, x, VT, VCRIT), 1);
%
% % use NR to solve for the solution from initial guess where it failed previously
% NR(AFO, NRparms, 0.5)
%
% % use NR to solve for the solution from an even "worse" initial guess
% NR(AFO, NRparms, 0)
% %-----------------------------------------------------------------------------
%
%    Note that here we are hand-coding the AF object with limiting function
%    built inside its f/df/RHS evaluations. In this case limiting can't be
%    turned off. In MAPP, AF object is usually set up by calling DAE's f/q and
%    limiting functions based on the analysis' type (DC, TRAN, etc.). It can
%    also turn init/limiting on and off based on its do_init and do_limit
%    flags.
%
%    With AF object, a standard NR iteration with init/limiting can be
%    implemented in MAPP as
%
%    pseudo code:
%        [fx, dfx, xlimOld, evalsuccess] = feval(AFobj.f_and_df, x, AFobj); 
%            % xlimOld is the xlim that has been used in this f/df evaluation
%        AFobj = feval(AFobj.set_xlimOld, xlimOld, AFobj);
%        x = x + -dfx\fx; iter = iter+1;
%       
%        if is_first_iter % init is not valid after first iter
%            AFobj = feval(AFobj.set_init, 0, AFobj);
%        end
%
%    With AF object, a SPICE's RHS-NR iteration with init/limiting can be
%    implemented in MAPP as
%
%    pseudo code:
%        [fx, dfx, rhsx, xlimOld, evalsuccess] = feval(AFobj.f_df_rhs,x,AFobj);
%            % xlimOld is the xlim that has been used in this evaluation
%        AFobj = feval(AFobj.set_xlimOld, xlimOld, AFobj);
%        x = rhsx\fx; iter = iter+1;
%       
%        if is_first_iter % init is not valid after first iter
%            AFobj = feval(AFobj.set_init, 0, AFobj);
%        end
%
% 5. DAE with init/limiting:
%
%    Recall that DAEAPI MAPP's way of specifying a DAE, especially its f and q
%    function fields. DAE's f normally takes x and u as inputs while q takes x
%    as input. To supply AF object with information on init/limiting, a few
%    fields have to be updated in a DAEAPI object.
%
%    For more detailed information about DAEAPI, help DAEAPI.
%
%    5.0 DAE.support_initlimiting flag has to be turned on (=1).
%        once it's on, a few API functions shown below should be provided or
%        updated
%
%    5.1 DAE.limitedvarnames, return limited variables' names.
%        DAE.nlimitedvars, return number of limited variables.
%
%    5.2 DAE.xTOxlim (function handle), convert unknowns x to limited variables
%            xlim when init/limiting is not in effect.
%            By default, this is equivalent to xlim = xTOxlimMat * x.
%
%        DAE.xTOxlimMatrix (function handle), returns the matrix that can
%            convert x to xlim.
%
%    5.3 DAE.NRlimiting (function handle), limiting function.
%            Use: dxlimNewdx = feval(DAE.NRlimiting, x, xlimOld, u, DAE);
%
%        DAE.dNRlimiting_dx (function handle).
%
%    5.4 DAE.NRinitGuess (function handle), returns initialiation values based
%            on u.
%            Use: xlimInit = feval(DAE.NRinitGuess, u, DAE);
%
%    5.5 DAE.f and q will be able take an extra input xlim, whose elements
%        correspond to DAE.limitedvarnames.
%
%    The block of code below creates a DAE object with init/limiting support
%    and exercises some of the init/limiting-related fields.
%
% %-------------------------------- CODE ---------------------------------------
% % create a DAE for a full wave rectifier with four diodes 
% DAE =  MNA_EqnEngine(fullWaveRectifier_ckt());
%
% % display name of DAE's input
% DAE.inputnames(DAE)
%
% % set DAE's input to be 5V
% uDC = 5;
% DAE = DAE.set_uQSS(uDC, DAE);
%
% % perform DC analysis
% dcop = op(DAE);
% dcop.print(dcop);
% qssSol = dcop.getSolution(dcop);
%
% % display names of DAE's limited variables
% DAE.limitedvarnames(DAE)
% 
% % display initial guesses for DAE's limited variables
% DAE.NRinitGuess(DAE.uQSS(DAE), DAE)
%
% % display the matrix that converts x to xlim
% DAE.xTOxlimMatrix(DAE)
%
% % convert x to xlim at DC solution
% xlim = DAE.xTOxlim(qssSol, DAE)
% % Note that these are the voltages across 4 PN junctions at DC operating
% % point
% %-----------------------------------------------------------------------------
%
%
% 6. ModSpec with init/limiting:
%
%    When using an equation engine to build up a DAE with init/limiting
%    support. DAE's init/limiting-related fields (NRlimiting, NRinitGuess,
%    limitedvarnames) have to be constructed from extracting information from
%    the ModSpec devices. For ModSpec to provide such information, a few fields
%    have to be updated.
%
%    For information about init/limiting in ModSpec, help ModSpecAPI and see
%    Section: init/limiting support.
%
%See also
%--------
%
% NR, AlgebraicFunction
% QSS, LMS
% DAEAPI, ModSpecAPI
