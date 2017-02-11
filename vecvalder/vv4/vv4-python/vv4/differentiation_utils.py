
import math
from .DAG_utils import topological_sort

def differentiate(deps, num_indep_variables, dmap, vv4_nm):

    """
    This function differentiates a set of functions with respect to a bunch of 
    independent variables.

    Description of inputs:

        * deps is a list of _vv4_Node objects representing the functions to be
          differentiated

        * num_indep_variables denotes the number of independent variables with 
          respect to which the differentiation is needed

        * dmap is a dictionary that provides the derivatives of a bunch of 
          independent nodes with respect to the independent variables, so that 
          these derivatives can then be propagated forward. That is, dmap maps 
          independent _vv4_Nodes u to lists of _vv4_Nodes l, where l is the list 
          of derivatives of u with respect to the independent variables.
          
          Note: if the dependent variables are found to ultimately depend on 
          some independent _vv4_Node that does *not* have an entry in dmap, the 
          derivatives of this independent _vv4_Node are assumed to be zero wrt 
          each independent variable above.

    Given the above, this function returns a list of lists l, where:

        * l is a list of len(deps) lists, where l[i] is a list of _vv4_Nodes 
          representing the derivatives of deps[i] with respect to the 
          independent variables above.

    Note: This function modifies dmap significantly. It's best you get rid of 
    dmap after calling this function.

    """

    # define constants
    constants = { s: vv4_nm.get('CONST', 'FLOAT', v) for s, v in 
                     [ ('minus_one', -1.0), ('zero', 0.0), ('one', 1.0), 
                       ('two', 2.0), ('log10', math.log(10)) ] }

    # do a topological sort
    topological_order = topological_sort(deps, vv4_nm)

    # differentiate nodes in topological order
    for u in topological_order:
        _differentiate_node(u, num_indep_variables, dmap, constants, vv4_nm)

    # collect the derivatives and return them
    return [dmap[u] for u in deps]


