
P = Primes()
i = 3
while True:
	p = P.next(2^(651+i))	#1511 #number.getPrime(11)
	q = P.next(2^(769+2*i))  #181001#
	if (not (p-1)%3 == 0) and (not (q-1)%3 == 0):
		break;
	i = i+1
	print(i)

print('p, q = ', p, q)

N = p*q

print('N = ', N)

N = 14854697210674840878452702602518793472677337256956052728495074709881270198835970389317941523857361850364017022304509376290207720256008405006732948566603224150355570649160734970971317472662883886886486338814746592921408393119181267181497570651798768021797205337230966145688421501488105679067409941062462734971969722385130944192813663982174957905597388266981965790521425259508395687922107614040885991691056092320226194800503374757179

#N = 9919284241247416948920551543278465872063230099610071763843336525689287934287926659255893398485432749689411356850582336939178442974545767722304129599329174472361750041060558296949269916243558819874445225035313606914816169307264051142707130580795527292695553859452458370197835276370801722192437370254489378754565675719517578364469392424265725148742846212089048643823356143303462198117746187760967164082409835695489435409357346880757104271587469236814872781657096591977250482489965960884579181622511200668877840950497591893224791531052004185881076981903


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

#r = 1122334455
#m1 = 3141592653589793238462643383279502884197169399
#m2 = m1 + r

#print('gcds:', gcd(N,m1), gcd(N,m2))

#c1 = ZZ(pow(m1, e, N))
#c2 = ZZ(pow(m2, e, N))

c1 = 31006276680299820175476315067101395202225288554778669509438887512651971587918750955037430926079670744122698892139964166907513659086428199
c2 = 31006276680299820175476315067101395235456279784465349644746371087297187055640323870771651352163943015674692663683581458592537440630679864

print('c1 = ', c1)
print('c2 = ', c2)

Xbound = floor(0.5*pow(N,(1./9)))
print('Xbound = ', Xbound)

var('z')
R = PolynomialRing(ZZ, 'z')
res = z^9 + (3*c1 - 3*c2)*z^6 + 3*z^3*(c1^2+7*c1*c2+c2^2) + (c1-c2)^3
resX = (Xbound*z)^9 + (3*c1 - 3*c2)*(Xbound*z)^6 + 3*(Xbound*z)^3*(c1^2+7*c1*c2+c2^2) + (c1-c2)^3

m = 5

def gpoly(u,v):
	global m,Xbound,fXbound,N
	return N^(m-v)*z^u*res^v

def gpolyXbound(u,v):
	global m,Xbound,fXbound,N
	return N^(m-v)*Xbound^u*z^u*resX^v

def eval(polycoeffs,a,N,m):
	tmp = 0
	for item in (polycoeffs):
		tmp+=mod(item[0]*a^item[1],(N^m))
	return tmp % (N^m)

deg = res.degree(z)
w = deg*(m+1) #lattice dimension
print('lattice dim:', w)


#print('test res:',eval(res.coefficients(),r,N,1))
"""
assert(eval(res.coefficients(),r,N,1)==0)
for v in range(m+1):
	for u in range(deg):
		polycoeff = gpoly(u,v)
		assert(eval(polycoeff.coefficients(),r,N,m)==0)
		#print('test:', u,v,eval(polycoeff.coefficients(),r,N,m))
"""

indrow = 0
A = matrix(ZZ, w,w)
for v in range(m+1):
	for u in range(deg):
		polycoeff = gpolyXbound(u,v).coefficients()
		for item in polycoeff:
			A[indrow,item[1]] = item[0]
		indrow+=1

#print(A)

ALLL = A.LLL(delta=0.9999, eta=0.5001, algorithm='fpLLL:proved')
#print(ALLL[0])
#for i in range(ALLL.nrows()):
#	print(ALLL[i].norm().n())
check = 0
hpoly = 0
for i in range(w):
	check+=(ALLL[0][i]/(Xbound^i)*x^i)
	hpoly+=(ALLL[0][i]/(Xbound^i)*z^i)
print('hpoly = ', hpoly)
print('roots = ', hpoly.roots(ring=ZZ))

#finding m

r = 1122334455

print(( (z-r)^3 - c1 ).gcd( ( (z)^3 - c2 )))


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
