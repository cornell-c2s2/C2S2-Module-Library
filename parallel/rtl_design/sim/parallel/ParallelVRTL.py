# This is the PyMTL wrapper for the corresponding Verilog RTL model RegIncVRTL.

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.passes.backends.verilog import *


class ParallelVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s, dib, dobreg, N):
    # If translated into Verilog, we use the explicit name
    # random comment DELETE LATER asdkjfdsk

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'Parallel' )

    # Interface
    s.dta = InPort(N)
    s.VIN = InPort(1)
    s.RIN = InPort(1)
    s.OUTPUTA = OutPort(dobreg)
    s.OUTPUTB = OutPort(dobreg)
    s.DSEL = OutPort(dib)
    s.DOUT = OutPort(dobreg)
    s.EN = OutPort(1)
    s.VOUT = OutPort(1)
    s.ROUT = OutPort(1)

Parallel = ParallelVRTL
