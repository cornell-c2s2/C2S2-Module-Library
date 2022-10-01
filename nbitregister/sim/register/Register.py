# This is the PyMTL wrapper for the corresponding Verilog RTL model RegIncVRTL.

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.passes.backends.verilog import *


class RegisterV( VerilogPlaceholder, Component ):

	# Constructor

	def construct( s, N ):
		# If translated into Verilog, we use the explicit name

		s.set_metadata( VerilogTranslationPass.explicit_module_name, 'Register' )

		# Interface
		s.w = InPort(1)
		s.d = InPort(N)
		s.q = OutPort(N)

class RegisterV_Reset( VerilogPlaceholder, Component ):
	# Constructor

	def construct ( s, N ):
    
		s.set_metadata( VerilogTranslationPass.explicit_module_name, 'Register_Reset' )

		# Interface
		s.w = InPort(1)
		s.d = InPort(N)
		s.q = OutPort(N)

Register = RegisterV
Register_Reset = RegisterV_Reset
