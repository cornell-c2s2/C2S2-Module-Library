#=========================================================================
# Choose PyMTL or Verilog version
#=========================================================================
# Set this variable to 'pymtl' if you are using PyMTL for your RTL design
# (i.e., your design is in IntMultFixedLatPRTL) or set this variable to
# 'verilog' if you are using Verilog for your RTL design (i.e., your
# design is in IntMulFixedLatVRTL).

rtl_language = 'verilog'

#-------------------------------------------------------------------------
# Do not edit below this line
#-------------------------------------------------------------------------

# This is the PyMTL wrapper for the corresponding Verilog RTL model.

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.passes.backends.verilog import *

class HarnessVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s, n=32, d=16 ):

    # If translated into Verilog, we use the explicit name

    # s.set_metadata( VerilogTranslationPass.explicit_module_name, 'HarnessVRTL' )

    # Interface

    s.recv = stream.ifcs.RecvIfcRTL( mk_bits(2*n) )
    s.send = stream.ifcs.SendIfcRTL( mk_bits(n) )