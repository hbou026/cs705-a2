#!/usr/bin/env python3

from z3 import Ints, Solver, sat, Or, And, Consts, BoolSort, Not, Xor 

def eq1(A, B, C, s, Y1):
    # Y1 = (!A && B && C) || (A && !B && C) || (A && B && !C) || (A && B && C)
    s.add(Y1 == Or(And(Not(A), B, C), And(A, Not(B), C), And(A, B, Not(C)), And(A, B, C)))

def eq2(A, B, C, s, Y2):
    # Y2 = (A && B) || (B && C) || (A && C)
    s.add(Y2 == Or(And(A, B), And(B, C), And(A, C)))

if __name__ == '__main__':
    A, B, C = Consts('A B C', BoolSort())
    Y1 = Consts('Y1', BoolSort())[0] # Consts returns list so use [0]
    s = Solver()
    eq1(A, B, C, s, Y1)
    Y2 = Consts('Y2', BoolSort())[0]
    eq2(A, B, C, s, Y2)

    # mitre: Y1 xor Y2. If different at any time then not equivalent.
    s.add(Xor(Y1, Y2))

    # Check equivalence
    if s.check() == sat:
        print('Not Equivalent!')
        print(s.model())
    else:
        print('Equivalent!')


    