
P = Primes()
q = P.next(2**5)
print('q:', q)

n = 12
m = ceil(n*log(q,2)+50)
print('q:', q, 'n:', n, 'm:', m)
F = GF(q)

A = random_matrix(F, n, m)
assert(A.rank()==n)


def hash(x):
    assert(len(x)==m)
    return A*x

x = vector(F,[ZZ.random_element(0,2) for _ in range(m)])

print(x)
print(hash(x))


#zero_vec = vector([0 for _ in range(n)])
#zero_mat =zero_matrix(F, n, m-n)

#ker  = A.solve_right(zero_vec)
#print(ker)
ker = A.transpose().kernel().basis_matrix()



kernel = matrix(ZZ, 2*m-n, m)
for i in range(m-n):
    kernel[i] = ker[i]
for i in range(m):
    kernel[m-n+i,i] = q

#print(ker)
#print(kernel)

def is_good(v):
    flag_minus = False
    for j in range(len(v)):
        if abs(v[j])>1:
            return False
    return True


print('running LLL...')
kernel_LLL_with0 = kernel.LLL()
print('LLL is finished')

kernel_LLL = matrix(ZZ, m, m)
for i in range(m):
    kernel_LLL[i] = kernel_LLL_with0[m-n+i]



for i in range(kernel_LLL.nrows()):
    if is_good(kernel_LLL[i]):
        print(kernel_LLL[i])



print('running BKZ...')
kernel_LLL.BKZ(block_size=10)
for i in range(kernel_LLL.nrows()):
    if is_good(kernel_LLL[i]):
        print(kernel_LLL[i])
