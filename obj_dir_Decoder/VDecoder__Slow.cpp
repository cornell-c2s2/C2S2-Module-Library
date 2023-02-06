// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VDecoder.h for the primary calling header

#include "VDecoder.h"
#include "VDecoder__Syms.h"

//==========

VL_CTOR_IMP(VDecoder) {
    VDecoder__Syms* __restrict vlSymsp = __VlSymsp = new VDecoder__Syms(this, name());
    VDecoder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void VDecoder::__Vconfigure(VDecoder__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
    Verilated::timeunit(-12);
    Verilated::timeprecision(-12);
}

VDecoder::~VDecoder() {
    VL_DO_CLEAR(delete __VlSymsp, __VlSymsp = NULL);
}

void VDecoder::_eval_initial(VDecoder__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDecoder::_eval_initial\n"); );
    VDecoder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void VDecoder::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDecoder::final\n"); );
    // Variables
    VDecoder__Syms* __restrict vlSymsp = this->__VlSymsp;
    VDecoder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void VDecoder::_eval_settle(VDecoder__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDecoder::_eval_settle\n"); );
    VDecoder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_combo__TOP__1(vlSymsp);
}

void VDecoder::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDecoder::_ctor_var_reset\n"); );
    // Body
    reset = VL_RAND_RESET_I(1);
    clk = VL_RAND_RESET_I(1);
    enable = VL_RAND_RESET_I(1);
    x = VL_RAND_RESET_I(1);
    y = VL_RAND_RESET_I(2);
}
