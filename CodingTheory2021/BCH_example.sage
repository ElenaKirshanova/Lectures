
def extended_euclid_break(a,b,quo=lambda a,b:a//b):
    r0 = a; r1 = b
    s0 = 1; s1 = 0
    t0 = 0; t1 = 1

    deg_t0 = 0
    deg_r0 = r0.degree()
    #while r1 != 0:
    #while deg_r1>=deg_t1:
    while deg_t0<=deg_r0:
        q = quo(r0, r1)
        r0, r1 = r1, r0 - q * r1
        s0, s1 = s1, s0 - q * s1
        t0, t1 = t1, t0 - q * t1

        try:
            deg_t0 = t0.degree()
        except:
            deg_t0 = 0

        deg_r0 = r0.degree()

        #print('r:', r0, r1)
        #print('s:', s0, s1)
        #print('t:', t0, t1)
        #print(deg_s1, deg_r1)

        #print('--------')
        #print(deg_t0, deg_r0)
        #print(t0*b+a*s0)
        #print(r0)
        #print(t0.factor())
        #if deg_t0>0:
        #    print('roots:', t0.roots())

    return r0, s0, t0


def gen_error(nerrs, n):
	error_vec = vector(GF(2), n)
	for i in range(nerrs):
		while True:
			error_pos_tmp = ZZ.random_element(0, n)
			if not error_vec[error_pos_tmp]==1:
				error_vec[error_pos_tmp]=1
				break
	return vector(error_vec)

def gen_message(k):
	m_coeffs = vector(GF(2), k)
	for i in range(k):
		m_coeffs[i] = ZZ.random_element(2)
	return m_coeffs

F = GF(2)
Fx = PolynomialRing(F, 'x')
x = Fx.gens()[0]
g = x^8+x^7+x^6+x^4+1

m1 = x^4+x+1

n = 15
k = 9 #n-k = d-1
dmin = 5

Fx_qou = Fx.quotient(x^15+1, 'x')
K.<alpha> = F.extension(m1)

d = {}#dictionary of degrees
for i in range(n):
    d[str(alpha^i)] = i
    #print(i, alpha^i)

print('d:', d)

Fz = PolynomialRing(K, 'z')
z = Fz.gens()[0]


G = matrix(F, k, n)
for i in range(1,k+1):
    tmp = Fx_qou(x^i*g)
    G[i-1] = list(Fx_qou(x^i)*g)

H = matrix(K, n-k, n)
for i in range(n-k):
    for j in range(n):
        H[i,j] = alpha^((i+1)*j)

print(H)

m = gen_message(k)
c = m*G
e = gen_error(2,n)
y_ = c+e

#---------------------------------------------------
#m =  (1, 0, 1, 1, 0, 0, 0, 1, 0)
#c =  (1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1)
#e =  (0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0)
#y =  (1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1)
#---------------------------------------------------
#m =  (0, 1, 0, 1, 0, 0, 0, 0, 0)
#c =  (0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0)
#e =  (0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0)
#y =  (0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0)
#---------------------------------------------------
#m =  (1, 0, 0, 1, 0, 0, 0, 0, 1)
#c =  (1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0)
#e =  (0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0)
#y =  (1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0)
#---------------------------------------------------
#m =  (0, 1, 0, 1, 1, 1, 1, 0, 1)
#c =  (0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0)
#e =  (0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0)
#y =  (0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0)
#---------------------------------------------------
#m =  (1, 1, 1, 1, 0, 0, 1, 0, 1)
#c =  (0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1)
#e =  (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0)
#y =  (0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1)
#---------------------------------------------------
#m =  (0, 1, 1, 1, 1, 0, 1, 0, 0)
#c =  (1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1)
#e =  (1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
#y =  (0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1)

#print('m = ', m)
#print('c = ', c)
#print('e = ', e)
#print('y = ', y_)

y_=vector([0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1])


s = vector([sum(y_[i]*alpha^(j*i) for i in range(n)) for j in range(n-k)])
print(s)
#print(H*vector(y_))

s_poly = sum(s[i]*z^i for i in range(n-k))
print('s:', s_poly)

r,s_,t_ = extended_euclid_break(z^(n-k), s_poly)
print(t_*s_poly+s_*z^(n-k))
print('r: ', r)
print('t_:', t_)
#print(s_,t_)
#print(s_.factor())
#print(t_.factor())
t_roots = t_.roots()
print(t_roots)
evec = vector(F, n)
for root,_ in t_roots:
    if root!=0:
        print(root, d[str(root)])
        evec[n-d[str(root)]] = 1
print('e:', evec)
c_cand = vector(F,y_)+evec
c_K = vector(K, c_cand)
print('c:', c_K)
c_ =  vector([1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 0])
print(H*c_) # the first d coordinates must be 0 (the remaining may not be)
