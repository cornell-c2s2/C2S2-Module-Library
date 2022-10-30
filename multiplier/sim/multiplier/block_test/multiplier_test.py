import pytest
from pymtl3 import *
from pymtl3.passes.PassGroups import DefaultPassGroup
from pymtl3.passes.backends.verilog import *
from fixedpt import Fixed
from multiplier import fpmulit
from random import randint

# return a random fxp value
def rand_fixed(s, n, d):
	return Fixed(randint(0, (1<<n)-1), s, n, d, raw=True)

# Initialize a simulatable model
def create_model(n, d, s, dump_vcd=None):
	model = fpmulit(n, d, s)
	model.elaborate()
	model.apply(VerilogPlaceholderPass())
	model = VerilogTranslationImportPass()( model )
	if dump_vcd is not None:
		model.apply(DefaultPassGroup(vcdwave=dump_vcd))
	else:
		model.apply(DefaultPassGroup())
	model.sim_reset()

	return model

# run the multiplier until output
def eval_until_ready(model, a, b, max_cycles = 1000):
	model.a @= int(a.bin(), 2)
	model.b @= int(b.bin(), 2)
	model.snd_val @= 1
	model.sim_eval_combinational()
	
	while int(model.snd_rdy) == 1:
		model.sim_tick()

	for _ in range(max_cycles): # Abort after too many cycles have passed
		if int(model.rcv_val) == 1:
			return model.c
		model.sim_tick()
	
	return None

def test_with_dump():
	n, d, s = 32, 16, 1 # 32 bit signed fixed point numbers with 16 bits allocated for decimal
	
	model = create_model(n, d, s, dump_vcd='test_with_dump');

	a = Fixed(3.7, s, n, d)
	b = Fixed(4.2, s, n, d)
	c = (a * b).resize(s, n, d);

	out = Fixed(int(eval_until_ready(model, a, b)), s, n, d, raw=True)

	print(c.bin(dot=True), out.bin(dot=True))

	assert c.bin() == out.bin()

def test_edge():
	cases = [
		(3, 0, 1, 3, 3), # overflow check
		(2, 0, 0, 2, 2), # unsigned overflow check
		(1, 1, 0, 1, 1), # 1 bit numbers (0.5 * 0.5 = 0)
		(3, 3, 0, 0.5, 0.5), # unsigned number with no non-decimal bits
		(2, 1, 0, 0.5, 1.5),
		(2, 1, 1, 0.5, -0.5),
		(6, 3, 1, -4, -0.125), #100.000 * 111.111 = 000.100
		(6, 3, 1, 3.875, -0.125), #-0.375
	]

	for (n, d, s, a, b) in cases:
		a = Fixed(a, s, n, d)
		b = Fixed(b, s, n, d)

		model = create_model(n, d, s, dump_vcd='edge')

		out = Fixed(int(eval_until_ready(model, a, b)), s, n, d, raw=True)

		c = (a * b).resize(s, n, d)
		print("%s * %s = %s, got %s" % (a.bin(dot=True), b.bin(dot=True), c.bin(dot=True), out.bin(dot=True)))
		assert c.bin() == out.bin()

@pytest.mark.parametrize('execution_number', range(100)) # run this test 100 times
def test_random_individual(execution_number):
	mmn = (1, 64) # minimum and maximum number of bits to use
	
	n = randint(mmn[0], mmn[1])
	s = randint(0, min(n-1,1)) # signed or not signed
	d = randint(0, n-s) # decimal bits

	a = rand_fixed(s, n, d)
	b = rand_fixed(s, n, d)

	model = create_model(n, d, s, dump_vcd='random_individual');

	out = Fixed(int(eval_until_ready(model, a, b)), s, n, d, raw=True)

	c = (a * b).resize(s, n, d)
	print("%s * %s = %s, got %s" % (a.bin(dot=True), b.bin(dot=True), c.bin(dot=True), out.bin(dot=True)))
	print("%s * %s = %s, got %s" % (a, b, c, out))
	assert c.bin() == out.bin()
		



