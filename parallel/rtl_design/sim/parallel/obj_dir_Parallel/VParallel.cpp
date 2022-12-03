// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VParallel.h for the primary calling header

#include "VParallel.h"
#include "VParallel__Syms.h"

//==========

void VParallel::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate VParallel::eval\n"); );
    VParallel__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    VParallel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
#ifdef VL_DEBUG
    // Debug assertions
    _eval_debug_assertions();
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("ParallelVRTL.v", 92, "",
                "Verilated model didn't converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

void VParallel::_eval_initial_loop(VParallel__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        _eval_settle(vlSymsp);
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("ParallelVRTL.v", 92, "",
                "Verilated model didn't DC converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

VL_INLINE_OPT void VParallel::_sequent__TOP__1(VParallel__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VParallel::_sequent__TOP__1\n"); );
    VParallel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if ((((~ (IData)(vlTOPp->reset)) & (IData)(vlTOPp->VIN)) 
         & (IData)(vlTOPp->RIN))) {
        vlTOPp->VOUT = 1U;
    }
    if ((((~ (IData)(vlTOPp->reset)) & (IData)(vlTOPp->VIN)) 
         & (IData)(vlTOPp->RIN))) {
        vlTOPp->ROUT = 1U;
    }
    if ((2U & (IData)(vlTOPp->DOUT))) {
        vlTOPp->Parallel__DOT__v__DOT__b__DOT__regout 
            = vlTOPp->dta;
    }
    if ((1U & (IData)(vlTOPp->DOUT))) {
        vlTOPp->Parallel__DOT__v__DOT__a__DOT__regout 
            = vlTOPp->dta;
    }
    if ((((~ (IData)(vlTOPp->reset)) & (IData)(vlTOPp->VIN)) 
         & (IData)(vlTOPp->RIN))) {
        vlTOPp->DSEL = 0U;
    }
    vlTOPp->EN = (((~ (IData)(vlTOPp->reset)) & (IData)(vlTOPp->VIN)) 
                  & (IData)(vlTOPp->RIN));
    vlTOPp->OUTPUTB = (3U & vlTOPp->Parallel__DOT__v__DOT__b__DOT__regout);
    vlTOPp->OUTPUTA = (3U & vlTOPp->Parallel__DOT__v__DOT__a__DOT__regout);
    vlTOPp->DOUT = ((IData)(vlTOPp->EN) ? (3U & ((IData)(1U) 
                                                 << (IData)(vlTOPp->DSEL)))
                     : 0U);
}

void VParallel::_eval(VParallel__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VParallel::_eval\n"); );
    VParallel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if (((IData)(vlTOPp->clk) & (~ (IData)(vlTOPp->__Vclklast__TOP__clk)))) {
        vlTOPp->_sequent__TOP__1(vlSymsp);
    }
    // Final
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
}

VL_INLINE_OPT QData VParallel::_change_request(VParallel__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VParallel::_change_request\n"); );
    VParallel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    return (vlTOPp->_change_request_1(vlSymsp));
}

VL_INLINE_OPT QData VParallel::_change_request_1(VParallel__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VParallel::_change_request_1\n"); );
    VParallel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}

#ifdef VL_DEBUG
void VParallel::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VParallel::_eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((RIN & 0xfeU))) {
        Verilated::overWidthError("RIN");}
    if (VL_UNLIKELY((VIN & 0xfeU))) {
        Verilated::overWidthError("VIN");}
    if (VL_UNLIKELY((clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((reset & 0xfeU))) {
        Verilated::overWidthError("reset");}
}
#endif  // VL_DEBUG
