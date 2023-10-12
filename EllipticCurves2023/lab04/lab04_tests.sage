# Проверять работу своей функции orderBSGS() с помощью встроенной функции order():

def test_orderBSGS(i):
  q = Primes().next(2^(16*i) + 1)
  a = ZZ.random_element(1,q-1)
  b = ZZ.random_element(1,q-1)
  F = GF(q)
  E = EllipticCurve(F, [a, b])
  return orderBSGS(a,b,q) == E.order()

def orderBSGS(a, b, q):
  """
  TESTS::
    sage: [test_orderBSGS(i) for i in range(1,5)]
    [True, True, True, True]
  """
  # **** Place your code here *****