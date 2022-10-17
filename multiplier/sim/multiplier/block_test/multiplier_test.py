import pytest
from pymtl3 import *
from pymtl3.passes.PassGroups import DefaultPassGroup
from pymtl3.passes.backends.verilog import *
from fxpmath import Fxp
from multiplier import fpmulit

def eval_until_ready(model, a, b):
	model.a @= int(a.bin(), 2)
	model.b @= int(b.bin(), 2)
	model.snd_val @= 1
	model.sim_eval_combinational()

	for _ in range(100):
		if model.snd_rdy == 1:
			break;
		model.sim_tick()
	
	return model.c


def test_with_dump():
	n, d, s = 32, 16, 1 # 32 bit signed fixed point numbers with 16 bits allocated for decimal

	model = fpmulit(n, d, s)
	model.elaborate()
	model.apply(VerilogPlaceholderPass())
	model = VerilogTranslationImportPass()( model )
	model.apply(DefaultPassGroup(vcdwave='test_dump'))
	model.sim_reset()

	a = Fxp(3.7, s, n, d, overflow='wrap')
	a.config.op_sizing = 'same'
	b = Fxp(4.2, s, n, d, overflow='wrap')
	c = a * b; # approximately 15.54

	out = Fxp(0, s, n, d, overflow='wrap')
	out.set_val(int(eval_until_ready(model, a, b)), raw=True)

	assert c == out
