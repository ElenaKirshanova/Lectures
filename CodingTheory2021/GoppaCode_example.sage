R = ZZ['x']
p = 3
kappa = 2
f_cycl = R.cyclotomic_polynomial(p**kappa - 1)


F = GF(p)
Fx = PolynomialRing(F, 'x')
decomp = (Fx(f_cycl)).factor()
#print(decomp)
defining_poly =  x^2 + 2*x + 2 #decomp[1][0]
print('defining_poly:', defining_poly)

ff.<a> = FiniteField(p**kappa, modulus = defining_poly)
S = [0]*(p**kappa - 1)
S[0] = 1
for i,ell in enumerate(ff):
	#print(i,x)
	if not (i==0 or ell ==1):
		S[i] = ell

for i in range(p^kappa):
    print(i, a^i)

t = 2 #also the number of errors Goppa code can decode if binary
Rff = PolynomialRing(ff, 'x')
x = Rff.gen()
g = Rff(x^2 + a*x + 2*a)#Rff.irreducible_element(t)
print('g:', g)



def constructL(S, n):
	L = [0]*n
	pos = set()
	for j in range(n):
		while True:
			pos_tmp = ZZ.random_element(0, n)
			if not pos_tmp in pos:
				pos.add(pos_tmp)
				break
		L[j] = S[pos_tmp]
	return L

def gen_message(k, p):
	m = [0]*k
	for i in range(k):
		m[i] = ZZ.random_element(0,p)
	return vector(GF(p),m)

def gen_parity(L, g):
	n = len(L)
	glist = list(g)
	t  = g.degree()
	V = matrix.vandermonde(L).transpose()
	V1 = V[0:t]
	Gdiag = matrix.diagonal([1/g(L[i]) for i in range(n)])
	return V1*Gdiag

n = 7
L = [1, 2, 2*a + 2, a, 2*a, a + 1, 2*a + 1] #constructL(S, n)
print("L:", L)

Hbar = gen_parity(L,g)
print(Hbar)
V, from_V, to_V = ff.vector_space(F, map=True)
H = matrix(F, kappa*Hbar.nrows(), n)
for i in range(Hbar.nrows()):
	for j in range(n):
		tmp_vec = to_V(Hbar[i,j])
		for k in range(kappa):
			H[kappa*i+k, j] = tmp_vec[k]

print(H)

k = n-kappa*Hbar.nrows()
G = matrix(H.transpose().kernel().basis())
mes = gen_message(k,p)
c = mes*G

#c = vector(GF(p), [0, 1, 1, 1, 2, 2, 0])


print('k = ', k)
print('m = ', mes)
print('c = ', c)

e = vector(GF(p),[0]*n)
e[2] = 2

#y = [1, 0, 1, 0, 2, 0, 1]
y = c+e
print('y = ', y)

Rquo = Rff.quotient(g, 'x1')
x1 = Rquo.gen()
Linv = [0]*n
for i in range(len(L)):
    print(i, ':', L[i], ': ', Rquo(1/(x1-L[i])))
    Linv[i] = Rquo(1/(x1-L[i]))

#syndrome = sum([c[i]*Linv[i] for i in range(n)])
#print('syndrome c:', syndrome)

syndrome = sum([y[i]*Linv[i] for i in range(n)])
print('syndrome:', syndrome)

#print(Rquo((x1+1)*(2*a*x1+a+1)))

#print(Rquo(1/(2*a)))
#print(Rquo(1/(a)))
