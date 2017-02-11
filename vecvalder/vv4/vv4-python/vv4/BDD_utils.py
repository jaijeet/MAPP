
from functools import lru_cache
from collections import deque
from prettytable import PrettyTable as PT

from .misc_utils import UniqID_Generator

class BDD:
    
    """
    This class represents a BDD. 
    
    In programming terms, this class essentially manages a bunch of BDD Nodes 
    for you. The functionality provided by this class includes: 
    
        * making sure that a proper variable ordering is maintained when 
          multiple BDD nodes are involved, 
          
        * making sure that canonicity is maintained by not creating BDD nodes 
          unnecessarily (via the use of a hashmap), 
          
        * providing functions for carrying out operations like AND, OR, and NOT 
          on BDD nodes, etc.
    """

    def __init__(self, ordered_var_names):
        self._vars = ordered_var_names
        self._ordering = {var_name: idx for idx, var_name in enumerate(ordered_var_names)}
        self._hashmap, self._uniqID_to_BDD_Node = {}, {}
        self._uniqID_generator = UniqID_Generator()
        self._False = self._create_BDD_Node_if_necessary(False, None, None)
        self._True = self._create_BDD_Node_if_necessary(True, None, None)

    def primary_inputs(self, var_names=None):
        if var_names is None:
            var_names = self._vars
        else:
            assert all(s in self._ordering for s in var_names), 'ERROR: One or more variable names unrecognized'
        return [self._create_BDD_Node_if_necessary(s, self._False, self._True) for s in var_names]

    def primary_input_complements(self, var_names=None):
        if var_names is None:
            var_names = self._vars
        else:
            assert all(s in self._ordering for s in var_names), 'ERROR: One or more variable names unrecognized'
        return [self._create_BDD_Node_if_necessary(s, self._True, self._False) for s in var_names]

    def is_True(self, u):
        return (u is self._True)

    def is_False(self, u):
        return (u is self._False)

    def is_zero(self, u):
        return self.is_False(u)

    def is_one(self, u):
        return self.is_True(u)

    def get_True(self):
        return self._True

    def get_False(self):
        return self._False

    def get_var(self, u):
        return u.var

    def get_zero(self, u):
        return u.zero

    def get_one(self, u):
        return u.one

    def AND(self, *args):
        return self._reduce(self._and, *args)

    def OR(self, *args):
        return self._reduce(self._or, *args)

    def NOT(self, u):
        if self.is_True(u):
            return self._False
        if self.is_False(u):
            return self._True
        return self._create_BDD_Node_if_necessary(u.var, self.NOT(u.zero), self.NOT(u.one))

    @lru_cache(maxsize=None)
    def to_MATLAB_expression(self, u):

        # u is a BDD node

        def mult(var_expr, expr):
            if expr == 'false':
                return ''
            if expr == 'true':
                return var_expr
            return '%s&&%s' % (var_expr, expr)

        if self.is_True(u):
            return 'true'

        if self.is_False(u):
            return 'false'

        var, zero, one = self.get_var(u), self.get_zero(u), self.get_one(u)
        zero_expr, one_expr = [self.to_MATLAB_expression(x) for x in (zero, one)]
        t0, t1 = mult('~%s' % var, zero_expr), mult(var, one_expr)

        if t0 and t1:
            return '(%s||%s)' % (t0, t1)
        elif t0:
            return t0
        elif t1:
            return t1
        else:
            assert False, 'ERROR: Both children of a BDD node seem to be pointed at False.'


    def print(self, u=None):
        if u is None:
            self._print_all()
            return
        t = self._empty_table()
        q, processed = deque([u]), set([])
        while q:
            v = q.popleft()
            if v in processed:
                continue
            t.add_row(v.fields_for_printing())
            if v.zero is not None:
                q.append(v.zero)
            if v.one is not None:
                q.append(v.one)
            processed.add(v)
        print(t)

    def _reduce(self, op, *args):
        ans = args[0]
        for arg in args[1:]:
            ans = op(ans, arg)
        return ans

    def _and(self, u, v):
        if self.is_False(u) or self.is_False(v):
            return self._False
        if self.is_True(u):
            return v
        if self.is_True(v):
            return u
        if u.var == v.var:
            return self._create_BDD_Node_if_necessary(u.var, self._and(u.zero, v.zero), self._and(u.one, v.one))
        if self._ordering[u.var] > self._ordering[v.var]:
            u, v = v, u
        return self._create_BDD_Node_if_necessary(u.var, self._and(u.zero, v), self._and(u.one, v))

    def _or(self, u, v):
        if self.is_True(u) or self.is_True(v):
            return self._True
        if self.is_False(u):
            return v
        if self.is_False(v):
            return u
        if u.var == v.var:
            return self._create_BDD_Node_if_necessary(u.var, self._or(u.zero, v.zero), self._or(u.one, v.one))
        if self._ordering[u.var] > self._ordering[v.var]:
            u, v = v, u
        return self._create_BDD_Node_if_necessary(u.var, self._or(u.zero, v), self._or(u.one, v))

    def _create_BDD_Node_if_necessary(self, var, zero, one):
        if zero is not None and one is not None and zero is one:
            return zero
        key = (var, zero, one)
        node = self._hashmap.get(key, None)
        if node is not None:
            return node
        uniqID = self._uniqID_generator.get_uniqID()
        new_node = _BDD_Node(uniqID, *key)
        self._hashmap[key] = new_node
        self._uniqID_to_BDD_Node[uniqID] = new_node
        return new_node

    def _print_all(self):
        t = self._empty_table()
        for u in self._uniqID_to_BDD_Node.values():
            t.add_row(u.fields_for_printing())
        print(t)

    def _empty_table(self):
        cols = ['UniqID', 'Var', 'Zero', 'One']
        t = PT(cols)
        for col in cols:
            t.align[col] = 'r'
        return t


class _BDD_Node:

    """
    This class represents a node in a BDD. Each instance of this class has the 
    following fields:

        uniqID: Something that uniquely identifies this BDD node

           var: Either True (representing the BDD node for logical 1), or 
                False (representing the BDD node for logical 0), or a string 
                containing the name of a decision variable. 

          zero: A BDD node that corresponds to the decision variable being 
                False (or None if var is either True or False).


           one: A BDD node that corresponds to the decision variable being 
                True (or None if var is either True or False).
    """

    def __init__(self, uniqID, var, zero, one):
        self.uniqID, self.var, self.zero, self.one = uniqID, var, zero, one

    def fields_for_printing(self):
        return [ 
                   str(self.uniqID), 
                   str(self.var),
                   str(self.zero.uniqID) if self.zero is not None else 'None',
                   str(self.one.uniqID) if self.one is not None else 'None',
               ]

    def __str__(self):
        return 'BDD Node with (uniqID, var, zero, one) = (%s, %s, %s, %s)' % tuple(self.fields_for_printing())

    def __repr__(self):
        return str(self)


