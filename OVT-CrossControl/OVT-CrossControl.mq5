//+------------------------------------------------------------------+
//|                                             OVT-CrossControl.mq5 |
//|                             Copyright 2018, OmniaVincit Trading. |
//|                                   https://www.omniavincit.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, OmniaVincit Trading."
#property link      "https://www.omniavincit.com.br"
#property version   "1.00"
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
CTrade trade;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   IsBuySignal();

  }
//+------------------------------------------------------------------+

bool IsBuySignal()
  {
   if(PositionSelect(_Symbol)) return false;

   const int handle_mm3=iMA(_Symbol,PERIOD_CURRENT,3,0,MODE_SMA,PRICE_CLOSE);
   double values_mm3[];

   const int handle_mm8=iMA(_Symbol,PERIOD_CURRENT,8,0,MODE_SMA,PRICE_CLOSE);
   double values_mm8[];

   ObjectDelete(ChartID(),"buy_obj");
   ObjectDelete(ChartID(),"sell_obj");

   ArraySetAsSeries(values_mm3,true);
   ArraySetAsSeries(values_mm8,true);
   ENUM_ORDER_TYPE signal=WRONG_VALUE;

   if(CopyBuffer(handle_mm3,0,0,10,values_mm3)>=0)
     {

      if(CopyBuffer(handle_mm8,0,0,10,values_mm8)>=0)
        {
         if(values_mm3[4]<values_mm3[2] && values_mm8[4]>values_mm8[2] && values_mm3[4]<values_mm8[4] && values_mm3[2]>values_mm8[2])
           {
            //ObjectCreate(0,"buy_obj",OBJ_ARROW_BUY,0,TimeCurrent(), SymbolInfoDouble(_Symbol,SYMBOL_LAST));
            signal=ORDER_TYPE_BUY;  // buy condition
           }

         if(values_mm3[4]>values_mm3[2] && values_mm8[4]<values_mm8[2] && values_mm3[4]>values_mm8[4] && values_mm3[2]<values_mm8[2])
           {
            ObjectCreate(0,"sell_obj",OBJ_ARROW_SELL,0,TimeCurrent(),SymbolInfoDouble(_Symbol,SYMBOL_LAST));
            signal=ORDER_TYPE_SELL;    // sell condition
           }

         if(signal!=WRONG_VALUE)
           {
            
            trade.SetTypeFilling(ORDER_FILLING_RETURN);
            trade.PositionOpen(_Symbol,signal,1,
                               SymbolInfoDouble(_Symbol,signal==ORDER_TYPE_SELL ? SYMBOL_BID:SYMBOL_ASK),
                               0,0);
                               
            uint x = trade.ResultRetcode();
            string y = trade.ResultRetcodeDescription();
           }
        }
     }

   return false;

  }
//+------------------------------------------------------------------+