def _differentiate_node(u, num_indep_variables, dmap, constants, vv4_nm):

    """
    u is a _vv4_Node object to be differentiated wrt a list of independent 
    variables.

    num_indep_variables is the number of independent variables that u is being 
    differentiated wrt to.
    
    dmap is a dictionary that maps _vv4_Nodes v to lists of _vv4_Nodes l, where
    the nodes in l represent the derivatives of v with respect to the
    independent variables. The idea is that the children of u have already been 
    differentiated wrt these independent variables and the results of this 
    differentiation are already in dmap. 
    
    constants is a dictionary that maps strings to appropriate _vv4_Nodes. It 
    is assumed that constants['zero'], constants['one'], constants['two'], 
    constants['minus_one'], and constants['log10'] have already been defined 
    and mapped to constant _vv4_Nodes corresponding to 0.0, 1.0, 2.0, -1.0, and 
    log_{e}(10) respectively.

    Note: this function does not return the computed derivatives of u. Instead, 
    it puts them in dmap.
    """
    
    if u in dmap:
        return

    minus_one, zero, one, two, log10 = [constants[x] for x in ('minus_one', 'zero', 'one', 'two', 'log10')]

    if not vv4_nm.is_func(u):
        dmap[u] = [zero]*num_indep_variables
        return

    op, children = vv4_nm.get_op(u), vv4_nm.get_children(u)
    x, dx = children[0], dmap[children[0]]
    if len(children) > 1:
        y, dy = children[1], dmap[children[1]]
        if len(children) > 2:
            z, dz = children[2], dmap[children[2]]


    def mult(u, l):
        # u is a single _vv4_Node, l is a list of _vv4_Nodes
        return [vv4_nm.get('FUNC', 'MTIMES', u, v) for v in l]


    if op in ['SIGN', 'SIGN2', 'AND', 'OR', 'GT', 'LT', 'GE', 'LE', 'EQ', 'NE', 'STRCMP', 'STRCMPI']:
        dmap[u] = [zero]*num_indep_variables

    elif op == 'ABS':
        dmap[u] = mult(vv4_nm.get('FUNC', 'ITE', vv4_nm.get('FUNC', 'GT', x, zero), one, minus_one), dx)

    elif op == 'SIN':
        dmap[u] = mult(vv4_nm.get('FUNC', 'COS', x), dx)

    elif op == 'COS':
        dmap[u] = mult(vv4_nm.get('FUNC', 'UMINUS', vv4_nm.get('FUNC', 'SIN', x)), dx)

    elif op == 'TAN':
        dmap[u] = mult(vv4_nm.get('FUNC', 'PLUS', one, vv4_nm.get('FUNC', 'MTIMES', u, u)), dx)

    elif op == 'ASIN':
        dmap[u] = mult(vv4_nm.get('FUNC', 'RDIVIDE', one, vv4_nm.get('FUNC', 'SQRT', vv4_nm.get('FUNC', 'MINUS', one, vv4_nm.get('FUNC', 'MPOWER', x, two)))), dx)

    elif op == 'ACOS':
        dmap[u] = mult(vv4_nm.get('FUNC', 'RDIVIDE', minus_one, vv4_nm.get('FUNC', 'SQRT', vv4_nm.get('FUNC', 'MINUS', one, vv4_nm.get('FUNC', 'MPOWER', x, two)))), dx)

    elif op == 'ATAN':
        dmap[u] = mult(vv4_nm.get('FUNC', 'RDIVIDE', one, vv4_nm.get('FUNC', 'PLUS', one, vv4_nm.get('FUNC', 'MPOWER', x, two))), dx)

    elif op == 'SINH':
        dmap[u] = mult(vv4_nm.get('FUNC', 'COSH', x), dx)

    elif op == 'COSH':
        dmap[u] = mult(vv4_nm.get('FUNC', 'SINH', x), dx)

    elif op == 'TANH':
        dmap[u] = mult(vv4_nm.get('FUNC', 'RDIVIDE', one, vv4_nm.get('FUNC', 'MPOWER', vv4_nm.get('FUNC', 'COSH', x), two)), dx)

    elif op == 'ASINH':
        dmap[u] = mult(vv4_nm.get('FUNC', 'RDIVIDE', one, vv4_nm.get('FUNC', 'SQRT', vv4_nm.get('FUNC', 'PLUS', one, vv4_nm.get('FUNC', 'MPOWER', x, two)))), dx)

    elif op == 'ACOSH':
        dmap[u] = mult(vv4_nm.get('FUNC', 'RDIVIDE', one, vv4_nm.get('FUNC', 'SQRT', vv4_nm.get('FUNC', 'MINUS', vv4_nm.get('FUNC', 'MPOWER', x, two), one))), dx)

    elif op == 'ATANH':
        dmap[u] = mult(vv4_nm.get('FUNC', 'RDIVIDE', one, vv4_nm.get('FUNC', 'MINUS', one, vv4_nm.get('FUNC', 'MPOWER', x, two))), dx)

    elif op == 'EXP':
        dmap[u] = mult(u, dx)

    elif op == 'LOG':
        dmap[u] = mult(vv4_nm.get('FUNC', 'RDIVIDE', one, x), dx)

    elif op == 'LOG10':
        dmap[u] = mult(vv4_nm.get('FUNC', 'RDIVIDE', one, vv4_nm.get('FUNC', 'MTIMES', x, log10)), dx)

    elif op == 'SQRT':
        dmap[u] = mult(vv4_nm.get('FUNC', 'RDIVIDE', one, vv4_nm.get('FUNC', 'MTIMES', two, u)), dx)

    elif op == 'UMINUS':
        dmap[u] = mult(minus_one, dx)

    elif op == 'UPLUS':
        dmap[u] = [v for v in dx]

    elif op == 'MAX':
        u_ge_v = vv4_nm.get('FUNC', 'GE', u, v)
        dmap[u] = [vv4_nm.get('FUNC', 'ITE', u_ge_v, dx[i], dy[i]) for i in range(num_indep_variables)]

    elif op == 'MIN':
        u_lt_v = vv4_nm.get('FUNC', 'LT', u, v)
        dmap[u] = [vv4_nm.get('FUNC', 'ITE', u_lt_v, dx[i], dy[i]) for i in range(num_indep_variables)]

    elif op == 'PLUS':
        dmap[u] = [vv4_nm.get('FUNC', 'PLUS', dx[i], dy[i]) for i in range(num_indep_variables)]

    elif op == 'MINUS':
        dmap[u] = [vv4_nm.get('FUNC', 'MINUS', dx[i], dy[i]) for i in range(num_indep_variables)]

    elif op in ['MTIMES', 'TIMES']:
        dmap[u] = [vv4_nm.get('FUNC', 'PLUS', vv4_nm.get('FUNC', 'MTIMES', x, dy[i]), vv4_nm.get('FUNC', 'MTIMES', y, dx[i])) for i in range(num_indep_variables)]

    elif op in ['MRDIVIDE', 'RDIVIDE']:
        out = []
        for idx in range(num_indep_variables):
            x_is_const = vv4_nm.is_zero(dx[idx])
            y_is_const = vv4_nm.is_zero(dy[idx])
            if x_is_const and y_is_const:
                d = zero
            elif y_is_const:
                d = vv4_nm.get('FUNC', 'RDIVIDE', dx[idx], y)
            elif x_is_const:
                d = vv4_nm.get('FUNC', 'MTIMES', vv4_nm.get('FUNC', 'MTIMES', x, vv4_nm.get('FUNC', 'RDIVIDE', minus_one, vv4_nm.get('FUNC', 'MPOWER', y, two))), dy[idx])
            else:
                d = vv4_nm.get('FUNC', 'RDIVIDE', vv4_nm.get('FUNC', 'MINUS', vv4_nm.get('FUNC', 'MTIMES', y, dx[idx]), vv4_nm.get('FUNC', 'MTIMES', x, dy[idx])), vv4_nm.get('FUNC', 'MPOWER', y, two))
            out.append(d)
        dmap[u] = out

    elif op == 'MPOWER':
        out = []
        x_pow_y = vv4_nm.get('FUNC', 'MPOWER', x, y)
        for idx in range(num_indep_variables):
            x_is_const = vv4_nm.is_zero(dx[idx])
            y_is_const = vv4_nm.is_zero(dy[idx])
            if x_is_const and y_is_const:
                d = zero
            elif y_is_const:
                d = vv4_nm.get('FUNC', 'MTIMES', vv4_nm.get('FUNC', 'MTIMES', y, vv4_nm.get('FUNC', 'MPOWER', x, vv4_nm.get('FUNC', 'MINUS', y, one))), dx[idx])
            elif x_is_const:
                d = vv4_nm.get('FUNC', 'MTIMES', vv4_nm.get('FUNC', 'MTIMES', x_pow_y, vv4_nm.get('FUNC', 'LOG', x)), dy[idx])
            else:
                d = vv4_nm.get('FUNC', 'MTIMES', x_pow_y, vv4_nm.get('FUNC', 'PLUS', vv4_nm.get('FUNC', 'MTIMES', dx[idx], vv4_nm.get('FUNC', 'RDIVIDE', y, x)), vv4_nm.get('FUNC', 'MTIMES', dy[idx], vv4_nm.get('FUNC', 'LOG', x))))
            out.append(d)
        dmap[u] = out

    elif op == 'ITE':
        dmap[u] = [vv4_nm.get('FUNC', 'ITE', x, dy[i], dz[i]) for i in range(num_indep_variables)]

    else:
        assert False, ('ERROR: Unrecognized operation %s' % op)


