
import os
import subprocess
from functools import lru_cache
from .DAG_utils import topological_sort, get_parents, compulsory_set


def MATLAB_stmts(dep_names, indep_names, ite, vv4_nm, var_name_prefix='z', num_format='%1.12e', line_length_threshold=None, indent_level=0, tabstop=4):
    if ite:
        yield from _MATLAB_stmts_ITE(dep_names, indep_names, vv4_nm, var_name_prefix, num_format, line_length_threshold, indent_level, tabstop)
    else:
        yield from _MATLAB_stmts_if_else(dep_names, indep_names, vv4_nm, var_name_prefix, num_format, line_length_threshold, indent_level, tabstop)


def _MATLAB_stmts_ITE(dep_names, indep_names, vv4_nm, var_name_prefix, num_format, line_length_threshold, indent_level, tabstop):
    
    """
    This function exports MATLAB code for computing a bunch of nodes in a DAG. 
    The code that is exported makes use of ite(., ., .) calls and does not 
    contain if/else ladders. This is potentially inefficient.

    Description of inputs:

        * dep_names is a dictionary. It maps variable names to _vv4_Node objects 
          (representing the functions to be computed). Once the functions are 
          evaluated, the corresponding variable names in the MATLAB workspace 
          will be assigned to the results of the computation.

        * indep_names is a dictionary that maps INDEP _vv4_Nodes to the names 
          under which they are available in the MATLAB workspace.

        * vv4_nm is a vv4_Node_Manager object that exposes an API allowing this 
          function to ask queries about _vv4_nodes, etc (e.g., is this node a 
          CONST node?).

        * var_name_prefix: prefix used to name intermediate variables. For 
          example, if var_prefix is 'z', intermediate variables will be named 
          'z1', 'z2', etc.

        * num_format: format to use when exporting float constants

        * line_length_threshold (integer or None): if the length of the MATLAB 
          expression for computing a variable exceeds this threshold, the 
          variable is immediately given a name and exported as an intermediate 
          quantity in the computation. None disables this feature (i.e., 
          intermediate variables are created only when they are needed for more 
          than one future calculation).

        * indent_level, tabstop: parameters for describing how many leading 
          spaces to output before each line of code. Note: indent_level 0 means 
          no indentation at all.

    Description of outputs:

        * This function yields MATLAB statements (perhaps with some blank 
          lines) one by one. Each MATLAB statement comes with a semicolon at 
          the end, and is terminated with a newline character.

    """

    # figure out from dep_names the set of dependent nodes to be computed
    deps = set(u for u in dep_names.values())

    # do a topological sort on deps
    tlist = topological_sort(deps, vv4_nm)
    
    # figure out how many times each node in tlist is used (if a node is used 
    # more than once, it should become an intermediate variable in the 
    # computation)
    parents = get_parents(tlist, vv4_nm)
    times_used = {u: len(parents[u]) for u in tlist}

    # each node referenced in dep_names should be marked as being used once 
    # more each time it is referenced, because a dep_name will be assigned to 
    # such nodes later and you don't want to do redundant computation
    for u in dep_names.values():
        times_used[u] += 1

    # go through the nodes in tlist one by one, converting them into MATLAB 
    # expression strings. When you get a node that needs to be created as an 
    # intermediate variable, yield a statement computing this variable and make 
    # a note to use the intermediate variable's name the next time it is needed.
    node_to_MATLAB_expression, num_intermediate_vars = {}, 0

    indent = (indent_level * tabstop) * ' '

    for u in tlist:

        if vv4_nm.is_indep(u):
            expr = indep_names[u]

        elif vv4_nm.is_const(u):
            dtype, val = vv4_nm.get_dtype(u), vv4_nm.get_val(u)
            expr = _const_to_MATLAB_expression(dtype, val, num_format)

        else:
            # u must be a function node
            op, children = vv4_nm.get_op(u), vv4_nm.get_children(u)
            expr_children = [node_to_MATLAB_expression[c] for c in children]
            expr = _op_to_MATLAB_expression(op, expr_children, parentheses=True)

        create_intermediate_var = False
        if line_length_threshold is not None:
            if len(expr) > line_length_threshold:
                create_intermediate_var = True
        if times_used[u] >= 2:
            create_intermediate_var = True

        if create_intermediate_var:
            num_intermediate_vars += 1
            var_name = '%s%d' % (var_name_prefix, num_intermediate_vars)
            stmt = '%s%s = %s;\n' % (indent, var_name, expr)
            yield stmt
            expr = var_name
        
        node_to_MATLAB_expression[u] = expr
    
    if num_intermediate_vars > 0:
        yield '\n'

    for var_name, u in dep_names.items():
        expr = node_to_MATLAB_expression[u]
        stmt = '%s%s = %s;\n' % (indent, var_name, expr)
        yield stmt


