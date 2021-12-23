

p = 11
n = p-1

k = 6
d = n - k + 1

ff = GF(p)

a = 2
while True:
	if Mod(a,p).multiplicative_order() == n:
		break
	else: 
		a+=1
	print('a:', a)

print('generator:', a)

S = [0]*(n)
S[0] = 1
for i in range(p-1):
	print(i, ff(a**i))
	S[i] = ff(a**i)

print('Reed-Solomon code with params [', n, k, d,']')
print('evaluation set S = ', S)

def gen_h(k, S, ff):
	n = len(S)
	HMat = matrix(ff, n-k, n)
	for i in range(n-k):
		for j in range(n):
			HMat[i,j] = S[j]**(i+1)
	return HMat


def gen_message(k, S):
	m_coeffs = [0]*k
	nelements = len(S)
	for i in range(k):
		rand_index = ZZ.random_element(0,nelements)
		m_coeffs[i] = S[i]
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



def gen_error(nerrs, d, S):
	assert nerrs <= floor((d-1)/2.)
	n = len(S)
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




def WB_decode(k, S, y, ff):
	assert len(S)==len(y)
	n = len(S)

	deg_E = floor((n - k + 1)/2)
	deg_N = deg_E + k - 1

	print('degs:', deg_E, deg_N)
	
	A = []
	for i in range(len(S)):
		A.append([y[i]*(S[i]**j) for j in range(deg_E)] + [-(S[i]**j) for j in range(deg_N+1)] )

	AMat = matrix(ff, [Arow for Arow in A])

	#print(AMat)

	#AMat2 = AMat.echelon_form()
	#print('AMat2', AMat2)

	target_vec = vector([-y[i]*(S[i]**deg_E) for i in range(n)])
	print('target_vec:', target_vec)
	sol = AMat.solve_right(target_vec)
	print('sol:', sol)

	R.<x> = PolynomialRing(ff, 'x')
	epoly = sum([ sol[i]*x**i  for i in range(deg_E)])
	epoly += x**deg_E

	npoly = sum([ sol[i]*(x**(i-deg_E))  for i in range(deg_E,deg_E+deg_N+1)])

	#f = npoly / epoly
	f, r = npoly.quo_rem(epoly)
	print('epoly:', epoly)
	print('npoly:', npoly)
	print('f:', f)
	flist = list(R(f))
	print('y:', y)
	#c = vector([eval_poly(flist,S[i]) for i in range(len(S))])
	#c = vector([2*a + 1, 2*a, a + 2, 0, 2*a, 2*a+1, 1, a + 2])
	#print('c:', c)

	#Hmat = gen_h(k, S, ff)
	#print('H:')
	#print(Hmat)
	#print('syndrom:', Hmat*vector(y))
	#print('check:', Hmat*c)


	return f


def PetersonDecode(k, S, y, ff):
	assert len(S)==len(y)
	n = len(S)

	deg_E = floor((n - k + 1)/2)
	deg_G = deg_E-1
	print('deg_E:', deg_E, 'deg_G:', deg_G)

	Hmat = gen_h(k, S, ff)
	syndrom = Hmat*vector(y)
	print('syndrom:', syndrom)

	AMat = matrix(ff, deg_E+deg_G, n - k - 1)
	for i in range(deg_E):
		AMat[i]  = [0]*i + list(syndrom[:n-k-i-1])
	for i in range(deg_G):
		AMat[i+deg_E,i] = - 1 

	print('AMat:')
	print(AMat)

	target_vec = vector(ff, -syndrom[1:])
	print('target_vec:', target_vec)
	sol = AMat.solve_left(target_vec)

	evec = [1]+list(sol[:deg_E])
	gammavec = sol[deg_E:]

	print('evec:', evec, 'gammavec:', gammavec)

	R.<x> = PolynomialRing(ff, 'x')
	epoly = sum([evec[i]*x^i for i in range(len(evec))])
	print('epoly:', epoly, epoly.factor())

	#find roots
	for root in S:
		if(eval_poly(evec, root) == 0):
			print('root:', root)

	return 1 




m = gen_message(k, S)
print('m = ', m)
#m = [a+1, 0, a]
c = encode(m, S)
print('c = ', c)
e = gen_error(2, d, S)
print('e = ', e)
y = c + e
print('y = ', y)

decP = PetersonDecode(k, S, y, ff)
print('decP:', decP)


#m = [2*a+1, 2]
#c = encode(m, S)
#print('c = ', c)
"""
y = (a, 2*a + 2, 2*a + 2, 0, 2, a, 2, 2*a + 1)
#print('y = ', y)



decWB = WB_decode(k, S, y, ff)
print('dec:', decWB, decWB.coefficients())
print(encode(decWB.coefficients(), S))
"""


