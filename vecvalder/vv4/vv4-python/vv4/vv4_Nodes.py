
import math
from .misc_utils import UniqID_Generator

class vv4_Node_Manager:
    
    def __init__(self):
        self._indep_hashmap = {}
        self._const_hashmap = {}
        self._func_hashmap = {}
        self._uniqID_generator = UniqID_Generator()

    def get(self, node_type, *node_parms):
        if node_type == 'INDEP':
            name = node_parms[0]
            return self._get_indep(name)
        if node_type == 'CONST':
            dtype, val = node_parms[:2]
            return self._get_const(dtype, val)
        if node_type == 'FUNC':
            op, children = node_parms[0], node_parms[1:]
            return self._get_func(op, children)
        assert False, ('ERROR: Unrecognized node type %s' % str(node_type))

    def get_uniqID(self, u):
        return u.uniqID

    def get_name(self, u):
        return getattr(u, 'name', None)

    def get_dtype(self, u):
        return getattr(u, 'dtype', None)

    def get_val(self, u):
        return getattr(u, 'val', None)

    def get_op(self, u):
        return getattr(u, 'op', None)

    def get_children(self, u):
        return getattr(u, 'children', [])

    def is_indep(self, u):
        return isinstance(u, _vv4_Indep_Node)

    def is_const(self, u):
        return isinstance(u, _vv4_Const_Node)

    def is_zero(self, u):
        return self.is_const(u) and (u.dtype, u.val) == ('FLOAT', 0.0)

    def is_one(self, u):
        return self.is_const(u) and (u.dtype, u.val) == ('FLOAT', 1.0)

    def is_func(self, u):
        return isinstance(u, _vv4_Func_Node)

    def _get_indep(self, name):
        key = name
        u = self._indep_hashmap.get(key, None)
        if u is not None:
            return u
        u = _vv4_Indep_Node(self._uniqID(), name)
        self._indep_hashmap[key] = u
        return u

    def _get_const(self, dtype, val):
        key = (dtype, val)
        u = self._const_hashmap.get(key, None)
        if u is not None:
            return u
        u = _vv4_Const_Node(self._uniqID(), dtype, val)
        self._const_hashmap[key] = u
        return u

    def _get_func(self, op, children):
        u = self._propagate_constants_if_possible(op, children)
        if u is not None:
            return u
        u = self._simplify_if_possible(op, children)
        if u is not None:
            return u
        key = tuple([op] + list(children))
        u = self._func_hashmap.get(key, None)
        if u is not None:
            return u
        u = _vv4_Func_Node(self._uniqID(), op, children)
        self._func_hashmap[key] = u
        return u

    def _uniqID(self):
        return self._uniqID_generator.get_uniqID()

    def _propagate_constants_if_possible(self, op, children):

        if not all(self.is_const(c) for c in children):
            return None

        callables = {      'ABS': abs, 
                           'SIN': math.sin, 
                           'COS': math.cos,
                           'TAN': math.tan, 
                          'ASIN': math.asin, 
                          'ACOS': math.acos, 
                          'ATAN': math.atan,
                          'SINH': math.sinh,
                          'COSH': math.cosh,
                          'TANH': math.tanh,
                         'ASINH': math.asinh,
                         'ACOSH': math.acosh,
                         'ATANH': math.atanh,
                           'EXP': math.exp,
                           'LOG': math.log,
                         'LOG10': math.log10,
                          'SQRT': math.sqrt,
                          'SIGN': lambda x: (1.0 if x > 0.0 else (-1.0 if x < 0.0 else 0.0)),
                         'SIGN2': lambda x: (1.0 if x >= 0.0 else -1.0),
                         'UPLUS': lambda x: x,
                        'UMINUS': lambda x: -x,
                           'MAX': max,
                           'MIN': min,
                          'PLUS': lambda x, y: x + y,
                         'MINUS': lambda x, y: x - y,
                         'TIMES': lambda x, y: x * y,
                        'MTIMES': lambda x, y: x * y,
                       'RDIVIDE': lambda x, y: x / y,
                      'MRDIVIDE': lambda x, y: x / y,
                        'MPOWER': lambda x, y: x ** y,
                        'STRCMP': lambda x, y: x == y,
                       'STRCMPI': lambda x, y: x.lower() == y.lower(),
                           'AND': lambda x, y: x and y,
                            'OR': lambda x, y: x or y,
                            'GT': lambda x, y: x > y,
                            'LT': lambda x, y: x < y,
                            'GE': lambda x, y: x >= y,
                            'LE': lambda x, y: x <= y,
                            'EQ': lambda x, y: x == y,
                            'NE': lambda x, y: x != y,
                           'ITE': lambda x, y, z: (y if x else z),
                    }

        # TODO: check data types before doing the operation, else you can get 
        # unexpected results, although this is pretty rare

        C = callables.get(op, None)

        if C is None:
            assert False, ('ERROR: Unrecognized operation %s' % op)

        val = C(*[c.val for c in children])
        dtype = self._dtype(val)
        
        return self._get_const(dtype, val)

    def _simplify_if_possible(self, op, children):
        
        u = children[0]
        if len(children) > 1:
            v = children[1]
            if len(children) > 2:
                w = children[2]

        if op == 'UPLUS':
            return u
        
        if op in ['MAX', 'MIN', 'AND', 'OR']:
            if u is v:
                return u

        if op in ['GE', 'LE', 'EQ', 'STRCMP', 'STRCMPI']:
            if u is v:
                return self._get_const('BOOL', True)

        if op == 'NE':
            if u is v:
                return self._get_const('BOOL', False)

        if op == 'PLUS':
            if self.is_zero(u):
                return v
            if self.is_zero(v):
                return u

        if op == 'MINUS':
            if self.is_zero(u):
                return self._get_func('UMINUS', (v, ))
            if self.is_zero(v):
                return u
            if u is v:
                return self._get_const('FLOAT', 0.0)
        
        if op in ['TIMES', 'MTIMES']:
            if self.is_zero(u):
                return u
            if self.is_zero(v):
                return v
            if self.is_one(u):
                return v
            if self.is_one(v):
                return u

        if op in ['RDIVIDE', 'MRDIVIDE']:
            if self.is_zero(u):
                return u
            if self.is_one(v):
                return u
            if u is v:
                return self._get_const('FLOAT', 1.0)

        if op == 'ITE':
            if self._is_True(u) or self.is_one(u):
                return v
            if self._is_False(u) or self.is_zero(u):
                return w
            if v is w:
                return v

        return None

    def _dtype(self, val):
        return {int: 'INT', float: 'FLOAT', str: 'CHAR', bool: 'BOOL'}[type(val)]

    def _is_True(self, u):
        return self.is_const(u) and u.dtype == 'BOOL' and u.val is True

    def _is_False(self, u):
        return self.is_const(u) and u.dtype == 'BOOL' and u.val is False


class _vv4_Node:

    def __init__(self, uniqID):
        self.uniqID = uniqID
    

class _vv4_Indep_Node(_vv4_Node):

    def __init__(self, uniqID, name):
        super().__init__(uniqID)
        self.name = name

    def __repr__(self):
        fmt = '_vv4_Indep_Node: uniqID, name = %s, %s'
        return fmt % (str(self.uniqID), self.name)


class _vv4_Const_Node(_vv4_Node):

    def __init__(self, uniqID, dtype, val):
        super().__init__(uniqID)
        self.dtype, self.val = dtype, val

    def __repr__(self):
        fmt = '_vv4_Const_Node: uniqID, dtype, val = %s, %s, %s' 
        return fmt % (str(self.uniqID), self.dtype, str(self.val))


class _vv4_Func_Node(_vv4_Node):
    
    def __init__(self, uniqID, op, children):
        super().__init__(uniqID)
        self.op = op
        self.children = children

    def __repr__(self):
        fmt = '_vv4_Func_Node: uniqID, op, uniqIDs of children = %s, %s, [%s]'
        uniqIDs_of_children_str = ', '.join([str(c.uniqID) for c in self.children])
        return fmt % (str(self.uniqID), self.op, uniqIDs_of_children_str)

