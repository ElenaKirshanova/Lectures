from fpylll import *
from fpylll.algorithms.bkz2 import BKZReduction as BKZ2
FPLLL.set_precision( 100 )

def str_to_ternary(s, max_len=128): #кодированиие буквенного сообщения
    l = []
    for c in s:
        n = ord(c)%3**5
        for i in range(5):
            l.append( n%3-1 )
            n = n//3
    assert len(l) < max_len, "Too long message!"
    if len(l)<max_len:
        l += [ randrange(-1,2) for i in range(max_len-len(l)) ]
    return l

def ternary_to_str( l ):  #декодированиие буквенного сообщения
    s = []
    for i in range(len(l)//5):
        n=0
        for j in range(5):
            n+=(l[5*i+j]+1)*3^j
        s.append(chr(n))
    #print(s)
    return "".join( [ ss for ss in s ] )

def convolution(f,g):
    return (f * g).mod(modulo)

def balancedmod(f,q):
    g = list(((f[i] + q//2) % q) - q//2 for i in list(range(N)))
    return ZZ[x](g)

def gen_invertable_f(x,d,N):  #генерация обратимого f
    Rq=Integers(q)[x].quotient_ring(modulo)
    baseq=Rq.base_ring()

    #generated poly in T(d+1,d)
    fq=Rq(0)
    stop_iter=d^2
    nump, numm = 0, 0 #КОЛИЧЕСТВО +1 И -1 В КОЭФФ
    i=0
    while i<=d:
        #print('debug +',i)
        coord=randrange(N)
        #если коэффициент свободен, то ставим его как 1
        if fq[coord]==baseq(0):
            nump+=1
            fq+=Rq(x^coord)
        else:
            #print('missed!')
            continue
        stop_iter-=1
        i+=1
        if stop_iter==0:
            print('Error!')
            break
    i=0
    while i<d:
        #print('debug -',i)
        coord=randrange(N)
        #если коэффициент свободен, то ставим его как -1
        if fq[coord]==baseq(0):
            numm+=1
            fq-=Rq(x^coord)
        else:
            continue
        i+=1
        stop_iter-=1
        if stop_iter==0:
            print('Error!')
            break
    print('+:', nump, '-:', numm)
    return balancedmod(fq,q)

def gen_g(x,d,N):
    Rq=Integers(q)[x].quotient_ring(modulo)
    baseq=Rq.base_ring()

    #generated poly in T(d+1,d)
    fq=Rq(0)
    stop_iter=d^2
    nump, numm = 0, 0 #КОЛИЧЕСТВО +1 И -1 В КОЭФФ
    i=0
    while i<d:
        #print('debug +',i)
        coord=randrange(N)
        #если коэффициент свободен, то ставим его как 1
        if fq[coord]==baseq(0):
            nump+=1
            fq+=Rq(x^coord)
        else:
            #print('missed!')
            continue
        stop_iter-=1
        i+=1
        if stop_iter==0:
            print('Error!')
            break
    i=0
    while i<d:
        #print('debug -',i)
        coord=randrange(N)
        #если коэффициент свободен, то ставим его как -1
        if fq[coord]==baseq(0):
            numm+=1
            fq-=Rq(x^coord)
        else:
            continue
        i+=1
        stop_iter-=1
        if stop_iter==0:
            print('Error!')
            break
    print('+:', nump, '-:', numm)
    return balancedmod(fq,q)


def invertmodprime(f,p): #обратить f по модулю p
    Zx.<x> = ZZ[]
    T = Zx.change_ring(Integers(p)).quotient(modulo)
    return Zx(lift(1 / T(f)))

def encrypt( modulo,h,q,msg ):
    print("mod", modulo)
    N=int( modulo.degree(x) )

    num = str_to_ternary(msg, max_len=N)
    msg = ZZ[x](num)
    print("Message:",msg)

    r=gen_g(x,d,N)

    enc=balancedmod(convolution(h,r) + msg,q)
    print("Cyphertext:",enc)
    return enc

def decrypt( modulo, f, q, p, enc ):
    a = balancedmod(convolution(enc,f),q)
    m=balancedmod(convolution(a,fp),p)
    return m
    #print(m)

# - - - attack

def attack(Phi,h,e,q,p=3):
        modulo = Phi
        N = Phi.degree(x)

        ZpZ=Integers(p)
        ZqZ=Integers(q)
        Zxp=ZpZ[x]
        Zxq=ZqZ[x]
        Rp.<t>=Zxp.quotient_ring(modulo)
        Rq.<t>=Zxq.quotient_ring(modulo)

        print(Rp, "is constructed...")
        print(Rq, "is constructed...")
        hq=Rq(h)

        roth=[hq*Rq(x^k) for k in range(N) ]  #constructing the lattice
        rotH=IntegerMatrix(N,N)

        for i in range(N):
            for j in range(N):
                rotH[i,j]= ((Integer(roth[i][j]) + q//2) % q) - q//2

        Lh_full=IntegerMatrix(2*N,2*N)

        for i in range(0,N):
            Lh_full[i,i]=1

        for i in range(0,N):
            for j in range(N,2*N):
                Lh_full[i,j]=rotH[i][j-N]

        for i in range(N,2*N):
            Lh_full[i,i]=q

        print("Lattice constructed")

        #print(Lh_sub.nrows,Lh_sub.ncols)
        print(f"Now well reduce {N}x{N} matrix.")
        import time
        beta=4

        #BKZ
        print('Preperocessing...')
        then=time.perf_counter()
        GSO_Lh_sub = GSO.Mat(IntegerMatrix.from_matrix(Lh_full), float_type='qd')
        GSO_Lh_sub.update_gso()
        print(f"R00 = {GSO_Lh_sub.get_r(0,0)^0.5}")

        print("Applying LLL...")
        lll_red = LLL.Reduction(GSO_Lh_sub, delta=0.97, eta=0.52)
        lll_red()
        dt=time.perf_counter()-then
        print('LLL done in: ',dt)
        print(f"Norm after LLL: {norm(GSO_Lh_sub.B[0])}")

        flags = BKZ.AUTO_ABORT|BKZ.GH_BND|BKZ.VERBOSE|BKZ.MAX_LOOPS
        #print(BKZ.DEFAULT_STRATEGY)
        par = BKZ.Param(block_size=beta, flags=flags, max_loops=14)

        bkz = BKZ2(GSO_Lh_sub)
        print('Preprocessed')

        print("Reducing lattice of dim",N,"with beta=",beta)
        then=time.perf_counter()

        DONE = bkz(par)

        dt=time.perf_counter()-then
        print('Counted in',dt, 'sec')
        print(f"R00 = {GSO_Lh_sub.get_r(0,0)^0.5}")
        B = matrix( matrix( GSO_Lh_sub.B ) )

        for beta in range(11,15,3):
            #reiterate with higher beta in order to reduce better
            #par = BKZ.Param(block_size=beta, strategies=BKZ.DEFAULT_STRATEGY, flags=flags, max_loops=22)
            #beta=10
            par = BKZ.Param(block_size=beta, flags=flags, max_loops=14)


            print("Reducing lattice of dim",N,"with beta=",beta)
            then=time.perf_counter()

            DONE = bkz(par)

            dt=time.perf_counter()-then
            print('Counted in',dt, 'sec')
            print(f"R00 = {GSO_Lh_sub.get_r(0,0)^0.5}")
        B = matrix( matrix( GSO_Lh_sub.B ) )

        print(f"R00 = {GSO_Lh_sub.get_r(0,0)^0.5}")

        v=B[0]

        vect=Rq(0)

        for i in range(0,N):
            vect+=Rq(v[i])*Rq(x^i)
        print(vect)

        y = vect.parent().gen()
        l = []
        for i in range(N):
            for j in [0,1]:
                f_hacked=  vect*y^i*(-1)^j
                f_hacked = ZZ[x]( [(z-q//2)%q + q//2 for z in f_hacked] )
                g_hacked=hq*f_hacked
                #print("f_hacked",[ZZ(z+ceil(q/2))-ceil(q/2) for z in f_hacked])
                print("f_hacked",[z for z in f_hacked])
                print()
                print("g_hacked",[ZZ(z+ceil(q/2))-ceil(q/2) for z in g_hacked])
                print()

                m = decrypt( modulo, f_hacked, q, p, e )
                l.append( ternary_to_str( m.list() ) )
                #
                # u=balancedmod(f_hacked,q)
                # u=balancedmod(u,q)
                # print(u)
                # print(type(e))
                # e = Zxp(e.list())
                # print(type(e))
                # print('- - -')
                #
                # e, u = Zxq(e), Zxq(u)
                #
                # a = balancedmod(convolution(e,u),q)
                # m=balancedmod(convolution(a,invertmodprime(u,p)),p)
                #
                # print(m)
                # print(m.list())
                #
                # print( ternary_to_str( m.list() ) )
                # l.append( ternary_to_str( m.list() ) )
        return f_hacked, g_hacked, l



# modulo= cyclotomic_polynomial(432)
modulo= cyclotomic_polynomial(128)

print("mod", modulo)
N=int( modulo.degree(x) )

p, q, d = 3, next_prime(2700), N//3
print(gcd(p,q),'=',gcd(N,q))
print(q,'>',(6*d+1)*p)
Zx.<x>=ZZ[x]

f= gen_invertable_f(x,d,N)
f=balancedmod(f,q)

g=gen_g(x,d,N)
g=balancedmod(g,q)

print("f=",f)
print("g=",g)

fp=invertmodprime(f,p)
fq=invertmodprime(f,q)

gp=invertmodprime(f,p)
gq=invertmodprime(f,q)

h = balancedmod(p * convolution(fq,g),q)
#h = balancedmod(convolution(fq,g),q)
print(f"h={h}")
print()
print(list(h))

# - - - Шифруем сообщение

num = str_to_ternary("The Bees", max_len=N)
msg = ZZ[x](num)
print("Message:",msg)

r=gen_g(x,d,N)

enc=balancedmod(convolution(h,r) + msg,q)
print("Cyphertext:",enc)

# - - - расшифровываем сообщение

a = balancedmod(convolution(enc,f),q)
m=balancedmod(convolution(a,fp),p)
#print(m)
assert m-msg==0, "Wrong decrypt"

print( ternary_to_str( m.list() ) )

f_hacked, g_hacked, l = attack(modulo,h,enc,q,p=3)
print( f_hacked / f )

i=0
for ll in l:
    print(f"i:{i}, {l}")
    i+=1

print("Succ:", m in l)
