from fpylll import *

A = IntegerMatrix.random(40, "qary", k=25, bits=15)
#print(A)

v = [0]*A.ncols
for i in range(A.ncols): v[i]=A[0][i]+11*((-1)**A[0][i])

print('lattice vec:', A[0])
print('target vec:', v)


M = GSO.Mat(A)
L = LLL.Reduction(M, delta=0.99, eta=0.501)
L()
M.update_gso()

# см. реализацию по ссылке https://github.com/fplll/fpylll/blob/master/src/fpylll/fplll/gso.pyx
coef = M.babai(v) #
print('coef:', coef)
vec = IntegerMatrix.from_iterable(1, A.ncols, coef)*A
print('result:', vec)