def _MATLAB_stmts_if_else(dep_names, indep_names, vv4_nm, var_name_prefix, num_format, line_length_threshold, indent_level, tabstop):

    py_stmts = _python_code_generator_for_MATLAB_stmts_if_else(dep_names, indep_names, vv4_nm, var_name_prefix, num_format, line_length_threshold, indent_level, tabstop)

    pyfile = '/tmp/a.py'
    with open(pyfile, 'w') as f:
        for stmt in py_stmts:
            f.write(stmt)
    
    mfile = '/tmp/a.m'
    cmd = 'rm -f %s; python3 %s > %s' % (mfile, pyfile, mfile)
    subprocess.call(cmd, shell=True)

    with open(mfile, 'r') as f:
        for line in f:
            yield line
        

def _python_code_generator_for_MATLAB_stmts_if_else(dep_names, indep_names, vv4_nm, var_name_prefix, num_format, line_length_threshold, indent_level, tabstop):

    # figure out from dep_names the set of dependent nodes to be computed
    deps = set(u for u in dep_names.values())

    # do a topological sort on deps
    tlist = topological_sort(deps, vv4_nm)
    
    # figure out how many times each node in tlist is used (if a node is used 
    # more than once, it should become an intermediate variable in the 
    # computation)
    parents = get_parents(tlist, vv4_nm)
    times_used = {u: len(parents[u]) for u in tlist}

    # each node referenced in dep_names should be marked as being used once 
    # more each time it is referenced, because a dep_name will be assigned to 
    # such nodes later and you don't want to do redundant computation
    for u in dep_names.values():
        times_used[u] += 1

    # go through the nodes in tlist one by one, converting them into MATLAB 
    # expression strings. When you get a node that needs to be created as an 
    # intermediate variable, create an _Intermediate_Variable object for it
    node_to_MATLAB_expression, node_to_intermediate_children = {}, {}
    node_to_intermediate_var = {}

    for u in tlist:

        if vv4_nm.is_indep(u):
            expr = indep_names[u]
            i_children = set()

        elif vv4_nm.is_const(u):
            dtype, val = vv4_nm.get_dtype(u), vv4_nm.get_val(u)
            expr = _const_to_MATLAB_expression(dtype, val, num_format)
            i_children = set()

        else:
            # u must be a function node
            op, children = vv4_nm.get_op(u), vv4_nm.get_children(u)
            expr_children = [node_to_MATLAB_expression[c] for c in children]
            expr = _op_to_MATLAB_expression(op, expr_children, parentheses=True)
            i_children = set.union(*[node_to_intermediate_children[c] for c in children])

        create_intermediate_var = False
        if (    times_used[u] >= 2
             or u in deps
             or vv4_nm.get_op(u) == 'ITE'
             or any(vv4_nm.get_op(p) == 'ITE' for p in parents[u])
             or (line_length_threshold is not None and len(expr) > line_length_threshold) ):
            create_intermediate_var = True

        if create_intermediate_var:
            var_name = '%s%d' % (var_name_prefix, len(node_to_intermediate_var) + 1)
            ivar = _Intermediate_Variable(var_name, u, expr, i_children)
            node_to_intermediate_var[u] = ivar
            expr, i_children = var_name, set([ivar])
        
        node_to_MATLAB_expression[u] = expr
        node_to_intermediate_children[u] = i_children

    # export Python code

    triple_quote = '"""'
    dir_where_this_file_resides = os.path.dirname(__file__)

    yield "import sys\n"
    yield "sys.path.append('%s')\n" % os.path.dirname(dir_where_this_file_resides)
    yield "\n"

    # top part of Python code
    top_stmts_file = dir_where_this_file_resides + '/' + 'MATLAB_stmts_if_else_top.py'
    with open(top_stmts_file, 'r') as f:
        for line in f:
            yield line

    # individual, mutually recursive functions for each intermediate variable
    for u, ivar in node_to_intermediate_var.items():

        ivar_name, ivar_expr, ivar_ichildren = ivar.name, ivar.expr, ivar.intermediate_children

        yield "@scopify\n"
        yield "def %s(indent_level, tabstop, scope, context, B):\n" % ivar_name

        if not vv4_nm.is_func(u):
            yield "    yield from yield_indent(indent_level, tabstop, %s%s = %s;%s)" % (triple_quote, ivar_name, ivar_expr, triple_quote)

        elif vv4_nm.get_op(u) == 'ITE':

            compulsory_non_ite_ivars, compulsory_ite_ivars = set(), set()
            for v in compulsory_set(u, vv4_nm):
                if v is u:
                    continue
                ivar = node_to_intermediate_var.get(v, None)
                if ivar is None:
                    continue
                if vv4_nm.get_op(v) == 'ITE':
                    compulsory_ite_ivars.add(ivar)
                else:
                    compulsory_non_ite_ivars.add(ivar)

            cond_ivar, if_ivar, else_ivar = [node_to_intermediate_var[v] for v in vv4_nm.get_children(u)]

            for iv in compulsory_non_ite_ivars:
                yield "    yield from %s(indent_level, tabstop, scope, context, B)\n" % iv.name

            for iv in compulsory_ite_ivars:
                yield "    yield from %s(indent_level, tabstop, scope, context, B)\n" % iv.name
            
            yield "    yield from yield_indent(indent_level, tabstop, 'if (%s)')\n" % cond_ivar.name
            yield "    if_context = B.AND(context, B.primary_inputs(['%s'])[0])\n" % cond_ivar.name
            yield "    yield from %s(indent_level + 1, tabstop, scope, if_context, B)\n" % if_ivar.name
            yield "    yield from yield_indent(indent_level + 1, tabstop, '%s = %s;')\n" % (ivar_name, if_ivar.name)
            yield "    yield from yield_indent(indent_level, tabstop, 'else')\n"
            yield "    else_context = B.AND(context, B.primary_input_complements(['%s'])[0])\n" % cond_ivar.name
            yield "    yield from %s(indent_level + 1, tabstop, scope, else_context, B)\n" % else_ivar.name
            yield "    yield from yield_indent(indent_level + 1, tabstop, '%s = %s;')\n" % (ivar_name, else_ivar.name)
            yield "    yield from yield_indent(indent_level, tabstop, 'end')\n"

        else:

            non_ite_ichildren = [ic for ic in ivar_ichildren if vv4_nm.get_op(ic.node) != 'ITE']
            ite_ichildren = [ic for ic in ivar_ichildren if vv4_nm.get_op(ic.node) == 'ITE']

            for iv in non_ite_ichildren:
                yield "    yield from %s(indent_level, tabstop, scope, context, B)\n" % iv.name

            for iv in ite_ichildren:
                yield "    yield from %s(indent_level, tabstop, scope, context, B)\n" % iv.name

            yield "    yield from yield_indent(indent_level, tabstop, %s%s = %s;%s)" % (triple_quote, ivar_name, ivar_expr, triple_quote)

        yield '\n\n'

    ite_ivar_names = [node_to_intermediate_var[u].name for u in tlist if any(vv4_nm.get_op(p) == 'ITE' for p in parents[u])]

    # main function
    yield "def main():\n"
    yield "\n"
    yield "    B = BDD([%s])\n" % ', '.join(["'%s'" % x for x in ite_ivar_names])
    yield "    indent_level, tabstop, scope, context = %d, %d, {}, B.get_True()\n" % (indent_level, tabstop)
    yield "\n"

    non_ite_deps = [dep for dep in deps if vv4_nm.get_op(dep) != 'ITE']
    ite_deps = [dep for dep in deps if vv4_nm.get_op(dep) == 'ITE']
    for dep in non_ite_deps + ite_deps:
        yield "    yield from %s(indent_level, tabstop, scope, context, B)\n" % node_to_intermediate_var[dep].name

    yield "\n"

    for dep_name, dep in dep_names.items():
        yield "    yield from yield_indent(indent_level, tabstop, '%s = %s;')\n" % (dep_name, node_to_intermediate_var[dep].name)

    yield "\n\n"

    yield "if __name__ == '__main__':\n"
    yield "    print(''.join(list(main())))\n"
    yield "\n"


