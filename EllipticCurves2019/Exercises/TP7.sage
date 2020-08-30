import os
import sys

directory1 = '/Users/elena/Desktop/Teaching/EllipticCurves2019/Exercises/Params1/'

def readfile(fn):
  fd = open(fn,'r')
  r = fd.read()
  fd.close()
  return r


p = Integer(readfile(directory1+'p.txt'))
print 'p: ', p
assert(p== pow(2, 511) + 111)

a =Integer(readfile(directory1+'a.txt'))
print 'a:', a
assert(a== pow(2, 511) + 108)

b =Integer(readfile(directory1+'b.txt'))
print 'b:', b

q =Integer(readfile(directory1+'q.txt'))
print 'q:', q

x = 2

y =Integer(readfile(directory1+'y.txt'))
print 'y:', y

print p.is_prime()
print q.is_prime()

assert(p!=q)

def is_on_curve(p, Px, Py, a, b):
  if ((Py*Py) % p == (pow(Px,3) + a*Px + b) % p):
    return True
  return False

print is_on_curve(p, x, y, a, b)

dlog_lvl = log(float(sqrt(gp(pi) / 4.0)* sqrt(q)), 2).n()
print 'dlog_lvl:', dlog_lvl

t = Mod(p,q).multiplicative_order()
print 't:', t


