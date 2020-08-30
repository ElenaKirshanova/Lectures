
d = 47
print 'is d prime:', d.is_prime()
print 'd mod 4:', d % 4


min_poly = x^2 + d
Qd.<alpha> = NumberField([min_poly])
print Qd
Cl = Qd.class_group()
print 'class group:', Cl
print 'class group gens:', Cl.gens()

L.<b> = Qd.absolute_field()
disc =  L.discriminant()
print 'disc', disc, disc.factor()
print 'conductor', Qd.conductor()

n = Qd.degree()
r2 = 1
Mink_bound = ( factorial(n) / n^n ) * pow( 4.0/gp(pi), r2) * sqrt(abs(disc))
print 'Mink_bound', Mink_bound

#p_prime = 5
#P.<x> = PolynomialRing(GF(p_prime))
#print P(min_poly)


#p_prime = 2
#while p_prime < 100:
#  if p_prime % 4 == 3 :
#    Qd.<alpha> = NumberField([x^2 + p_prime])
#    Cl = Qd.class_group()
#    print 'class group:', Cl
#    print 'class group gens:', Cl.gens()
#  p_prime = Primes().next(p_prime)
