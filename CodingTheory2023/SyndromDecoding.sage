import copy
import itertools



p = 3
F = GF(p)



def gen_message(k, n):
	m_coeffs = [0]*k
	for i in range(k):
		rand_index = ZZ.random_element(0,n)
		m_coeffs[i] = ZZ.random_element(0,p)
	return m_coeffs

def gen_error_w1(n):
	error_vec = [0]*n
	error_vec[ZZ.random_element(0,n)] = ZZ.random_element(1,p)
	return vector(F,error_vec)



def gen_random_binary(k, n):
	#set_random_seed(ZZ.random_element(0,200))
	#G = Matrix(F, k, n)
	while True:
		G = random_matrix(F, k, n)
		if G.rank() == k:
			break
	H = matrix(kernel(G.transpose()).basis())
	#H = Matrix(F, n-k, n)
	#row = 0
	#for i in range(Hzeros.nrows()):
	#	if sum([Hzeros[i][j] for j in range(Hzeros.ncols())]) > 0:
	#		H[row] = Hzeros[i]
	#		row+=1

	assert H.nrows() == n - k
	return G, H



def encode(m, G):
	assert len(m) == G.nrows()
	return m*G

def kbits(n, k):
    result = []
    for bits in itertools.combinations(range(n), k):
        s = [0] * n
        for bit in bits:
            s[bit] = 1
        result.append(vector(F,s))
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


def decode_random(H, syndrom_table, y):
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

n = 7
k = 3

G, H = gen_random_binary(k, n)
#print(G)
#print(H)

C = LinearCode(G)

D = codes.decoders.LinearCodeSyndromeDecoder(C)
#print(D.decoding_radius())
Stable = D.syndrome_table()
#print(Stable)
#print(type(Stable))


with open('solutions.txt', 'w') as f:
	for j in range(15):
		f.write('--------------- Student Name ---------------------'+"\n")
		G, H = gen_random_binary(k, n)
		f.write("Generator matrix: "+"\n")
		f.write(str(G)+"\n")
		#print(H)
		C = LinearCode(G)
		D = codes.decoders.LinearCodeSyndromeDecoder(C)
		f.write('dec radius: '+str(D.decoding_radius())+"\n")
		Stable = D.syndrome_table()
		f.write('Syndrome table:'+"\n")
		f.write(str(Stable)+"\n")

		m = gen_message(k, n)
		f.write('message: '+str(m)+"\n")
		c = encode(vector(m),G)
		f.write('codeword: '+ str(c)+"\n")
		e = gen_error_w1(n)
		f.write('error: '+str(e)+"\n")
		y = c + e
		f.write('received word: '+str(y)+"\n")
		s = H*y
		f.write('syndrome: '+str(s)+"\n")
		for i in Stable.keys():
			if i==s:
				f.write('Syndrome found!'+ str(s)+" "+str(Stable[i])+"\n")
				print(j, s, Stable[i])
				break
		f.write('------------------------------------'+"\n"+"\n")
