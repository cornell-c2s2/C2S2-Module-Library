#=========================================================================
# IntMulFixedLatRTL_test
#=========================================================================

import pytest
import random

random.seed(0xdeadbeef)

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.test_utils import mk_test_case_table, run_sim
from multiplier.fpmultRTL    import fpmult
from multiplier.IntMulMsgs    import IntMulMsgs

BITS         = 64 #Amount of bits on multiplier
DECIMAL_BITS = 32 #Amount of decimal bits on multiplier

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s, fpmult ):

    # Instantiate models

    s.src  = stream.SourceRTL( IntMulMsgs.req )
    s.sink = stream.SinkRTL( IntMulMsgs.resp )
    s.fpmult = fpmult

    # Connect

    s.src.send  //= s.fpmult.recv
    s.fpmult.send //= s.sink.recv

  def done( s ):
    return s.src.done() and s.sink.done()

  def line_trace( s ):
    return s.src.line_trace() + " > " + s.fpmult.line_trace() + " > " + s.sink.line_trace()

#-------------------------------------------------------------------------
# mk_req_msg
#-------------------------------------------------------------------------

def req( a, b ):
  a = a % 2**32
  b = b % 2**32
  return IntMulMsgs.req( a, b )

def resp( a ):
  a = a % 2**32
  return IntMulMsgs.resp( a )

#----------------------------------------------------------------------
# Test Case: small positive * positive
#----------------------------------------------------------------------

small_pos_pos_msgs = [
  req(  2 << DECIMAL_BITS,  3 << DECIMAL_BITS ), resp(   6 << DECIMAL_BITS ),
  req(  4 << DECIMAL_BITS,  5 << DECIMAL_BITS ), resp(  20 << DECIMAL_BITS ),
  req(  3 << DECIMAL_BITS,  4 << DECIMAL_BITS ), resp(  12 << DECIMAL_BITS ),
  req( 10 << DECIMAL_BITS, 13 << DECIMAL_BITS ), resp( 130 << DECIMAL_BITS ),
  req(  8 << DECIMAL_BITS,  7 << DECIMAL_BITS ), resp(  56 << DECIMAL_BITS ),
]

#----------------------------------------------------------------------
# Test Case: small negative * positive
#----------------------------------------------------------------------

small_neg_pos_msgs = [
  req(  -2 << DECIMAL_BITS,  3 << DECIMAL_BITS ), resp(   -6 << DECIMAL_BITS ),
  req(  -4 << DECIMAL_BITS,  5 << DECIMAL_BITS ), resp(  -20 << DECIMAL_BITS ),
  req(  -3 << DECIMAL_BITS,  4 << DECIMAL_BITS ), resp(  -12 << DECIMAL_BITS ),
  req( -10 << DECIMAL_BITS, 13 << DECIMAL_BITS ), resp( -130 << DECIMAL_BITS ),
  req(  -8 << DECIMAL_BITS,  7 << DECIMAL_BITS ), resp(  -56 << DECIMAL_BITS ),
]

#----------------------------------------------------------------------
# Test Case: small positive * negative
#----------------------------------------------------------------------

small_pos_neg_msgs = [
  req(  2 << DECIMAL_BITS,  -3 << DECIMAL_BITS ), resp(   -6 << DECIMAL_BITS ),
  req(  4 << DECIMAL_BITS,  -5 << DECIMAL_BITS ), resp(  -20 << DECIMAL_BITS ),
  req(  3 << DECIMAL_BITS,  -4 << DECIMAL_BITS ), resp(  -12 << DECIMAL_BITS ),
  req( 10 << DECIMAL_BITS, -13 << DECIMAL_BITS ), resp( -130 << DECIMAL_BITS ),
  req(  8 << DECIMAL_BITS,  -7 << DECIMAL_BITS ), resp(  -56 << DECIMAL_BITS ),
]

#----------------------------------------------------------------------
# Test Case: small negative * negative
#----------------------------------------------------------------------

