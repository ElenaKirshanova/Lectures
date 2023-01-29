load("test.sage")
B = matrix(GF(2), A.nrows(), A.ncols())
As_ = [0]*(A.ncols()+1)
Bs_ = [0]*(A.ncols()+1)

current_rank = 0
for i in range(A.nrows()-1):
    for j in range(A.ncols()):
        B[current_rank,j]=GF(2)(A[i,j])
    if B.rank()>current_rank:
        As_[current_rank] = a[i]
        Bs_[current_rank] = b[i]
        current_rank+=1
        print(current_rank)
    if B.rank()==A.ncols(): break

assert(B.rank()==A.ncols())


d = len(P)
print('d:', d)
j=i+1
while True and j<A.nrows():
    c = B.solve_left(A[j])
    if not c == vector(GF(2),A.nrows()):
        As_[A.ncols()] = a[j]
        Bs_[A.ncols()] = b[j]

        x = 1
        y = 1
        for k in range(d):
            sx = (As_[d][k]+Bs_[d][k])/2
            sy = As_[d][k]
            for i in range(d):
                #print(i, As_[i], Bs_[i])
                sx+=(As_[i][k]+Bs_[i][k])*int(c[i])/2
                sy+=As_[i][k]*int(c[i])
            x*=P[k]^sx
            y*=P[k]^sy
        print(j, gcd(N, x+y), gcd(N, x-y))

    j+=1
print(factor(N))

#print(As_)
#print(Bs_)
#print(len(As_))
