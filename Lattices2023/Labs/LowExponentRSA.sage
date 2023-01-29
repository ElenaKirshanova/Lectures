
P = Primes()
p = P.next(2^529)#1511 #number.getPrime(11)
q = P.next(2^657)  #181001#

print('p, q = ', p, q)

N = p*q

N = 7427348605337420439226351301259396736338668628478026364247537354940635099417985194658970761928680925182008511152254688145103860128004202503366474283301612075177785324580367485485658736331441943472952155621639662643715068050809082488144556149444490361655502468281994103450718847571742070878683972591764582106285078065864827820587920185765360247986736413307433316395696422364074349807321647196675748416486392177198614794875770634343

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
#phiN = (p-1)*(q-1)
#assert(gcd(e,phiN) == 1)

#d = modinv(e,phiN)

#print('d = ', d)
#print('is 1? ', d*e % phiN)


S = 10#randrange(1,N-1)
x = 5 #randrange(1, floor(pow(sqrt(N),(1./e))) )
mes = (S+x)%N

print('x = ', x)

#c = pow(mes, e, N)
#print('c = ', c)

c = 31006276680299820175476315067101395202225288554778669509438887512651971587918750955037430926079670744122698892139964166907513659086428199

#decrypted = pow(c,d,N)
#print('is m? ', decrypted)

Xbound = 6#floor(pow(N,(1./e)))
print('Xbound = ', Xbound)

var('z')
R = PolynomialRing(ZZ, 'z')
f = (z)^3 + 3*S*(z)^2+3*S^2*z+S^3 - ZZ(c)
fXbound = (Xbound*z)^3 + 3*S*(Xbound*z)^2+3*S^2*z*Xbound+S^3 - ZZ(c)
print('f = ', f)
m = 4

# only for e = 3
def gpolyXbound(u,v):
	global m,Xbound,fXbound,N
	return N^(m-v)*Xbound^u*z^u*fXbound^v

def gpoly(u,v):
	global m,f
	return N^(m-v)*z^u*f^v

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

#print(A)

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
