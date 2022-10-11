import pytest
from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim

from valrdy.valrdyRTL import valrdyVRTL

def test_simple(cmdline_opts):
    run_test_vector_sim(valrdyVRTL(),[
        ('snd_val snd_msg rcv_rdy snd_rdy rcv_msg* rcv_val'),
        [ 0x01,   0xFF,   0x01,   0x01,   '?',    0x01],
        [ 0x00,   0xFF,   0x00,   0x00,   0xFF,   0x00 ]],cmdline_opts)
