# Проверять работу своей функции ec_order() с помощью встроенной функции order():

def test_ec_order(i):
  q = Primes().next(2^(20*i) + 1)
  a = ZZ.random_element(1,q-1)
  b = ZZ.random_element(1,q-1)
  F = GF(q)
  E = EllipticCurve(F, [a, b])
  return ec_order(a,b,q) == E.order()

def ec_order(a, b, q):
  """
  TESTS::
    sage: [test_ec_order(i) for i in range(1,5)]
    [True, True, True, True]
  """
  # **** Place your code here *****
