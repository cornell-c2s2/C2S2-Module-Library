from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.passes.backends.verilog import *

class shiftregSISOVRTL(VerilogPlaceholder, Component):
    def construct(s, bitwidth = 4):
        s.set_metadata(VerilogTranslationPass.explicit_module_name, 'shiftregSISO')
        s.LOAD_EN = InPort(1)
        s.SHIFT_EN = InPort(1)
        s.IN = InPort(1)
        s.LOAD_DATA = InPort(bitwidth)
        s.OUT = OutPort(1)
   #    s.CLK = InPort(1)
   #    s.RESET = InPort(1)

shiftregSISO = shiftregSISOVRTL
