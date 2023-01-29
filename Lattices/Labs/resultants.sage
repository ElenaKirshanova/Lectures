P.<r,m,c1,c2> = PolynomialRing(QQ)

p1 = P(m^3 - c1)
p2 = P((m+r)^3 - c2)
res = p1.resultant(p2,m)
print(res)
print(p2.resultant(p1,m))

