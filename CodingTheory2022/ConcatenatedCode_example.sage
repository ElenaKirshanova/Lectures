import copy
import itertools


R = ZZ['x']
p = 2
n = 3
n_out = p**n - 1
f_cycl = R.cyclotomic_polynomial(n_out)

k_out = 3
d_out = (p**n - 1) - k_out + 1

F = GF(p)
Fx = PolynomialRing(F, 'x')
decomp = (Fx(f_cycl)).factor()

defining_poly = decomp[0][0]
ff.<a> = FiniteField(p**n, modulus = defining_poly)
S = [0]*(p**n - 1)
S[0] = 1
for i,x in enumerate(ff):
	#print(i,x, a**i)
	if not (i==0 or x ==1):
		S[i] = x
print('------------------------------------------- ')
print('------------ Concatenated code ------------ ')
print('------------------------------------------- ', '\n')
print('------------ Outer RS code ----------------')
print('Parans: p = ', 2, ', n = ', n, ', defining_poly:', defining_poly)
print('Reed-Solomon code with params [', n_out, k_out, d_out,']')
print('Evaluation set S = ', S, '\n')

def gen_h(k, S, ff):
	n = len(S)
	HMat = matrix(ff, n-k, n)
	for i in range(n-k):
		for j in range(n):
			HMat[i,j] = S[i]**(j+1)
	return HMat


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

def gen_binary_error(nerrs, n):
	error_vec = [0]*n
	error_pos = set()
	for i in range(nerrs):
		while True:
			error_pos_tmp = ZZ.random_element(0, n)
			if not error_pos_tmp in error_pos:
				error_pos.add(error_pos_tmp)
				break
		error_vec[error_pos_tmp] = 1
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

	f = npoly / epoly

	print('epoly:', epoly)
	print('npoly:', npoly)
	print('f:', f)

	return f



def gen_random_binary(k, n):
	set_random_seed(ZZ.random_element(0,200))
	G = Matrix(GF(2), k, n)
	while True:
		for i in range(n):
			zero_column = True
			while zero_column:
				column_weight = 0
				for j in range(k):
					G[j,i] = ZZ.random_element(0, 2)
					column_weight+=G[j,i]
				if column_weight>0:
					zero_column = False
		if G.rank() == k:
			break
	Hzeros = Matrix(GF(2), kernel(G.transpose())).echelon_form()
	H = Matrix(GF(2), n-k, n)
	row = 0
	for i in range(Hzeros.nrows()):
		if sum([Hzeros[i][j] for j in range(Hzeros.ncols())]) > 0:
			H[row] = Hzeros[i]
			row+=1
	assert H.nrows() == n - k
	return G, H



def random_enc(m, G):
	assert len(m) == G.nrows()
	return m*G

def kbits(n, k):
    result = []
    for bits in itertools.combinations(range(n), k):
        s = [0] * n
        for bit in bits:
            s[bit] = 1
        result.append(vector(GF(2),s))
    return result

def construct_syndrom_table(H, err_weight_bound):

	n = H.ncols()
	syndrom_table = {0:vector([0]*n)}
	for i in range(err_weight_bound+1):
		errs = kbits(n, i)
		for err in errs:
			#compute the syndrom for err
			#print('err:', err)
			s = H*err
			#check if s already has an error
			s_decimal = sum([ZZ(s[i])*(2**i) for i in range(len(s))])
			if not s_decimal in syndrom_table:
				syndrom_table[s_decimal] = err
				#print(s_decimal, err, s)
	len_syndrom_table = sum([binomial(n,i) for i in range(err_weight_bound+1)])

	return syndrom_table


def deocde_random(H, syndrom_table, y):
	assert H.ncols() == len(y)
	#syndrom_table = construct_syndrom_table(H, err_weight_bound)
	syndrom_y = H*y
	syndrom_y_decimal  = sum([ZZ(syndrom_y[i])*(2**i) for i in range(len(syndrom_y))])
	#print('deocde_random:', y, syndrom_y, syndrom_y_decimal)
	if not syndrom_y_decimal in syndrom_table:
		return -1
	error = syndrom_table[syndrom_y_decimal]
	return y + error

def if_in_code(H, c):
	assert len(c) == H.ncols()
	s = H*c
	return sum([ZZ(s[i]) for i in range(len(s))])==0

def code_with_spec_d(k, n, d):
	while True:
		G, H = gen_random_binary(k, n)

		C = [0]*(2**k)
		min_weight = 10000
		for i in range(2**k):
			binary_i = [0]*k
			short_binary_i = (Integer(i).digits(2))
			for j in range(len(short_binary_i)):
				binary_i[k-j-1] = short_binary_i[j]

			C[i] = vector(binary_i)*G
			wt_i = sum([ZZ(C[i][j]) for j in range(n)])
			if wt_i<min_weight and wt_i > 0:
				min_weight = wt_i
				min_codeword = C[i]


		print('min_weight:', min_weight)
		if (min_weight==d):
			break
	return G, H


