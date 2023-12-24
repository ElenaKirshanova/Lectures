R = ZZ['x']
p = 2
kappa = 3
f_cycl = R.cyclotomic_polynomial(p**kappa - 1)


F = GF(p)
Fx = PolynomialRing(F, 'x')
decomp = (Fx(f_cycl)).factor()
#print(decomp)
defining_poly =  decomp[1][0]
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
g = Rff(x^2+x+1)#Rff(x^2 + a*x + 2*a)#Rff.irreducible_element(t)
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

def gen_error(nerrs, n):
	error_vec = [0]*n
	error_pos = set()
	for i in range(nerrs):
		while True:
			error_pos_tmp = ZZ.random_element(0, n)
			if not error_pos_tmp in error_pos:
				error_pos.add(error_pos_tmp)
				break
		error_vec[error_pos_tmp] = ZZ.random_element(1,p)
	return vector(GF(2),error_vec)

def gen_parity(L, g):
	n = len(L)
	glist = list(g)
	t  = g.degree()
	V = matrix.vandermonde(L).transpose()
	V1 = V[0:t]
	Gdiag = matrix.diagonal([1/g(L[i]) for i in range(n)])
	return V1*Gdiag

n = 8
L = [0, 1, a, a^2, a+1, a^2+a, a^2+a+1, a^2+1]#[1, 2, 2*a + 2, a, 2*a, a + 1, 2*a + 1] #constructL(S, n)
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

Rquo = Rff.quotient(g*g, 'x1')
x1 = Rquo.gen()
Linv = [0]*n
for i in range(len(L)):
    print(i, ':', L[i], ': ', Rquo(1/(x1-L[i])))
    Linv[i] = Rquo(1/(x1-L[i]))

k = n-kappa*Hbar.nrows()
print('k = ', k)
G = matrix(H.transpose().kernel().basis())

for i in range(20):
	mes = gen_message(k,p)
	c = mes*G
	print('m = ', mes)
	print('c = ', c)

	e = gen_error(2, n)
	print('e = ', e)

	y = c+e
	print('y = ', y)

	syndrome = sum([y[i]*Linv[i] for i in range(n)])
	print('syndrome:', syndrome)



