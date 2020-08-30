
d = 79
min_poly = x^2 - 79
Q79.<alpha> = NumberField([min_poly])
print Q79

#------- this is to compute the discriminant correctly------
L.<b> = Q79.absolute_field()
disc =  L.discriminant()
print 'disc', disc, disc.factor()



n = 2
Mink_bound = ( factorial(n) / n^n ) * sqrt(disc)
print 'Minkbound', Mink_bound.n()

m = Q79.conductor()
print 'conductor', m
print 'euler_phi(m):', euler_phi(m)


Cl = Q79.class_group()
print 'class group:', Cl
print 'class group gens:', Cl.gens()

#Q7.<alpha> = NumberField([x^2+7])
#print Q7.class_group()