G = Matrix(GF(2), [[1,0,0,1,1,1,0,0,1,0,0,1],[1,1,0,1,0,0,1,0,0,1,0,0],[1,0,1,1,0,0,0,1,0,0,1,0]])
Hzeros = Matrix(GF(2), kernel(G.transpose())).echelon_form()
n_in = G.ncols()
k_in = G.nrows()
d_in = 5

#print("Hzeros:")
#print(Hzeros)
H = Matrix(GF(2), n_in-k_in, n_in)
row = 0
#for i in range(Hzeros.nrows()):
#if sum([Hzeros[i][j] for j in range(Hzeros.ncols())]) > 0:
#		H[row] = Hzeros[i]
#		row+=1
for i in range(n_in-k_in):
	H[i] = Hzeros[i]
assert H.nrows() == n_in - k_in


print('------------ Binary inner code ------------ ')
print('Params: n_in =', n_in, 'k_in =', k_in, 'd_in =', d_in)
print("G:")
print(G)
print("H:")
print(H, '\n')

print('Concatenated code params: n = ', n_in*n_out, ' k = ', k_out*k_in, ' d >= ', d_in*d_out, '\n')

# generate a message
m = gen_message(k_out, S)
#print('m = ', m, '\n')

#encode the message with the outer code
c_out = encode(m, S)
#print('c\' = ', c_out, '\n')


#encode the message with the inner code
V, from_V, to_V = ff.vector_space(F, map=True)
cout_isom = [0]*n_out
c_in = [0]*n_out

for i in range(n_out):
	cout_isom[i] = to_V(c_out[i])
	c_in[i] = random_enc(to_V(c_out[i]), G)

#print('c_isomorph = ', cout_isom, '\n')
#print('c = c_isomorph*G = ', c_in, '\n')


d = d_out * d_in

# generate the error
e = gen_binary_error(floor((d-1)/2.), n_out*n_in)
#print('e:', e)


err_max_weight = floor((d_in-1)/2.)
#print('err_max_weight:', err_max_weight)
syn_table = construct_syndrom_table(H,err_max_weight)


# scrumbled code-word

y = copy.deepcopy(c_in)
for i in range(n_out):
	y[i]+= e[i*n_in:(i+1)*n_in]
	#print(i, e[i*n_in:(i+1)*n_in])
	#assert (sum(ZZ(e[i*n_in:(i+1)*n_in][j]) for j in range(n_in) ))<=3
# print('y:', y, '\n')
#print(type(y))
#print(type(y[0]))


y = [vector(GF(2),(0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1)),
	vector(GF(2),(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)),
			vector(GF(2),(0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0)),
			vector(GF(2),(0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1)),
			vector(GF(2),(0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0)),
			vector(GF(2),(0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0)),
			vector(GF(2),(0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1))]


w_prime = [0]*n_out
for i in range(n_out):
	w_i = deocde_random(H, syn_table, y[i])
	#print(i, y[i], w_i)
	if not w_i == -1:
		m = G.solve_left(w_i)
		w_prime[i] = from_V(m)
	else:
		w_prime[i] = "?"
print('w_prime:', w_prime, '\n')

int_points = []
for i in range(len(w_prime)):
	if not w_prime[i] == "?":
		int_points.append([S[i], w_prime[i]])


ff2 = PolynomialRing(GF(p**n,'a'), 'x')
f_inter = ff2.lagrange_polynomial(int_points)
print('f_inter:', f_inter)






"""
def Hamming_enc(m):
	assert len(m) == 4
	G = transpose(Matrix(GF(2), [
		[1, 1, 0, 1], [1, 0, 1, 1],
		[1, 0, 0, 0], [0, 1, 1, 1],
		[0, 1, 0, 0], [0, 0, 1, 0],
		[0, 0, 0, 1]
		]))
	return m*G

def Hamming_dec(y):
	assert len(y) == 7
	H = Matrix(GF(2),[
		[1, 0, 1, 0, 1, 0, 1],
		[0, 1, 1, 0, 0, 1, 1],
		[0, 0, 0, 1, 1, 1, 1]
		])
	error_pos_vec = H*y
	error_pos = sum([ZZ(error_pos_vec[i])*(2**i) for i in range(3)])
	if error_pos==0:
		return y
	error_vec = [0]*7
	error_vec[error_pos-1] = 1
	c = y - vector(GF(2),error_vec)
	return c

def if_in_hamming(c):
	assert len(c) == 7
	H = Matrix(GF(2),[
		[1, 0, 1, 0, 1, 0, 1],
		[0, 1, 1, 0, 0, 1, 1],
		[0, 0, 0, 1, 1, 1, 1]
		])

	s = H*c
	return sum([ZZ(s[i]) for i in range(len(s))])==0








print(c_in)






"""
