
P = Primes()
p = P.next(80)	#1511 #number.getPrime(11)
q = P.next(97)  #181001#

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

r = 3
m1 = 10
m2 = m1 + r

c1 = ZZ(pow(m1, e, N))
c2 = ZZ(pow(m2, e, N))

Xbound = 6#floor(pow(N,(1./e)))
print('Xbound = ', Xbound)

var('z')
R = PolynomialRing(ZZ, 'z')
res = z^9 + (3*c1 - 3*c2)*z^6 + 3*c2^2*z^3 + (c1-c2)^3
resX = (Xbound*z)^9 + (3*c1 - 3*c2)*(Xbound*z)^6 + 3*c2^2*(Xbound*z)^3 + (c1-c2)^3

m = 4

# only for e = 3
def gpolyXbound(u,v):
	global m,Xbound,fXbound,N
	return N^(m-v)*Xbound^u*z^u*resX^v

def eval(polycoeffs,a,N,m):
	tmp = 0
	for item in (polycoeffs):
		tmp+=mod(item[0]*a^item[1],(N^m))
	return tmp % (N^m)

w = e*(m+1) #lattice dimension

indrow = 0
A = matrix(ZZ, w,w)
for v in range(m+1):
	for u in range(e):
		polycoeff = gpolyXbound(u,v).coefficients()
		for item in polycoeff:
			A[indrow,item[1]] = item[0]
		indrow+=1

print(A)

ALLL = A.LLL(delta=0.9999, eta=0.5001, algorithm='fpLLL:proved')
print(ALLL[0])
for i in range(ALLL.nrows()):
	print(ALLL[i].norm().n())
check = 0
hpoly = 0
for i in range(w):
	check+=(ALLL[0][i]/(Xbound^i)*x^i)
	hpoly+=(ALLL[0][i]/(Xbound^i)*z^i)
print('hpoly = ', hpoly)
print('roots = ', hpoly.roots(ring=ZZ))
"""
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
"""

