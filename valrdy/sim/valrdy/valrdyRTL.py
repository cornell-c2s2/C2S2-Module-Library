from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.passes.backends.verilog import *

class valrdyVRTL(VerilogPlaceholder, Component):
    def construct(s, bitwidth = 32):
        s.set_metadata(VerilogTranslationPass.explicit_module_name, 'valrdy')
        s.snd_val = InPort(1)
        s.snd_msg = InPort(bitwidth)
        s.rcv_rdy = InPort(1)
        s.snd_rdy = OutPort(1)
        s.rcv_msg = OutPort(bitwidth)
        s.rcv_val = OutPort(1)

valrdy = valrdyVRTL
