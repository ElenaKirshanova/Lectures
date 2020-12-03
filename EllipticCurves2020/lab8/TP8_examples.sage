p = 7
for i in range(100):
    a = randint(1, p)
    b = randint(1, p)
    try: 
        E = EllipticCurve(GF(p), [a, b])
    except ArithmeticError:
        continue

    print(E)

    N = E.order()
    F = N.factor()
    for j in range(len(F)):
        l = F[j][0] 
        if l > 10000:
            continue

        while True:
          P = E.random_element()
          Q = int(N/l)*P

          if not E.is_on_curve(Q[0], Q[1]):
            continue

          if Q != E(0):
            break
        print("l =", l, "N =", N)
        #print("[{}, {}], Mod({}, {}), Mod({}, {})".format(Q[0], Q[1], a, p, b, p))
        print("test_Velu_curve([{}, {}], GF({})({}), GF({})({}))".format(Q[0], Q[1], p, a, p, b))
        #print([[Q[0],Q[1]], p, a, b])

        R = E.random_element()
        phi = E.isogeny(Q)
        #E2 = phi.codomain()
        phi(R)
        print("test_Velu_point([{}, {}], GF({})({}), GF({})({}), [{}, {}])".format(Q[0], Q[1], p, a, p, b, R[0], R[1]))

    p = random_prime(2^(i+1)*p)