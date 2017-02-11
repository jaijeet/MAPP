
from functools import lru_cache
from .BDD_utils import BDD

def topological_sort(node_list, vv4_nm):

    """
    Given a list of _vv4_Node objects (or more generally, something that 
    one can iterate over to obtain a sequence of _vv4_Node objects), and a 
    vv4_Node_Manager object, this function computes a topological ordering of 
    _vv4_Nodes for evaluating the nodes in the given list. The topological 
    ordering is returned as a list of nodes.
    """

    topological_order, processed = [], set([])

    def process(u):
        if u in processed:
            return
        children = vv4_nm.get_children(u)
        for child in children:
            process(child)
        topological_order.append(u)
        processed.add(u)

    for u in node_list:
        process(u)
    
    return topological_order


def get_parents(topological_order, vv4_nm):

    """
    Given a sequence of DAG nodes in topological order, and a vv4_Node_Manager 
    instance for querying them, this function returns a dict that maps each 
    node in the order to a list of all its parents, i.e., a list of the nodes 
    that have this node as a child.
    """

    parents_map = {u: [] for u in topological_order}
    for u in topological_order:
        for v in vv4_nm.get_children(u):
            parents_map[v].append(u)

    return parents_map


def contexts(deps, topological_order, vv4_nm):

    """
    Given a list of dependent _vv4_Node objects, a topological ordering of 
    nodes in a DAG for computing them, and a vv4_Node_Manager instance, this 
    function tells you the context in which it becomes necessary and sufficient 
    to evaluate each underlying DAG node (other than INDEP/CONST DAG nodes).

    For example, if you have nodes u, v, w, and x = ite(u, v, w), then you 
    may not have to evaluate v if the condition u is False. Similarly, you 
    may not have to evaluate w if the condition is True. Thus, each node in 
    the DAG has a "context" in which its evaluation becomes necessary. In 
    this case, the context for w might be "not u". This function computes 
    these contexts for you.

    The context for each node is expressed as a Boolean formula, where "any 
    node that makes up the conditional part of one or more ITE nodes in the 
    topological order" is a primary input. These primary inputs are given 
    names such as 'x0', 'x1', 'x2', etc.

    Each context is expressed as a Binary Decision Diagram (BDD), and is 
    returned as a BDD node.

    This function returns a 3-tuple (pi_list, cmap, B), where:

        * pi_list is a list of primary inputs. Each primary input is a 2-tuple 
          (_vv4_Node, pi_name) corresponding to the primary input node and its 
          variable name. The ordering of primary inputs in the list is also the 
          variable ordering used for the BDD. Primary inputs that occur earlier 
          in the list have a higher priority in the BDD.

        * cmap is a dict that maps each DAG node in the topological order to a 
          BDD nodes representing its evaluation context 
          
          Note: cmap does not have entries for INDEP/CONST DAG nodes because 
          they are assumed to be always available (and therefore not necessary 
          to evaluate). Also, the BDDs for these are likely to be complicated 
          and we don't want them to blow up.

        * B is a "BDD node manager" that gives you methods for printing out the 
          BDD, doing computations on the returned BDD nodes, etc.
    """

    # figure out what the primary inputs are
    pi_list, pi_map = [], {}
    ite_cond_nodes = [vv4_nm.get_children(u)[0] for u in topological_order if vv4_nm.get_op(u) == 'ITE']
    for u in ite_cond_nodes:
        if u not in pi_map:
            pi_name = 'x%d' % len(pi_list)
            pi_list.append((u, pi_name))
            pi_map[u] = pi_name

    # initialize a BDD with the primary inputs
    B = BDD([pi[1] for pi in pi_list])

    # start computing contexts: initialize cmap based on the fact that every 
    # node in deps must have a context of "True"
    cmap = {u: B.get_True() for u in deps if vv4_nm.is_func(u)}

    # from this, compute the contexts for the other nodes in topological_order
    parents_map = get_parents(topological_order, vv4_nm)

    def context_contribution_from_a_single_parent(u, p):
        pc = cmap[p]
        if vv4_nm.get_op(p) != 'ITE':
            return pc
        cond, t, f = vv4_nm.get_children(p)
        if u is cond:
            return pc
        pi_name = pi_map[cond]
        if u is t:
            return B.AND(pc, B.primary_inputs([pi_name])[0])
        return B.AND(pc, B.primary_input_complements([pi_name])[0])

    def context_from_parents_contexts(u):
        parents = parents_map[u]
        if not parents:
            return B.get_False()
        return B.OR(*[context_contribution_from_a_single_parent(u, p) for p in parents])

    for u in reversed(topological_order):
        if not vv4_nm.is_func(u):
            continue
        if u in cmap:
            continue
        cmap[u] = context_from_parents_contexts(u)

    # return
    return (pi_list, cmap, B)


@lru_cache(maxsize=None)
def compulsory_set(u, vv4_nm):

    """
    Given a DAG node u (and a vv4_Node_Manager instance), this function returns 
    the set of all the nodes in the DAG that *must* be evaluated in any 
    evaluation of u.

    If u is not a FUNC node (i.e., it is an INDEP node or CONST node), the 
    returned set includes just u.

    If u is an ITE node, the returned set includes u, plus all the nodes in the 
    compulsory set of the ITE condition, plus all the nodes that are in the 
    compulsory set of *both* the if ITE child and the else ITE child.

    If u is any other kind of node, the returned set includes u, plus all the 
    nodes that are in the compulsory set of *any* of u's children.
    """

    S = set([u])

    if not vv4_nm.is_func(u):
        return S

    op, children = vv4_nm.get_op(u), vv4_nm.get_children(u)
    child_sets = [compulsory_set(c, vv4_nm) for c in children]
    
    if op != 'ITE':
        return S.union(*child_sets)

    cond_set, if_set, else_set = child_sets
    return S.union(cond_set, set.intersection(if_set, else_set))


