

def gen_message(k, S):
	m_coeffs = [0]*k
	nelements = len(S)
	for i in range(k):
		rand_index = ZZ.random_element(0,nelements)
		m_coeffs[i] = S[rand_index]
	return m_coeffs 

def eval_poly(f, y):
	res = 0
	for i in range(len(f)):
		res+=f[i]*(y**i)
	return res



def encode(m, S):
	c = [0]*len(S)
	for i in range(len(S)):
		c[i] = eval_poly(m, S[i])
	return vector(c)


def gen_error(nerrs, n):
	error_vec = [0]*n
	error_pos = set()
	for i in range(nerrs):
		while True:
			error_pos_tmp = ZZ.random_element(0, n)
			if not error_pos_tmp in error_pos:
				error_pos.add(error_pos_tmp)
				break
		error_vec[error_pos_tmp] = S[ZZ.random_element(0,n)]
	return vector(error_vec)


p = 7
F = GF(p)

a = 3 # generator

k = 2 # code dimension
n = 6 # code length
nerrors = n/2 # number of errors

S = [0]*(n)
S[0] = 1
for i in range(p-1):
	#print(i, F(a**i))
	S[i] = F(a**i)

print('S:', S)


m = gen_message(k,S)
c = encode(m, S)
e = gen_error(nerrors,n)

y = c+e

#y = vector(F, [1,0,1,0,3,5])

print('m = ', m)
print('c = ', c)
print('e = ', e)
#print('y = ', y)

#y = [5, 5, 6, 0, 2, 6]
#y =  [2, 4, 1, 2, 5, 2]
y = [6, 0, 4, 3, 3, 3]

assert(n>= 3*k-1)

Qmat = matrix(F, n, 3*k-1)
bvec = vector(F, n)

print('# unknowns', 3*k-1)

Bcoeffs = k #number of coeffs in B
Ccoeffs = 2*(k-1)+1  #number of coeffs in C

for neq in range(3*k-1):
	#coeffs of the polynom B
	for i in range(Bcoeffs):
		Qmat[neq, i] = (-(S[neq])^i)*y[neq]
	#coeffs of the polynom C
	for j in range(Ccoeffs):
		Qmat[neq, Bcoeffs+j] = (S[neq])^j
	bvec[neq] = -(y[neq]*y[neq])

print(Qmat)
print(bvec)

print(rank(Qmat))
sol = Qmat.solve_right(bvec) # Qmat * sol = bvec mod p
print(sol)

Blist = list(sol[:k])
Clist = list(sol[k:])

Fx = PolynomialRing(F, 'x')
Bpoly = Fx(Blist)
Cpoly = Fx(Clist)

x,y = PolynomialRing(F, 2, ['x','y']).gens()

fpoly = y*y - y*Bpoly + Cpoly
print(fpoly)
print(fpoly.factor())
"""


print(Bpoly, Cpoly)
#x = Fx.gens()[0]

Fxy = PolynomialRing(Fx, 'y')
fbivar = y*y - y*Bpoly+Cpoly
print(fbivar)
print(fbivar.factor())
"""
#s1 = vector(F, [3,1,4,5,1])
#print(Qmat*s1)