small_neg_neg_msgs = [
  req(  -2 << DECIMAL_BITS,  -3 << DECIMAL_BITS ), resp(   6 << DECIMAL_BITS ),
  req(  -4 << DECIMAL_BITS,  -5 << DECIMAL_BITS ), resp(  20 << DECIMAL_BITS ),
  req(  -3 << DECIMAL_BITS,  -4 << DECIMAL_BITS ), resp(  12 << DECIMAL_BITS ),
  req( -10 << DECIMAL_BITS, -13 << DECIMAL_BITS ), resp( 130 << DECIMAL_BITS ),
  req(  -8 << DECIMAL_BITS,  -7 << DECIMAL_BITS ), resp(  56 << DECIMAL_BITS ),
]

#----------------------------------------------------------------------
# Test Case: large positive * positive
#----------------------------------------------------------------------

large_pos_pos_msgs = [
  req( 0x0bcd0000 << DECIMAL_BITS, 0x0000abcd << DECIMAL_BITS ), resp( 0x62290000 << DECIMAL_BITS ),
  req( 0x0fff0000 << DECIMAL_BITS, 0x0000ffff << DECIMAL_BITS ), resp( 0xf0010000 << DECIMAL_BITS ),
  req( 0x0fff0000 << DECIMAL_BITS, 0x0fff0000 << DECIMAL_BITS ), resp( 0x00000000 << DECIMAL_BITS ),
  req( 0x04e5f14d << DECIMAL_BITS, 0x7839d4fc << DECIMAL_BITS ), resp( 0x10524bcc << DECIMAL_BITS ),
]

#----------------------------------------------------------------------
# Test Case: large negative * negative
#----------------------------------------------------------------------

large_neg_neg_msgs = [
  req( 0x80000001 << DECIMAL_BITS, 0x80000001 << DECIMAL_BITS ), resp( 0x00000001 << DECIMAL_BITS ),
  req( 0x8000abcd << DECIMAL_BITS, 0x8000ef00 << DECIMAL_BITS ), resp( 0x20646300 << DECIMAL_BITS ),
  req( 0x80340580 << DECIMAL_BITS, 0x8aadefc0 << DECIMAL_BITS ), resp( 0x6fa6a000 << DECIMAL_BITS ),
]

#----------------------------------------------------------------------
# Test Case: zeros
#----------------------------------------------------------------------

zeros_msgs = [
  req(  0 << DECIMAL_BITS,  0 << DECIMAL_BITS ), resp(   0 << DECIMAL_BITS ),
  req(  0 << DECIMAL_BITS,  1 << DECIMAL_BITS ), resp(   0 << DECIMAL_BITS ),
  req(  1 << DECIMAL_BITS,  0 << DECIMAL_BITS ), resp(   0 << DECIMAL_BITS ),
  req(  0 << DECIMAL_BITS, -1 << DECIMAL_BITS ), resp(   0 << DECIMAL_BITS ),
  req( -1 << DECIMAL_BITS,  0 << DECIMAL_BITS ), resp(   0 << DECIMAL_BITS ),
]
#----------------------------------------------------------------------
# Test Case: random small
#----------------------------------------------------------------------

random_small_msgs = []
for i in range(50):
  a = random.randint(0,100)
  b = random.randint(0,100)
  random_small_msgs.extend([ req( a << DECIMAL_BITS , b << DECIMAL_BITS ), resp( (a * b) << DECIMAL_BITS ) ])

#----------------------------------------------------------------------
# Test Case: random large
#----------------------------------------------------------------------

random_large_msgs = []
for i in range(50):
  a = random.randint(0,0xffffffff)
  b = random.randint(0,0xffffffff)
  random_large_msgs.extend([ req( a << DECIMAL_BITS, b << DECIMAL_BITS ), resp( (a * b) << DECIMAL_BITS ) ])

#----------------------------------------------------------------------
# Test Case: lomask
#----------------------------------------------------------------------

random_lomask_msgs = []
for i in range(50):

  shift_amount = random.randint(0,16)
  a = random.randint(0,0xffffffff) << shift_amount

  shift_amount = random.randint(0,16)
  b = random.randint(0,0xffffffff) << shift_amount

  random_lomask_msgs.extend([ req( a << DECIMAL_BITS, b << DECIMAL_BITS ), resp( (a * b) << DECIMAL_BITS ) ])

