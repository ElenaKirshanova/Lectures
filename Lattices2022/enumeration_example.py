from fpylll import *

A = IntegerMatrix.random(40, "qary", k=25, bits=30)
#print(A)

M = GSO.Mat(A)
L = LLL.Reduction(M, delta=0.99, eta=0.501)
L()

enum = Enumeration(M, strategy=EvaluatorStrategy.BEST_N_SOLUTIONS, sub_solutions=True) #интанция объекта Enumeration
res = enum.enumerate(0, 40, 0.8*M.get_r(0, 0), 0) # запуск метода enumerate, запуск самого перечисления
print(([int(res[0][1][i]) for i in range(len(res[0][1]))]))
#for a,b in enum.sub_solutions:
#    print(a, b)

print(enum.get_nodes()) # число перебранных x_i'ых
