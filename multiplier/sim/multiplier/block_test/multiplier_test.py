#=========================================================================
# IntMulFixedLatRTL_test
#=========================================================================

import pytest
import random

random.seed(0xdeadbeef)

from pymtl3 import *
from pymtl3.passes.PassGroups import DefaultPassGroup
from pymtl3.passes.backends.verilog import *
from pymtl3.stdlib.test_utils import run_sim
from pymtl3.stdlib import stream
from fixedpt import Fixed
from multiplier import HarnessVRTL
from random import randint


# Merge a and b into a larger number
def mk_msg(n, a, b):
	return (a << n) | b;

# Test harness for streaming data

class Harness( Component ):
	def construct (s, mult, n):

		s.mult = mult

		s.src = stream.SourceRTL(mk_bits(2*n))

		s.sink = stream.SinkRTL(mk_bits(n))

		s.src.send //= s.mult.recv
		s.mult.send //= s.sink.recv



	def done(s):
		return s.src.done() and s.sink.done()

# return a random fxp value
def rand_fixed(n, d):
	return Fixed(randint(0, (1<<n)-1), 1, n, d, raw=True)

# Initialize a simulatable model
def create_model(n, d, dump_vcd=None):
	model = HarnessVRTL(n, d)
	# model.elaborate()
	# model.apply(VerilogPlaceholderPass())
	# model = VerilogTranslationImportPass()( model )
	# if dump_vcd is not None:
	# 	model.apply(DefaultPassGroup(vcdwave=dump_vcd))
	# else:
	# 	model.apply(DefaultPassGroup())
	# model.sim_reset()

	return Harness(model, n)

@pytest.mark.parametrize('n, d, a, b', [
	(3, 0, 3, 3), # overflow check
	(2, 1, 0.5, -0.5),
	(6, 3, -4, -0.125), #100.000 * 111.111 = 000.100
	(6, 3, 3.875, -0.125), #-0.375
])
def test_edge(n, d, a, b):
	print(a, b);
	a = Fixed(a, 1, n, d)
	b = Fixed(b, 1, n, d)

	print("%s * %s = %s", a.bin(dot=1), b.bin(dot=1), (a*b).resize(None, n, d).bin(dot=1));
	print("%s * %s = %s", a.get(), b.get(), (a*b).resize(None, n, d).get());

	model = create_model(n, d, dump_vcd='edge')

	model.set_param("top.src.construct",
		msgs=[mk_msg(n, a.get(), b.get())],
		initial_delay=0,
		interval_delay=0
	)

	model.set_param("top.sink.construct", 
		msgs=[(a * b).resize(None, n, d).get()],
		initial_delay=0,
		interval_delay=0
	)

	run_sim(model)

	# out = Fixed(int(eval_until_ready(model, a, b)), s, n, d, raw=True)

	# c = (a * b).resize(s, n, d)
	# print("%s * %s = %s, got %s" % (a.bin(dot=True), b.bin(dot=True), c.bin(dot=True), out.bin(dot=True)))
	# assert c.bin() == out.bin()
		
@pytest.mark.parametrize('execution_number, sequence_length', [(None, i) for i in [1, 5, 50] for _ in range(20)])
def test_random(execution_number, sequence_length): # test individual and sequential multiplications to assure stream system works
	mmn = (16, 64) # minimum and maximum number of bits to use
	
	n = randint(mmn[0], mmn[1])
	d = randint(0, n-1) # decimal bits

	dat = [{'a':rand_fixed(n, d), 'b':rand_fixed(n, d)} for i in range(sequence_length)]
	solns = [(i['a'] * i['b']).resize(None, n, d) for i in dat]

	model = create_model(n, d, dump_vcd='random_individual')

	t = mk_bitstruct(
		"In",
		{
			'a': mk_bits(n),
			'b': mk_bits(n)
		}
	)

	dat = [mk_msg(n, i['a'].get(), i['b'].get()) for i in dat]

	model.set_param("top.src.construct",
		msgs=dat,
		initial_delay=5,
		interval_delay=5
	)

	model.set_param("top.sink.construct", 
		msgs=[c.get() for c in solns],
		initial_delay=5,
		interval_delay=5
	)

	run_sim(model)