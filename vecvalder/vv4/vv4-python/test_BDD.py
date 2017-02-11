
from vv4.BDD_utils import BDD

var_names = ['a', 'b', 'c']
B = BDD(var_names)

a, b, c = B.primary_inputs()
a_bar, b_bar, c_bar = B.primary_input_complements()

T1 = B.AND(a_bar, b_bar, c)
T2 = B.AND(a_bar, c_bar, b)
T3 = B.AND(a, b_bar, c_bar)
T4 = B.AND(a, b, c)
f = B.OR(T1, T2, T3, T4)
g = B.NOT(f)

p = B.OR(f, g)
q = B.AND(f, g)

print('Printing f:')
B.print(f)
print('')

print('Printing g:')
B.print(g)
print('')

print('Printing p (should be logical 1):')
B.print(p)
print('')

print('Printing q (should be logical 0):')
B.print(q)
print('')

print('Printing everything:')
B.print()

