#=========================================================================
# Register_test
#=========================================================================

import pytest

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim

from register.Register import RegisterV, RegisterV_Reset

def test_simple( cmdline_opts):
	run_test_vector_sim(RegisterV(32),[
		('w  d     q*'),
		[0, 0x00, '?' ],
		[1, 0x00, 0x00],
		[0, 0x01, 0x00],
	],cmdline_opts)  

def test_resetability( cmdline_opts ):
	r = RegisterV(32)
	rr = RegisterV_Reset(32)
	vectors = [
		('w reset d     q*'),
		[1, 0, 0x01, '?' ],
		[1, 0, 0x02, 0x01],
		[1, 0, 0x03, 0x02],
		[0, 0, 0x00, 0x03],
		[1, 1, 0x01, 0x03],
		[1, 0, 0x00, 0x01],
		[0, 0, 0x01, 0x00],
	]
	vectorsr = [
		('w reset d     q*'),
		[1, 0, 0x01, '?' ],
		[1, 0, 0x02, 0x01],
		[1, 0, 0x03, 0x02],
		[0, 0, 0x00, 0x03],
		[1, 1, 0x01, 0x03],
		[1, 0, 0x03, 0x00],
		[0, 0, 0x01, 0x03],
	]
	run_test_vector_sim(r, vectors, cmdline_opts)
	run_test_vector_sim(rr, vectorsr, cmdline_opts)

def test_reset_reg ( cmdline_opts ):
	run_test_vector_sim(RegisterV(32), [
		('w d     q*'),
		[1, 0x01, '?' ],
		[1, 0x02, 0x01],
		[1, 0x03, 0x02],
		[0, 0x00, 0x03],
		[1, 0x01, 0x03],
	], cmdline_opts)