"""
m =  (1, 1)
c =  (1, 1, 1, 1, 0, 0, 1, 0)
e =  (0, 0, 1, 0, 0, 1, 0, 0)
y =  (1, 1, 0, 1, 0, 1, 1, 0)
syndrome: (a + 1)*x1^3 + (a^2 + 1)*x1^2 + (a + 1)*x1
m =  (1, 1)
c =  (1, 1, 1, 1, 0, 0, 1, 0)
e =  (0, 0, 0, 1, 0, 0, 0, 1)
y =  (1, 1, 1, 0, 0, 0, 1, 1)
syndrome: (a + 1)*x1^2 + (a + 1)*x1 + a^2 + 1
m =  (0, 1)
c =  (0, 0, 1, 1, 1, 1, 1, 1)
e =  (0, 1, 0, 0, 1, 0, 0, 0)
y =  (0, 1, 1, 1, 0, 1, 1, 1)
syndrome: (a^2 + a + 1)*x1^3 + (a^2 + a)*x1^2 + a*x1 + a^2 + a
m =  (1, 0)
c =  (1, 1, 0, 0, 1, 1, 0, 1)
e =  (1, 0, 0, 0, 0, 1, 0, 0)
y =  (0, 1, 0, 0, 1, 0, 0, 1)
syndrome: a^2*x1^3 + a^2*x1^2 + (a^2 + a)*x1 + a^2 + 1
m =  (0, 1)
c =  (0, 0, 1, 1, 1, 1, 1, 1)
e =  (1, 0, 1, 0, 0, 0, 0, 0)
y =  (1, 0, 0, 1, 1, 1, 1, 1)
syndrome: (a^2 + a + 1)*x1^3 + x1^2 + (a^2 + 1)*x1 + a^2 + 1
m =  (0, 0)
c =  (0, 0, 0, 0, 0, 0, 0, 0)
e =  (0, 0, 0, 0, 0, 1, 0, 1)
y =  (0, 0, 0, 0, 0, 1, 0, 1)
syndrome: (a^2 + a)*x1^3 + (a^2 + a)*x1^2 + (a + 1)*x1 + a^2 + a
m =  (1, 1)
c =  (1, 1, 1, 1, 0, 0, 1, 0)
e =  (0, 0, 0, 1, 0, 1, 0, 0)
y =  (1, 1, 1, 0, 0, 1, 1, 0)
syndrome: (a^2 + a)*x1^3 + (a^2 + 1)*x1^2 + a + 1
m =  (0, 1)
c =  (0, 0, 1, 1, 1, 1, 1, 1)
e =  (1, 0, 0, 0, 0, 0, 0, 1)
y =  (1, 0, 1, 1, 1, 1, 1, 0)
syndrome: a*x1^3 + a*x1^2 + (a^2 + 1)*x1 + a + 1
m =  (0, 1)
c =  (0, 0, 1, 1, 1, 1, 1, 1)
e =  (0, 1, 0, 0, 0, 0, 1, 0)
y =  (0, 1, 1, 1, 1, 1, 0, 1)
syndrome: a^2*x1^3 + a*x1 + a + 1

m =  (0, 1)
c =  (0, 0, 1, 1, 1, 1, 1, 1)
e =  (0, 1, 0, 1, 0, 0, 0, 0)
y =  (0, 1, 1, 0, 1, 1, 1, 1)
syndrome: a*x1^3 + (a^2 + a + 1)*x1 + a^2 + a
m =  (0, 1)
c =  (0, 0, 1, 1, 1, 1, 1, 1)
e =  (0, 0, 0, 0, 1, 1, 0, 0)
y =  (0, 0, 1, 1, 0, 0, 1, 1)
syndrome: (a + 1)*x1^3 + (a + 1)*x1^2 + (a^2 + 1)*x1 + a + 1

syndrome: a^2*x1^3 + (a^2 + 1)*x1^2 + (a^2 + a + 1)*x1 + a^2 + 1


syndrome: (a^2 + a + 1)*x1^3 + x1^2 + (a^2 + 1)*x1 + a^2 + 1
m =  (1, 0)
c =  (1, 1, 0, 0, 1, 1, 0, 1)
e =  (0, 0, 1, 1, 0, 0, 0, 0)
y =  (1, 1, 1, 1, 1, 1, 0, 1)
syndrome: (a^2 + 1)*x1^3 + (a + 1)*x1 + a + 1
m =  (1, 0)
c =  (1, 1, 0, 0, 1, 1, 0, 1)
e =  (0, 0, 0, 0, 1, 1, 0, 0)
y =  (1, 1, 0, 0, 0, 0, 0, 1)
syndrome: (a + 1)*x1^3 + (a + 1)*x1^2 + (a^2 + 1)*x1 + a + 1

m =  (1, 1)
c =  (1, 1, 1, 1, 0, 0, 1, 0)
e =  (0, 0, 0, 0, 1, 1, 0, 0)
y =  (1, 1, 1, 1, 1, 1, 1, 0)
syndrome: (a + 1)*x1^3 + (a + 1)*x1^2 + (a^2 + 1)*x1 + a + 1

m =  (1, 0)
c =  (1, 1, 0, 0, 1, 1, 0, 1)
e =  (1, 1, 0, 0, 0, 0, 0, 0)
y =  (0, 0, 0, 0, 1, 1, 0, 1)
syndrome: x1^2 + x1
"""


#syndrome = sum([c[i]*Linv[i] for i in range(n)])
#print('syndrome c:', syndrome)



#print(Rquo((x1+1)*(2*a*x1+a+1)))

#print(Rquo(1/(2*a)))
#print(Rquo(1/(a)))
