'''
Master SPI Testing
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

#import verilog spi model here

"""
Right now trying to put down basic blocks together for building
tests. 
"""

def test( model, cs_addr, packet_size, recv, send, cs, sclk, mosi, miso ): 
    
    model.cs_addr
    model.miso @= miso

    """
    need to assert

    mosi
    sclk
    cs
    send_val
    recv_rdy
    send_msg

    """

def reset(model):
    model.miso @= 0
    model.send_rdy @= 0
    model.recv_msg @= 0
    model.recv_val @= 0

def basic_test(cmd_line_opts): 
    model = #spi model
    model = config_model_with_cmdline_opts( model, cmdline_opts, duts=[] )

    #https://pymtl3.readthedocs.io/en/latest/ref/passes-sim-api.html
    model.apply(DefaultPassGroup(linetracing=True))
    reset(model)




    

    #run items here
    # cs   packet
    # addr size    recv send cs  sclk mosi, miso
    t( 0,   0,      0,   0,   0,  0,   0,    0   ); #setting up formatting
