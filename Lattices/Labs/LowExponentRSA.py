from fpylll import IntegerMatrix,LLL, GSO, FPLLL

from Crypto.Util import number  # to generate prime numbers
from math import gcd, floor, sqrt
from random import randrange 
import numpy as np

p = number.getPrime(5)#1511 #number.getPrime(11)
q = number.getPrime(6)  #181001#

print('p, q = ', p, q)

N = p*q

#N = 9919284241247416948920551543278465872063230099610071763843336525689287934287926659255893398485432749689411356850582336939178442974545767722304129599329174472361750041060558296949269916243558819874445225035313606914816169307264051142707130580795527292695553859452458370197835276370801722192437370254489378754565675719517578364469392424265725148742846212089048643823356143303462198117746187760967164082409835695489435409357346880757104271587469236814872781657096591977250482489965960884579181622511200668877840950497591893224791531052004185881076981903

print('N =', N)

def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)

def modinv(a, m):
    g, x, y = egcd(a, m)
    if g != 1:
        raise Exception('modular inverse does not exist')
    else:
        return x % m

def arraymod(a, p):
	assert(p>1)
	for i in range(len(a)):
		a[i] = a[i]%p
	return a

e = 3
phiN = (p-1)*(q-1)
assert(gcd(e,phiN) == 1)

d = modinv(e,phiN)

print('d = ', d)
print('is 1? ', d*e % phiN)


S = 10#randrange(1,N-1)
x = 2 #randrange(1, floor(pow(sqrt(N),(1./e))) )
mes = (S+x)%N

print('x = ', x)

c = pow(mes, e, N)
print('c = ', c)

decrypted = pow(c,d,N)
print('is m? ', decrypted)

Xbound = 3#floor(pow(N,(1./e)))
print('Xbound = ', Xbound)

f = np.poly1d([pow(Xbound,3), 3*S*pow(Xbound,2), 3*S*S*Xbound, S*S*S-c]) #only for e = 3; TODO: implement for general e
print('f = ', f)
m = 3

# only for e = 3
def gpoly(u,v):
	xpolycoeff = [0]*(u+1)
	xpolycoeff[0] = pow(N,m-v)*pow(Xbound,u)
	p1 = np.poly1d(xpolycoeff);
	fprod = 1
	for i in range(v):
		fprod*=f
	res = p1*fprod
	return res.coeffs




w = e*(m+1) #lattice dimension

print(gpoly(0,0))
#print(gpoly(1,0))

indrow = 0
A = IntegerMatrix(w,w)
for v in range(m+1):
	for u in range(e):
		coeff_vector = gpoly(u,v)
		#print(v,u,coeff_vector)
		for icol in range(len(coeff_vector)):
			A[indrow,icol] = int(coeff_vector[len(coeff_vector)-icol-1])#.item()
		indrow+=1

print(A)

FPLLL.set_precision(120)
M = GSO.Mat(A, float_type="mpfr")
M.update_gso()
print('before LLL:', A[0].norm(), M.get_r(0,0))

L = LLL.Reduction(M, delta=0.9999, eta=0.5001)
L()
print('after LLL:', A[0].norm(), M.get_r(0,0))
print(A[0])
A0rev = list(A[0])[::-1]

hpoly = np.poly1d(A0rev)
print('hpoly:', hpoly)
print('eval at 2 = ', np.polyval(hpoly, 2)%(N^3))
print(hpoly.r)


