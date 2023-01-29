from fpylll import *
import copy
from math import log, exp, sqrt, floor, ceil

inp = open("hidden.txt", "r")
p = int(inp.readline())
#print(p)

t = []
msbs = []
for data in inp:
    lst = data.split(" ")
    assert(len(lst)==2)
    t.append(int(lst[0]))
    msbs.append(int(lst[1].rstrip()))

def new_instance(t, msbs, p):
    t_ = [0]*(len(t)-1)
    msbs_ = [0]*(len(t)-1)
    for i in range(len(t)-1):
        t_[i] = (t[i+1]*pow(t[0], p-2, p)) % p
        msbs_[i] =( msbs[i+1] - t_[i]*msbs[0]) % p
    return t_, msbs_

t_, msbs_ = new_instance(t, msbs, p)


n = floor(log(p,2))
k = ceil(sqrt(n)) + ceil(log(n, 2))
target = msbs_+[int(p / 2**(k+2))]


def build_basis(t, p):
    n = len(t)
    A = IntegerMatrix(n+1,n+1)
    for i in range(n):
        A[i,i] = p
        A[n,i] = t[i]
        #A[n, i] = msbs[n+1]
    A[n, n] = 1
    return A

A = build_basis(t_, p)
print(A)
#print(A.nrows)
Acopy = copy.deepcopy(A)

FPLLL.set_precision(150)


U = IntegerMatrix.identity(A.nrows)
UInv = IntegerMatrix.identity(A.nrows)
M = GSO.Mat(Acopy, float_type='mpfr', U=U, UinvT=UInv)
M.update_gso()


L = LLL.Reduction(M, delta = 0.99, eta=0.501)
L()

#print(UInv.transpose()*Acopy) # == A

M.update_gso()


error = M.babai(target)
#print('error:', error)
coeff = IntegerMatrix.from_iterable(1, len(error), error)*Acopy
#print(coeff)
#print(target)
print([list(coeff[0])[i]-target[i] for i in range(len(target))])

k0 = list(coeff[0])[0]*pow(t_[0], p-2, p)%p
print(k0)


alpha_ = (k0+msbs[0])*pow(t[0], p-2, p)%p
print(alpha_)



#print(abs(target[0]-coeff[0][0]))
#alpha = 874856421902
#print((alpha*t[0])%p - msbs[0])
#print((alpha*t[1])%p - msbs[1])

#x = [-int((alpha*t[0]-(alpha*t[0])%p)/p) for i in range(n)]+[alpha]
#close = IntegerMatrix.from_iterable(1, n+1, x)
#print(close)

#print(x*p + alpha*t[0])
#print((alpha*t[0])%p)
#print(msbs[0])
#x = [-int((alpha*t[i]-(alpha*t[i])%p)/p) for i in range(n)]+[alpha]
#xvec = IntegerMatrix.from_iterable(1, n, x)
#print(xvec*A)

# alpha_ = (coeff[i]/t[i]) in F_p
