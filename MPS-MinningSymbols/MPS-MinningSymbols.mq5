//+------------------------------------------------------------------+
//|                                            MPSMinningSymbols.mqh |
//|                        Copyright 2018, Márcio Pulcinelli         |
//|                                http://omniavincittrading.com.br/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Márcio Pulcinelli"
#property link      "http://omniavincittrading.com.br/"
#property version   "1.00"

#include "MPSMinningSymbols.mqh"

CMPSMinningSymbols ms;

int OnInit()
  {
  
  ms.ImprimeOperacao();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   ms.ChangeSymbol();
  }