#----------------------------------------------------------------------
# Test Case: himask
#----------------------------------------------------------------------

random_himask_msgs = []
for i in range(50):

  shift_amount = random.randint(0,16)
  a = random.randint(0,0xffffffff) >> shift_amount

  shift_amount = random.randint(0,16)
  b = random.randint(0,0xffffffff) >> shift_amount

  random_himask_msgs.extend([ req( a << DECIMAL_BITS, b << DECIMAL_BITS ), resp( (a * b) << DECIMAL_BITS ) ])

#----------------------------------------------------------------------
# Test Case: lohimask
#----------------------------------------------------------------------

random_lohimask_msgs = []
for i in range(50):

  rshift_amount = random.randint(0,12)
  lshift_amount = random.randint(0,12)
  a = (random.randint(0,0xffffff) >> rshift_amount) << lshift_amount

  rshift_amount = random.randint(0,12)
  lshift_amount = random.randint(0,12)
  b = (random.randint(0,0xffffff) >> rshift_amount) << lshift_amount

  random_lohimask_msgs.extend([ req( a << DECIMAL_BITS, b << DECIMAL_BITS ), resp( (a * b) << DECIMAL_BITS ) ])

#----------------------------------------------------------------------
# Test Case: sparse
#----------------------------------------------------------------------

random_sparse_msgs = []
for i in range(50):

  a = random.randint(0,0xffffffff)

  for i in range(32):
    is_masked = random.randint(0,1)
    if is_masked:
      a = a & ( (~(1 << i)) & 0xffffffff )

  b = random.randint(0,0xffffffff)

  for i in range(32):
    is_masked = random.randint(0,1)
    if is_masked:
      b = b & ( (~(1 << i)) & 0xffffffff )

  random_sparse_msgs.extend([ req( a << DECIMAL_BITS, b << DECIMAL_BITS ), resp( (a * b) << DECIMAL_BITS ) ])

#-------------------------------------------------------------------------
# Test Case Table
#-------------------------------------------------------------------------

test_case_table = mk_test_case_table([
  (                      "msgs                 src_delay sink_delay"),
  [ "small_pos_pos",     small_pos_pos_msgs,   0,        0          ],
  [ "small_neg_pos",     small_neg_pos_msgs,   0,        0          ],
  [ "small_pos_neg",     small_pos_neg_msgs,   0,        0          ],
  [ "small_neg_neg",     small_neg_neg_msgs,   0,        0          ],
  [ "large_pos_pos",     large_pos_pos_msgs,   0,        0          ],
  [ "large_neg_neg",     large_neg_neg_msgs,   0,        0          ],
  [ "zeros",             zeros_msgs,           0,        0          ],
  [ "random_small",      random_small_msgs,    0,        0          ],
  [ "random_large",      random_large_msgs,    0,        0          ],
  [ "random_lomask",     random_lomask_msgs,   0,        0          ],
  [ "random_himask",     random_himask_msgs,   0,        0          ],
  [ "random_lohimask",   random_lohimask_msgs, 0,        0          ],
  [ "random_sparse",     random_sparse_msgs,   0,        0          ],
  [ "random_small_3x14", random_small_msgs,    3,        14         ],
  [ "random_large_3x14", random_large_msgs,    3,        14         ],
])

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

@pytest.mark.parametrize( **test_case_table )
def test( test_params, cmdline_opts ):

  th = TestHarness( fpmult( BITS, DECIMAL_BITS) )

  th.set_param("top.src.construct",
    msgs=test_params.msgs[::2],
    initial_delay=test_params.src_delay+3,
    interval_delay=test_params.src_delay )

  th.set_param("top.sink.construct",
    msgs=test_params.msgs[1::2],
    initial_delay=test_params.sink_delay+3,
    interval_delay=test_params.sink_delay )

  run_sim( th, cmdline_opts, duts=['fpmult'] )

