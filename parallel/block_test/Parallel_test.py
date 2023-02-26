#=========================================================================
# Parallel_test
#=========================================================================

import pytest

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim

from parallel.ParallelVRTL  import ControlVRTL
from parallel.ParallelVRTL  import ParallelVRTL

def test_controlsmall( cmdline_opts):
  run_test_vector_sim(ControlVRTL(1, 2),[       #tests function of control block for 1 input two registers
    ( ' vin  rin   vout*  rout*  EN*  dsel*'),  #vin = rec_val
    [   0x0, 0x0,  0x00,  0x1,   0x0, 0x00  ],  #rin = send_rdy
    [   0x1, 0x0,  0x00,  0x1,   0x1, 0x00  ],  #vout = send_val
    [   0x1, 0x0,  0x00,  0x1,   0x1, 0x01  ],  #rout = rec_rdy
    [   0x1, 0x0,  0x01,  0x0,   0x0, 0x02  ], 
  ],cmdline_opts)

def test_controlsbig( cmdline_opts):
  run_test_vector_sim(ControlVRTL(2, 4),[       #tests function of control block for 2 input 4 registers
    ( ' vin  rin   vout*  rout*  EN*  dsel*'),  
    [   0x0, 0x0,  0x00,  0x1,   0x0, 0x00  ],  
    [   0x1, 0x0,  0x00,  0x1,   0x1, 0x00  ],  
    [   0x1, 0x0,  0x00,  0x1,   0x1, 0x01  ],  
    [   0x1, 0x0,  0x00,  0x1,   0x1, 0x02  ],
    [   0x1, 0x0,  0x00,  0x1,   0x1, 0x03  ],
    [   0x1, 0x0,  0x01,  0x0,   0x0, 0x04  ], 
  ],cmdline_opts)

# def test_parallel( cmdline_opts):
#   run_test_vector_sim(ParallelVRTL(1, 2, 32),[
#     ( ' dta          rec_val  send_rdy  rec_rdy*  EN*   dec_select*  dec_out* send_val*  OUTPUTA*     OUTPUTB*  ' ),
#     [   0x00000002,  0x01,    0x00,     0x00,     0x00, 0x00,        0x01,    0x00,      0x00000000,  0x00000000  ],
#     [   0x00000002,  0x01,    0x01,     0x01,     0x01, 0x00,        0x01,    0x00,      0x00000002,  0x00000000  ],
#     [   0x00000003,  0x01,    0x01,     0x01,     0x01, 0x01,        0x02,    0x01,      0x00000002,  0x00000003  ],
#   ],cmdline_opts)



