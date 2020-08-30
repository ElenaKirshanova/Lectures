

#Q_5_13.<alpha> = NumberField([x^4 - 36*x^2 + 64])
#print Q_5_13.class_group()




#--------- search for (a,b) s.t. Q(sqrt(a), sqrt(b)) has h > 1 ---------
Ntrials = 0 #20
a = 2
for i in xrange(Ntrials):
  a = Primes().next(a)
  b = a
  for i in xrange(Ntrials):
    b = Primes().next(b)
    min_poly = x^4 + (2*(a-b)-4*a)*x^2 + (a-b)^2
    Numfield.<alpha> = NumberField([min_poly])
    print a, b, Numfield.class_group(), a % 4, b % 4

#  found example with h = 2
a = 79
b = 83
min_poly = x^4 + (2*(a-b)-4*a)*x^2 + (a-b)^2
Q_a_b.<alpha> = NumberField([min_poly])
Ok = Q_a_b.maximal_order()
Cl = Q_a_b.class_group()
print Ok.basis(), Cl, Cl.gens()

#R = PolynomialRing(Q_a_b, 'x')
#poly2 = R(min_poly).factor()
#remaining_poly = poly2[1][0]*poly2[2][0]*poly2[3][0]
#print remaining_poly


# compute Minkowski bound for the number field
r2 = 0
L.<b> = Q_a_b.absolute_field()
disc =  L.discriminant()
discQ = Q_a_b.discriminant()
n = 4
Mink_bound = ( factorial(n) / n^n ) * sqrt(discQ)
print 'discQ:', discQ, discQ.factor()
print 'Mink_bound:', Mink_bound.n()


# factor all prime ideals of norm below Mink_bound
#p_prime = 2
#while p_prime < Mink_bound:
#  F = GF(p_prime)
#  Fx = PolynomialRing(F, 'x')
#  print Q_a_b.factor(p_prime), Fx(min_poly).factor()
#  p_prime = Primes().next(p_prime)


Ok = Q_a_b.maximal_order()
print Ok.basis()
print Q_a_b.integral_basis()


Q2.<a,b> = NumberField([x^2 - 79, x^2 - 83])
print Q2
print Q2.integral_basis()

print 'Q_a_b base field:', Q_a_b.base_field()
print 'Q2 base field:', Q2.base_field()






print Q_a_b.factor(2), Q2.factor(2)
print Q_a_b.factor(3), Q2.factor(3)
#Cl = Q25.class_group()
#print Cl.gen()

#K.<a> = NumberField(x^2 - 229)
#print K.class_group()

#p_prime = 2
#print 'prime: ', p_prime, ': ', Q25.factor(p_prime)
#for i in xrange(10):
#  p_prime = Primes().next(p_prime)
#  print 'prime: ', p_prime, ': ', Q25.factor(p_prime)