class _Intermediate_Variable:
    def __init__(self, name, node, expr, intermediate_children):
        self.name, self.node, self.expr, self.intermediate_children = name, node, expr, intermediate_children


def _const_to_MATLAB_expression(dtype, val, num_format):
    if dtype == 'INT':
        return 'int64(%d)' % val
    elif dtype == 'FLOAT':
        return num_format % val
    elif dtype == 'CHAR':
        return "'%s'" % val
    elif dtype == 'BOOL':
        return 'true' if val else 'false'
    else:
        assert False, ('ERROR: Unrecognized data type %s' % dtype)


def _op_to_MATLAB_expression(op, expr_children, parentheses=False):

    # op is a string
    # expr_children is a list of strings (MATLAB expressions for the children)

    if op in [ 'ABS', 'SIN', 'COS', 'TAN', 'ASIN', 'ACOS', 'ATAN', 'SINH', 
               'COSH', 'TANH', 'ASINH', 'ACOSH', 'ATANH', 'EXP', 'LOG', 
               'LOG10', 'SQRT', 'SIGN', 'SIGN2', 'MAX', 'MIN', 'STRCMP', 
               'STRCMPI', 'AND', 'OR', 'ITE']:
        return '%s(%s)' % (op.lower(), ','.join(expr_children))

    op_map = { 'UPLUS': '', 'UMINUS': '-', 'PLUS': '+', 'MINUS': '-', 
               'TIMES': '*', 'MTIMES': '*', 'RDIVIDE': '/', 'MRDIVIDE': '/', 
               'MPOWER': '^', 'GT': '>', 'LT': '<', 'GE': '>=', 'LE': '<=', 
               'EQ': '==', 'NE': '~=' }

    if op in ['UPLUS', 'UMINUS']:
        out = op_map[op] + expr_children[0]

    elif op in [ 'PLUS', 'MINUS', 'TIMES', 'MTIMES', 'RDIVIDE', 'MRDIVIDE', 
                 'MPOWER', 'GT', 'LT', 'GE', 'LE', 'EQ', 'NE' ]:
        out = '%s%s%s' % (expr_children[0], op_map[op], expr_children[1])

    else:
        assert False, ('ERROR: Unrecognized operation %s' % op)

    if parentheses:
        out = '(%s)' % out

    return out


