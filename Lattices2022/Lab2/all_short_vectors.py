#!/usr/bin/env python
####
#
#   Copyright (C) 2018-2021 Team G6K
#
#   This file is part of G6K. G6K is free software:
#   you can redistribute it and/or modify it under the terms of the
#   GNU General Public License as published by the Free Software Foundation,
#   either version 2 of the License, or (at your option) any later version.
#
#   G6K is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with G6K. If not, see <http://www.gnu.org/licenses/>.
#
####



# SCRIPT: Get (almost) all short vectors of squared length < 1.7 * gh^2

from math import sqrt, gcd
from fpylll import IntegerMatrix
from fpylll.util import gaussian_heuristic
from scipy.special import betaincinv
from sympy import randprime, nextprime, ln, Matrix
#import sympy
from random import shuffle
import sys
from math import log

try:
	from g6k import Siever
except ImportError:
	raise ImportError("g6k not installed. Please run './setup.py install' from ../")

#from simple_pump import pump

def first_primes(n):
	p = 1
	P = []
	while len(P) < n:
		p = nextprime(p)
		P += [p]
	return P

def is_smooth(x, P):
	y = x
	for p in P:
		while y%p==0:
			y /= p
	return abs(y) == 1

def build_lattice(N, n, P, prec=100): #400):

	f = list(range(1, n+1))
	shuffle(f)


	# Scale up and round
	def sr(x):
		return round(x * 2**prec)

	diag = [sr(N*f[i]) for i in range(n)] + [sr(N*ln(N))]

	B = IntegerMatrix(n+1, n+1)
	for i in range(n):
		B[i,i] = diag[i]
		B[i,n] = int(sr(N*ln(P[i])))
	B[n,n] = int(sr(N*ln(N)))
	return B,f

def get_uv_value(e,n,P):
	u = 1
	k = 1
	a = [0]*n
	b = [0]*n
	for i in range(n):
		if e[i] > 0:
			u *= P[i]**e[i]
			a[i] = e[i]
		if e[i] < 0:
			k *= P[i]**(-e[i])
			b[i] = -e[i]
	return u,k,a,b

#n = 30
#A = IntegerMatrix.random(n, "qary", k=n/2, bits=8)
bits  = 20
n = 27
p = randprime(2**(bits/2-1), 2**(bits/2))
q = randprime(2**(bits/2-1), 2**(bits/2))
N = p*q
print('N = ', N, log(N,2))
print(1048583*1049599, log(1048583*1049599, 2))
P = first_primes(n)
print(P)
radius = 1.9

#sys.stdout=open("test.sage","w")
print('A = matrix([')

as_ =[]
bs_ =[]

Ntrials = 26
for j in range(Ntrials):
	#print('running ', j, 'th trials')
	A,f = build_lattice(N,n,P)
	#print(A)
#	"""
	g6k = Siever(A)
	d = g6k.full_n
	g6k.lll(0, d)
	#print('lll is finished')
	g6k.initialize_local(0, d/2, d)
	#print('initialize_local is finished')
	while g6k.l > 0:
		# Extend the lift context to the left
		g6k.extend_left(1)
		# Sieve
		g6k()
	with g6k.temp_params(saturation_ratio=.95, saturation_radius=radius,
						 db_size_base=sqrt(radius), db_size_factor=5):
		g6k() #run Gauss sieve
	gh = gaussian_heuristic([g6k.M.get_r(i, i) for i in range(n)])

	db = list(g6k.itervalues())
	Mrows = [0]*d
	for x in db:
		#print(x)
		vec = A.multiply_left(x)
		l = sum(v_**2 for v_ in vec)
		if l < radius * gh:
			vec_ = [int(vec[i]/round(N*f[i]*2**100)) for i in range(d-1)]
			u,k,a,b = get_uv_value(vec_,n,P)

			#print(u - k*N)
			if is_smooth(u - k*N, P):
				print('smooth is found')
				strtmp=''
				as_.append(a)
				bs_.append(b)
				strtmp ='['
				for ell in range(len(a)):
					strtmp+=str(a[ell]+b[ell])+', '
			#print([int(vec[i]/round(N*f[i]*2**400)) for i in range(d-1)])
				print(strtmp+'], ')
		#u,k,a,b = get_uv_value(x_,n,P)
		#if is_smooth(u - k*N, P):
		#	Mrows[count] = [0]*len(a)
		#	for i in range(len(a)):
		#		Mrows[count][i] = a[i]+b[i]
		#	count+=1
		#if count==d:
		#	break

print('])'+'\n')
print('a = [')
for i in range(len(as_)):print(str(as_[i])+',')
print(']'+'\n')
print('b = [')
for i in range(len(bs_)):print(str(bs_[i])+',')
print(']'+'\n')
print('P = [')
for i in range(len(P)):print(str(P[i])+',')
print(']'+'\n')
print('N = ', N)


sys.stdout.close()
#"""
#print(g6k.M.B)

# Run a progressive sieve, to get an initial database saturating the 4/3 *gh^2 ball.
# This makes the final computation saturating a larger ball faster than directly
# running such a large sieve.
#
# G6K will use a database of size db_size_base * db_size_base^dim with default values
#               db_size_base = sqrt(4./3) and db_size_factor = 3.2
#
# The sieve stops when a
#               0.5 * saturation_ratio * saturation_radius^(dim/2)
#
# distinct vectors (modulo negation) of length less than saturation_radius have
# been found




# Increase db_size, saturation radius and saturation ratio to find almost all
# the desired vectors.
# We need to increase db_size to at least
#               0.5 * saturation_ratio * saturation_radius^(dim/2)
#
# for this to be possible, but a significant margin is recommended




# Convert all db vectors from basis A to cannonical basis and print them
# out if they are indeed shorter than 1.7 * gh^2




#print("found %d vectors of squared length than 1.7*gh. (expected %f)"%(found, .5 * 1.7**(n/2.)))
