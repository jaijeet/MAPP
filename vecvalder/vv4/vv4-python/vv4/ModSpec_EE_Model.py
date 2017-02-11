
import os
import jinja2
import itertools

from .vv4_Nodes import vv4_Node_Manager
from .differentiation_utils import differentiate
from .codegen_utils_MATLAB import MATLAB_stmts
from .templating_utils_MATLAB import jinja2_filters

class ModSpec_EE_Model:

    """
    This class represents a ModSpec EE Model. The class constructor is designed 
    to parse the model from a file exported, for example, by export_MOD_via_vv4.

    The data members of this class are as follows:

        basic info: 
            self.model_name (string)
            self.model_description (string)
            self.terminals (list of strings)
            self.refnode (string that belongs to self.terminals)
            self.internal_unks (list of strings)
            self.explicit_outs (list of strings)
            self.implicit_eqns (list of strings)
            self.internal_srcs (list of strings)
            self.output_names (list of strings)
            self.output_matrix (list of lists of floats)

        parameters:
            self.parm_names (list of strings)
            self.parm_data_types (list of strings)
            self.parm_default_values (list of values of type defined by parm_data_types)

        core functions (some of these only exist if the model supports limiting):
            self.fe_without_limiting (list of _vv4_Node objects)
            self.fe_with_limiting (list of _vv4_Node objects)
            self.qe_without_limiting (list of _vv4_Node objects)
            self.qe_with_limiting (list of _vv4_Node objects)
            self.fi_without_limiting (list of _vv4_Node objects)
            self.fi_with_limiting (list of _vv4_Node objects)
            self.qi_without_limiting (list of _vv4_Node objects)
            self.qi_with_limiting (list of _vv4_Node objects)

        init/limiting support:
            self.support_initlimiting (True/False)
            self.limited_vars (list of strings)
            self.vecXY_to_limited_vars_matrix (list of lists of floats)
            self.init_guess (list of _vv4_Node objects)
            self.limiting (list of _vv4_Node objects)

        derivatives (some of these only exist if the model supports limiting):
            self.dfe_without_limiting_dvecX (list of lists of _vv4_Node objects)
            self.dfe_without_limiting_dvecY (list of lists of _vv4_Node objects)
            self.dfe_without_limiting_dvecU (list of lists of _vv4_Node objects)
            self.dfe_with_limiting_dvecX (list of lists of _vv4_Node objects)
            self.dfe_with_limiting_dvecY (list of lists of _vv4_Node objects)
            self.dfe_with_limiting_dvecLim (list of lists of _vv4_Node objects)
            self.dfe_with_limiting_dvecU (list of lists of _vv4_Node objects)
            self.dqe_without_limiting_dvecX (list of lists of _vv4_Node objects)
            self.dqe_without_limiting_dvecY (list of lists of _vv4_Node objects)
            self.dqe_with_limiting_dvecX (list of lists of _vv4_Node objects)
            self.dqe_with_limiting_dvecY (list of lists of _vv4_Node objects)
            self.dqe_with_limiting_dvecLim (list of lists of _vv4_Node objects)
            self.dfi_without_limiting_dvecX (list of lists of _vv4_Node objects)
            self.dfi_without_limiting_dvecY (list of lists of _vv4_Node objects)
            self.dfi_without_limiting_dvecU (list of lists of _vv4_Node objects)
            self.dfi_with_limiting_dvecX (list of lists of _vv4_Node objects)
            self.dfi_with_limiting_dvecY (list of lists of _vv4_Node objects)
            self.dfi_with_limiting_dvecLim (list of lists of _vv4_Node objects)
            self.dfi_with_limiting_dvecU (list of lists of _vv4_Node objects)
            self.dqi_without_limiting_dvecX (list of lists of _vv4_Node objects)
            self.dqi_without_limiting_dvecY (list of lists of _vv4_Node objects)
            self.dqi_with_limiting_dvecX (list of lists of _vv4_Node objects)
            self.dqi_with_limiting_dvecY (list of lists of _vv4_Node objects)
            self.dqi_with_limiting_dvecLim (list of lists of _vv4_Node objects)
            self.dinit_guess_dvecU (list of lists of _vv4_Node objects)
            self.dlimiting_dvecX (list of lists of _vv4_Node objects)
            self.dlimiting_dvecY (list of lists of _vv4_Node objects)
            self.dlimiting_dvecLim (list of lists of _vv4_Node objects)
            self.dlimiting_dvecU (list of lists of _vv4_Node objects)

        various lengths associated with this model:
            self.len_vecX (float)
            self.len_vecY (float)
            self.len_vecLim (float)
            self.len_vecU (float)
            self.len_parms (float)
            self.len_fe (float)
            self.len_qe (float)
            self.len_fi (float)
            self.len_qi (float)
            self.len_init_guess (float)
            self.len_limiting (float)

        some data members for book-keeping:
            self._vv4_nm (a vv4_Node_Manager instance)

        data members for code export:
            self._MATLAB_indep_names (dict: _vv4_Node -> string)

    """


    def __init__(self, infile_name):
        self._parse(infile_name)


    def print_lengths(self):
        print('         len(vecX) = ' + str(self.len_vecX))
        print('         len(vecY) = ' + str(self.len_vecY))
        print('       len(vecLim) = ' + str(self.len_vecLim))
        print('         len(vecU) = ' + str(self.len_vecU))
        print('        len(parms) = ' + str(self.len_parms))
        print('           len(fe) = ' + str(self.len_fe))
        print('           len(qe) = ' + str(self.len_qe))
        print('           len(fi) = ' + str(self.len_fi))
        print('           len(qi) = ' + str(self.len_qi))
        print('   len(init_guess) = ' + str(self.len_init_guess))
        print('     len(limiting) = ' + str(self.len_limiting))


    def export_optimized_MATLAB_code(self, dir_name, base_name, ite=True):

        self._compute_derivatives()
        self._compute_MATLAB_code_fields(ite)

        context = {'BASENAME': base_name, 'pyMOD': self}

        dir_where_this_file_resides = os.path.dirname(os.path.realpath(__file__))
        env = jinja2.Environment(loader=jinja2.FileSystemLoader(searchpath=dir_where_this_file_resides))
        for filter_name, filter_func in jinja2_filters.items():
            env.filters[filter_name] = filter_func

        out_text = env.get_template('ModSpec_EE_Model_MATLAB.jinja2').render(context)

        with open(dir_name + '/' + base_name + '.m', 'w') as f:
            f.write(out_text)


    def _parse(self, infile_name):
        self._vv4_nm = vv4_Node_Manager()
        with open(infile_name, 'r') as f:
            while True:
                l = f.readline()
                if not l:
                    # EOF reached
                    break
                l = l.strip()
                if not l or l[0] == '#':
                    # comment
                    continue
                # beginning of section
                assert l.startswith('[BEGIN'), 'ERROR: Expected beginning of section'
                section_name = l.lstrip('[BEGIN').rstrip(']').strip()
                if section_name == 'BASIC INFO':
                    self._parse_basic_info(f)
                elif section_name == 'PARAMETERS':
                    self._parse_parms(f)
                elif section_name == 'CORE FUNCTIONS':
                    self._parse_core_functions(f)
                elif section_name == 'INIT/LIMITING':
                    assert self.support_initlimiting is True, 'ERROR: INIT/LIMITING section found but support_initlimiting is not True'
                    self._parse_init_limiting(f)
                else:
                    assert False, ('Unexpected section name %s' % section_name)
        self._set_lengths()


    def _parse_basic_info(self, f):
        while True:
            l = f.readline()
            if l.startswith('[END'):
                break
            l = l.strip()
            if not l or l[0] == '#':
                continue
            field, _, value = [s.strip() for s in l.partition('=')]
            assert field in ['MODEL_NAME', 'MODEL_DESCRIPTION', 'TERMINALS', 'REFNODE', 'INTERNAL_UNKS', 'EXPLICIT_OUTS', 'IMPLICIT_EQNS', 'INTERNAL_SRCS', 'OUTPUT_NAMES', 'SUPPORT_INITLIMITING', 'OUTPUT_MATRIX'], ('ERROR: Unexpected basic info field %s' % field)
            if field != 'OUTPUT_MATRIX':
                setattr(self, field.lower(), eval(value))
            else:
                setattr(self, field.lower(), self._parse_matrix(f, len(self.output_names)))


    def _parse_parms(self, f):
        self.parm_names, self.parm_data_types, self.parm_default_values = [], [], []
        while True:
            l = f.readline()
            if l.startswith('[END'):
                break
            l = l.strip()
            if not l or l[0] == '#':
                continue
            eq_idx, lsq_idx, rsq_idx = l.index('='), l.rindex('['), l.rindex(']')
            name, data_type, value = l[:eq_idx].strip(), l[(lsq_idx+1):rsq_idx].strip(), eval(l[(eq_idx+1):lsq_idx].strip())
            self.parm_names.append(name)
            self.parm_data_types.append(data_type)
            self.parm_default_values.append(value)


    def _parse_core_functions(self, f):
        all_func_names = ['%s_%s' % (s1, s2) for (s1, s2) in itertools.product(['fe', 'qe', 'fi', 'qi'], ['without_limiting', 'with_limiting'])]
        while True:
            l = f.readline()
            if l.startswith('[END'):
                break
            l = l.strip()
            if not l or l[0] == '#':
                continue
            func_name, _, _ = [s.strip() for s in l.partition('=')]
            assert func_name in all_func_names, ('ERROR: Unexpected function name %s' % func_name)
            setattr(self, func_name, self._parse_func(f))


    def _parse_init_limiting(self, f):
        while True:
            l = f.readline()
            if l.startswith('[END'):
                break
            l = l.strip()
            if not l or l[0] == '#':
                continue
            field_name, _, rhs = [s.strip() for s in l.partition('=')]
            assert field_name in ['LIMITED_VARS', 'VECXY_TO_LIMITED_VARS_MATRIX', 'init_guess', 'limiting'], ('ERROR: Unexpected init/limiting field name %s' % field_name)
            if field_name == 'LIMITED_VARS':
                self.limited_vars = eval(rhs)
            elif field_name == 'VECXY_TO_LIMITED_VARS_MATRIX':
                self.vecXY_to_limited_vars_matrix = self._parse_matrix(f, len(self.limited_vars))
            else:
                setattr(self, field_name, self._parse_func(f))


    def _set_lengths(self):
        self.len_vecX = 2*(len(self.terminals)-1) - len(self.explicit_outs)
        self.len_vecY = len(self.internal_unks)
        self.len_vecLim = len(self.limited_vars) if self.support_initlimiting else 0
        self.len_vecU = len(self.internal_srcs)
        self.len_parms = len(self.parm_names)
        self.len_fe = len(self.explicit_outs)
        self.len_qe = self.len_fe
        self.len_fi = len(self.terminals) - 1 + self.len_vecY - self.len_fe
        self.len_qi = self.len_fi
        self.len_init_guess = self.len_vecLim
        self.len_limiting = self.len_vecLim


    def _parse_matrix(self, f, num_lines):
        return [[float(x) for x in f.readline().strip().split()] for idx in range(num_lines)]


    def _parse_func(self, f):
        idxs_to_vv4_Nodes, out_idxs_to_vv4_Node_idxs = {}, {}
        while True:
            l = f.readline().strip()
            if not l:
                break
            s = l.split()
            if s[0] == 'OUT':
                out_idx, node_idx = [int(x) for x in s[1:]]
                out_idxs_to_vv4_Node_idxs[out_idx] = node_idx
                continue
            node_idx, node_type = int(s[0]), s[1]
            assert node_type in ['INDEP', 'CONST', 'FUNC'], ('ERROR: Unrecognized node type %s' % node_type)
            if node_type == 'INDEP':
                name = s[2]
                node = self._vv4_nm.get('INDEP', name)
            elif node_type == 'CONST':
                dtype, val = s[2], eval(s[3])
                node = self._vv4_nm.get('CONST', dtype, val)
            elif node_type == 'FUNC':
                op, children = s[2], [idxs_to_vv4_Nodes[int(x)] for x in s[3:]]
                node = self._vv4_nm.get('FUNC', op, *children)
            idxs_to_vv4_Nodes[node_idx] = node
        return [idxs_to_vv4_Nodes[out_idxs_to_vv4_Node_idxs[i+1]] for i in range(len(out_idxs_to_vv4_Node_idxs))]


    def _compute_derivatives(self):
        
        # what are all the func names that this model can have?
            # actual func names depend on whether the model supports limiting, etc.
        all_func_names = ['%s_%s_limiting' % (s1, s2) for (s1, s2) in itertools.product(['fe', 'qe', 'fi', 'qi'], ['without', 'with'])] + ['init_guess', 'limiting']

        # what are all the independent variables we want to differentiate wrt?
            # some indep nodes (such as those representing model parameters) 
            # are not included in this list
        indep_var_names = (   ['vecX_%d' % (idx+1) for idx in range(self.len_vecX)]
                            + ['vecY_%d' % (idx+1) for idx in range(self.len_vecY)]
                            + ['vecLim_%d' % (idx+1) for idx in range(self.len_vecLim)]
                            + ['vecU_%d' % (idx+1) for idx in range(self.len_vecU)] )

        num_indep_variables = len(indep_var_names)

        # build a list of vv4_Nodes called deps that contains all the function 
        # nodes that we want to differentiate
        deps = []
        func_name_idxs_map = {}
        for func_name in all_func_names:
            func = getattr(self, func_name, None)
            if func is None:
                continue
            func_name_idxs_map[func_name] = (len(deps), len(deps) + len(func) - 1)
            deps += func

        # set the initial derivatives for the independent nodes that will be 
        # propagated forward: basically, each indep variable we care about will 
        # have a derivative of 1 wrt itself and 0 wrt every other indep variable 
        # we care about
        dmap = {}
        zero, one = [self._vv4_nm.get('CONST', 'FLOAT', x) for x in (0.0, 1.0)]
        for idx, name in enumerate(indep_var_names):
            indep_node = self._vv4_nm.get('INDEP', name)
            d = [zero]*num_indep_variables; d[idx] = one
            dmap[indep_node] = d

        # do the differentiation!
        derivs = differentiate(deps, num_indep_variables, dmap, self._vv4_nm)
        
        # set model fields related to derivatives by picking and choosing the 
        # appropriate entries from derivs
        for func_name, (lidx, hidx) in func_name_idxs_map.items():

            func_derivs, pos = derivs[lidx:(hidx+1)], 0

            dfunc_dvecX, pos = [x[pos:(pos + self.len_vecX)] for x in func_derivs], pos + self.len_vecX
            dfunc_dvecY, pos = [x[pos:(pos + self.len_vecY)] for x in func_derivs], pos + self.len_vecY
            dfunc_dvecLim, pos = [x[pos:(pos + self.len_vecLim)] for x in func_derivs], pos + self.len_vecLim
            dfunc_dvecU, pos = [x[pos:(pos + self.len_vecU)] for x in func_derivs], pos + self.len_vecU

            if func_name.startswith('f') or func_name.startswith('q') or func_name == 'limiting':
                setattr(self, 'd%s_dvecX' % func_name, dfunc_dvecX)
                setattr(self, 'd%s_dvecY' % func_name, dfunc_dvecY)

            if func_name.endswith('with_limiting') or func_name == 'limiting':
                setattr(self, 'd%s_dvecLim' % func_name, dfunc_dvecLim)

            if func_name.startswith('f') or func_name in ['init_guess', 'limiting']:
                setattr(self, 'd%s_dvecU' % func_name, dfunc_dvecU)

    
    def _compute_MATLAB_code_fields(self, ite):
        self._compute_MATLAB_indep_names()
        for idx, s in enumerate([ 'fqeiJ_without_limiting', 
                                  'only_fe_without_limiting',
                                  'only_qe_without_limiting',
                                  'only_fi_without_limiting',
                                  'only_qi_without_limiting',
                                  'fqeiJ_with_limiting',
                                  'only_fe_with_limiting',
                                  'only_qe_with_limiting',
                                  'only_fi_with_limiting',
                                  'only_qi_with_limiting',
                                  'init_guess', 
                                  'dinit_guess_dvecU', 
                                  'limiting', 
                                  'dlimiting_dvecX', 
                                  'dlimiting_dvecY', 
                                  'dlimiting_dvecLim', 
                                  'dlimiting_dvecU' ]):
            if idx > 4 and not self.support_initlimiting:
                continue
            code_block_str = ''.join(list(self._MATLAB_stmts(s, ite)))
            setattr(self, 'MATLAB_code_for_%s' % s, code_block_str)


    def _compute_MATLAB_indep_names(self):
        
        self._MATLAB_indep_names = {}

        # indep nodes corresponding to vecX, vecY, vecLim, vecU
        for s in ['X', 'Y', 'Lim', 'U']:
            l = getattr(self, 'len_vec' + s)
            for idx in range(l):
                indep_node = self._vv4_nm.get('INDEP', 'vec%s_%d' % (s, idx+1))
                self._MATLAB_indep_names[indep_node] = 'vec%s(%d)' % (s, idx+1)

        # indep nodes corresponding to parms
        for idx, pname in enumerate(self.parm_names):
            indep_node = self._vv4_nm.get('INDEP', 'parm_%s' % pname)
            self._MATLAB_indep_names[indep_node] = 'MOD.parm_vals{%d}' % (idx+1)


    def _MATLAB_stmts(self, s, ite):

        if s.startswith('only'):
            pre_alloc_info, dep_names = self._compute_MATLAB_pre_alloc_info_and_dep_names_fqeiJ_only_one(s)
        elif s.startswith('fqeiJ'):
            pre_alloc_info, dep_names = self._compute_MATLAB_pre_alloc_info_and_dep_names_fqeiJ_all(s)
        else:
            pre_alloc_info, dep_names = self._compute_MATLAB_pre_alloc_info_and_dep_names_init_guess_and_limiting(s)

        # pre-allocation
        for (var_name, num_rows, num_cols) in pre_alloc_info:
            expr = 'zeros(%d, %d)' % (num_rows, num_cols)
            yield '%s = %s;\n' % (var_name, expr)

        # model evaluation
        if dep_names:
            yield '\n'
            yield from MATLAB_stmts(dep_names, self._MATLAB_indep_names, ite, self._vv4_nm)


    def _compute_MATLAB_pre_alloc_info_and_dep_names_fqeiJ_only_one(self, s):

        fq = next(x for x in ('fe', 'qe', 'fi', 'qi') if ('_%s_' % x) in s)
        with_limiting = s.endswith('with_limiting')

        out_name = 'fqei_out.' + fq
        num_rows, num_cols = getattr(self, 'len_' + fq), 1
        pre_alloc_info = [(out_name, num_rows, num_cols), ('J_out', 0, 0)]
        dep_names, dep_nodes = {}, getattr(self, '%s_%s_limiting' % (fq, 'with' if with_limiting else 'without'))
        self._MATLAB_add_to_dep_names(dep_nodes, dep_names, out_name, num_rows, num_cols, is_2D=False)

        return pre_alloc_info, dep_names


    def _compute_MATLAB_pre_alloc_info_and_dep_names_fqeiJ_all(self, s):

        pre_alloc_info, dep_names = [], {}

        core_funcs, vecs = ('fe', 'qe', 'fi', 'qi'), ('X', 'Y', 'Lim', 'U')
        
        # fqei part
        for fq in core_funcs:
            out_name = 'fqei_out.' + fq
            num_rows, num_cols = getattr(self, 'len_' + fq), 1
            pre_alloc_info.append((out_name, num_rows, num_cols))
            dep_nodes = getattr(self, fq + s.lstrip('fqeiJ'))
            self._MATLAB_add_to_dep_names(dep_nodes, dep_names, out_name, num_rows, num_cols, is_2D=False)

        # J part
        for fq, vec in itertools.product(core_funcs, vecs):
            if vec == 'U' and fq.startswith('q'):
                continue
            if vec == 'Lim' and 'without_limiting' in s:
                continue
            out_name = 'J_out.J%s.d%s_dvec%s' % (fq, fq, vec)
            num_rows = getattr(self, 'len_' + fq)
            num_cols = getattr(self, 'len_vec' + vec)
            pre_alloc_info.append((out_name, num_rows, num_cols))
            dep_nodes = getattr(self, 'd%s_%s_dvec%s' % (fq, s.lstrip('fqeiJ_'), vec))
            self._MATLAB_add_to_dep_names(dep_nodes, dep_names, out_name, num_rows, num_cols, is_2D=True)

        return pre_alloc_info, dep_names


    def _compute_MATLAB_pre_alloc_info_and_dep_names_init_guess_and_limiting(self, s):

        is_jac = s.startswith('d')

        out_name = 'out'
        num_rows = self.len_init_guess if 'init_guess' in s else self.len_limiting
        num_cols = getattr(self, 'len_' + s[s.rindex('_dvec') + 2:]) if is_jac else 1

        pre_alloc_info = [(out_name, num_rows, num_cols)]

        dep_nodes, dep_names = getattr(self, s), {}
        self._MATLAB_add_to_dep_names(dep_nodes, dep_names, out_name, num_rows, num_cols, is_2D=is_jac)

        return pre_alloc_info, dep_names


    def _MATLAB_add_to_dep_names(self, dep_nodes, dep_names, out_name, num_rows, num_cols, is_2D):
        for row_idx, col_idx in itertools.product(range(num_rows), range(num_cols)):
            dep_node = dep_nodes[row_idx]
            if is_2D:
                dep_node = dep_node[col_idx]
            dep_names['%s(%d, %d)' % (out_name, row_idx+1, col_idx+1)] = dep_node


