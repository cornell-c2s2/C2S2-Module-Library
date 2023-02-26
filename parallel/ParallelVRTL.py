# This is the PyMTL wrapper for the corresponding Verilog RTL model RegIncVRTL.

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.passes.backends.verilog import *

#model.apply( DefaultPassGroup(vcdwave='parallel-sim') )

class ParallelVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s, dec_in, regs, N):
    # If translated into Verilog, we use the explicit name
    # random comment DELETE LATER asdkjfdsk

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'Parallel' )

    # Interface
    s.dta         = InPort(N)
    s.rec_val     = InPort(1)
    s.send_rdy    = InPort(1)
    
    s.EN          = OutPort(1)
    s.OUTPUTA     = OutPort(regs)
    s.OUTPUTB     = OutPort(regs)
    s.dec_select  = OutPort(dec_in)
    s.dec_out     = OutPort(regs)
    s.send_val    = OutPort(1)
    s.rec_rdy     = OutPort(1)

Parallel = ParallelVRTL

class ControlVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s, dib, dobreg):
    # If translated into Verilog, we use the explicit name

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'Control' )

    # Interface
    s.vin  = InPort(1)
    s.rin  = InPort(1)
    
    s.vout = OutPort(1)
    s.rout = OutPort(1)
    s.EN   = OutPort(1)
    s.dsel = OutPort(dib)

Control = ControlVRTL