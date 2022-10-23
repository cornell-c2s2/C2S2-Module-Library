#=========================================================================
# Decoder Test
#=========================================================================

import pytest

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim

from decoder.DecoderVRTL import DecoderVRTL

def test_enable( cmdline_opts): #check if enable is working properly
  run_test_vector_sim(DecoderVRTL( 3, 8 ),[
    ('enable    x     y*'),
    [0, 0x00, 0],
    [0, 0x01, 0],
  ],cmdline_opts)

def test_3to8( cmdline_opts):
  run_test_vector_sim(DecoderVRTL( 3, 8 ),[
    ('enable    x     y*'),
    [1, 0x00, 0x01],
    [1, 0x01, 0x02],
    [1, 0x02, 0x04],
    [1, 0x03, 0x08],
    [1, 0x04, 0x10],
    [1, 0x05, 0x20],
    [1, 0x06, 0x40],
    [1, 0x07, 0x80],
  ],cmdline_opts)

def test_2to4( cmdline_opts):
  run_test_vector_sim(DecoderVRTL( 2, 4),[
    ('enable    x     y*'),
    [1, 0x00, 0x01],
    [1, 0x01, 0x02],
    [1, 0x02, 0x04],
    [1, 0x03, 0x08],
  ],cmdline_opts)


