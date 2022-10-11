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
    
    model.cs_addr_ifc_val     @= cs_addr[0]
    model.cs_addr_ifc_msg     @= cs_addr[2]
    model.packet_size_ifc_val @= packet_size[0]
    model.packet_size_ifc_msg @= packet_size[2]
    model.recv_val            @= recv[0]
    model.recv_msg            @= recv[2]
    model.send_rdy            @= send[1]
    model.miso                @= miso

    assert model.cs_addr_ifc_rdy == cs_addr[1]
    assert model.packet_size_rdy == packet_size[1]
    assert model.recv_rdy == recv_rdy[1]
    assert model.send_val == send_val[0]
    assert model.cs == cs

    if (send[2] != '?'):
        assert model.send_msg == send[2]

    if (mosi != '?'):
        assert model.mosi == mosi

    if (sclk != '?'):
        assert model.sclk == sclk

    model.sim_tick()

def reset(model):
    model.miso                @= 0
    model.send_rdy            @= 0
    model.recv_msg            @= 0
    model.recv_val            @= 0
    model.cs_addr_ifc_msg     @= 0
    model.cs_addr_ifc_val     @= 0
    model.packet_size_ifc_msg @= 0
    model.packet_size_ifc_val @= 0
    model.sim_reset()

def basic_test(cmd_line_opts): 
    model = #spi model
    model = config_model_with_cmdline_opts( model, cmdline_opts, duts=[] )

    #https://pymtl3.readthedocs.io/en/latest/ref/passes-sim-api.html
    model.apply(DefaultPassGroup(linetracing=True))
    reset(model)




    

    #run items here
    #             cs        packet
    #  model      addr      size      recv      send       cs   sclk   mosi   miso
    #INIT
    test( model      [1,1,0],  [0,1,0],  [0,0,0]   [0,0,0],   1,   0,     '?',     0 ); #setting up for 
    test( model      [0,0,0],  [0,1,0],  [0,0,0]   [0,0,0],   1,   0,     '?',     0 ); #setting up formatting
    test( model      [0,0,0],  [0,1,0],  [0,0,0]   [0,0,0],   1,   0,     '?',     0 ); #setting up formatting
    #START0
    test( model      [0,0,0],  [0,0,0],  [0,0,0]   [0,0,0],   0,   0,     0,     0 ); #setting up formatting
    #START1
    test( model      [0,0,0],  [0,0,0],  [0,0,0]   [0,0,0],   0,   0,     0,     0 ); #setting up formatting
    #HIGH LOW
    test( model      [0,0,0],  [0,0,0],  [0,0,0]   [0,0,0],   0,   0,     0,     0 ); #setting up formatting
    test( model      [0,0,0],  [0,0,0],  [0,0,0]   [0,0,0],   0,   0,     0,     0 ); #setting up formatting
    #HIGH LOW
    test( model      [0,0,0],  [0,0,0],  [0,0,0]   [0,0,0],   0,   0,     0,     0 ); #setting up formatting
    test( model      [0,0,0],  [0,0,0],  [0,0,0]   [0,0,0],   0,   0,     0,     0 ); #setting up formatting
    #HIGH LOW
    test( model      [0,0,0],  [0,0,0],  [0,0,0]   [0,0,0],   0,   0,     0,     0 ); #setting up formatting
    test( model      [0,0,0],  [0,0,0],  [0,0,0]   [0,0,0],   0,   0,     0,     0 ); #setting up formatting
    #CS LOW WAIT
    test( model      [0,0,0],  [0,0,0],  [0,0,0]   [0,0,0],   0,   0,     0,     0 ); #setting up formatting
    #DONE


