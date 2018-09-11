//+------------------------------------------------------------------+
//|                                             OVT-OptionTravas.mq5 |
//|                             Copyright 2018, OmniaVincit Trading. |
//|                                   https://www.omniavincit.com.br |
//+------------------------------------------------------------------+

#include "OVT-OptionTravas_FrontEnd.mqh"
#property copyright "Copyright 2018, OmniaVincit Trading."
#property link      "https://www.omniavincit.com.br"
#property version   "1.00"

OVTOptionTravasFrontEnd frm;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!frm.Create(0,"Controls",0,20,20,360,324))
     return(INIT_FAILED);
     
     
   frm.Run();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   frm.Destroy(reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   frm.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
