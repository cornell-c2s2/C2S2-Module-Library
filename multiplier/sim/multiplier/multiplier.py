from pymtl3 import *
from pymtl3.passes.backends.verilog import *
from pymtl3.stdlib.stream.ifcs import IStreamIfc, OStreamIfc

class fpmult(VerilogPlaceholder, Component):
	def construct(s, n=32, d=16):
		s.istream = IStreamIfc( Bits64 )
		s.ostream = OStreamIfc( Bits32 )



