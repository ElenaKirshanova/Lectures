
P = Primes()
i = 3
while True:
	p = P.next(2^(651+i))	#1511 #number.getPrime(11)
	q = P.next(2^(769+2*i))  #181001#
	if (not (p-1)%3 == 0) and (not (q-1)%3 == 0):
		break;
	i = i+1
	print(i)

#print('p, q = ', p, q)

#N = p*q

#print('N = ', N)

N = 7427348605337420439226351301259396736338668628478026364247537354940635099417985194658970761928680925182008511152254688145103860128004202503366474283301612075177785324580367485485658736331441943472952155621639662643715068050809082488144556149444490361655502468281994103450718847571742070878683972591764582106285078065864827820587920185765360247986736413307433316395696422364074349807321647196675748416486392177198614794875770634343

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

r = 2718281828
m1 = 3141592653589793238462643383279502884197169399
m2 = m1 + r

#print('gcds:', gcd(N,m1), gcd(N,m2))

c1 = ZZ(pow(m1, e, N))
c2 = ZZ(pow(m2, e, N))

c1 = 31006276680299820175476315067101395202225288554778669509438887512651971587918750955037430926079670744122698892139964166907513659086428199
c2 = 31006276680299820175476315067101395282710387433868750322697813786430647302673358518858061044167142934256709846999692381475803695916434083

print('c1 = ', c1)
print('c2 = ', c2)
print(c1-c2)
print(c2-c1)

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

r = 2718281828

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
