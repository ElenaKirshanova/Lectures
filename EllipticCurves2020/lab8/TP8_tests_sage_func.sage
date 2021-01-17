def test_Velu_curve(G, a, b):
    E1 = EllipticCurve([a,b])
    a2,b2 = Velu_curve(G, a, b)
    E2 = EllipticCurve([a2, b2])
    if E1.order() != E2.order():
        return "not isogenous"

    if E1.is_isomorphic(E2):
        return "wrong degree"

    F = a.parent().extension(2)
    a = F(a)
    b = F(b)
    E3 = EllipticCurve([a,b])
    a2,b2 = Velu_curve(G, a, b)
    E4 = EllipticCurve([a2, b2])
    if E3.order() != E4.order():
        return "not isogenous over an extension" 
    return True

def Velu_curve(G, a, b):
  """
  TESTS::
  sage: test_Velu_curve([2, 6], GF(7)(5), GF(7)(4))
  True

  sage: test_Velu_curve([3, 8], GF(11)(10), GF(11)(7))
  True

  sage: test_Velu_curve([5, 0], GF(17)(5), GF(17)(3))
  True

  sage: test_Velu_curve([20, 33], GF(37)(24), GF(37)(9))
  True

  sage: test_Velu_curve([8040895309733, 7431502456959], GF(8197264664389)(5418881554929), GF(8197264664389)(6364590786677))
  True

  sage: test_Velu_curve([12485090540353281933, 4065847262544326755], GF(13639518044186602499)(9580437492399244187), GF(13639518044186602499)(806081007850339880))
  True

  """
  # your code here
  E = EllipticCurve([a,b])
  Q = E(G)
  phi = E.isogeny(Q)
  E2 = phi.codomain()
  return [E2.a4(), E2.a6()]

def test_Velu_point(G, a, b, P):
  E1 = EllipticCurve([a,b])
  a2,b2 = Velu_curve(G, a, b)
  E2 = EllipticCurve([a2, b2])
  Q = Velu_point(G, a, b, P)
  if not E2.is_on_curve(Q[0], Q[1]):
    return "point is not on Velu curve"

  P = E1(P)
  if E2(Velu_point(G, a, b, 3*P)) - E2(Velu_point(G, a, b, 2*P)) != E2(Velu_point(G, a, b, P)):
    return "not a homomorphism"
  return True

def Velu_point(G, a, b, P):
  """
  TESTS::
  sage: test_Velu_point([11020, 13219], GF(21319)(19573), GF(21319)(7127), [3490, 15205])
  True

  sage: test_Velu_point([12939, 10990], GF(21319)(19573), GF(21319)(7127), [9466, 8938])
  True

  sage: test_Velu_point([5180949, 25065947], GF(30737689)(29493746), GF(30737689)(785909), [9668505, 9777763])
  True
  
  """
  # your code here
  E = EllipticCurve([a,b])
  Q = E(G)
  phi = E.isogeny(Q)
  R = phi(E(P))
  return [R[0], R[1]]