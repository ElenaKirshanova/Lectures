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
