from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.passes.backends.verilog import *

class fpmulit(VerilogPlaceholder, Component):
	def construct(s, n=32, d=16, sign=1):
		s.snd_val = InPort(1)
		s.snd_rdy = OutPort(1)
		s.a = InPort(n)
		s.b = InPort(n)
		s.rcv_val = OutPort(1)
		s.rcv_rdy = InPort(1)
		s.c = OutPort(n)
