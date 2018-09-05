//+------------------------------------------------------------------+
//|                                            MPSMinningSymbols.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

input int Tempo=2; // TEMPO DE ATUALIZAÇÃO
input string ListaAtivos=""; // LISTA DE ATIVOS PARA EXIBIÇÃO (Sep --> ;)
input int mfi_value=14; // VALOR MFI
input double trigger_compra= 30; // ENTRADA < x
input double trigger_saida = 70; // SAIDA > x
input bool show_alert=false; // EXIBIR ALERTAS?
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMPSMinningSymbols
  {
private:

   string            ArrAtivos[];

   int               hwnd_mfi;
   double            mfi_curr_val;

public:
                     CMPSMinningSymbols();
                    ~CMPSMinningSymbols();

   void              ChangeSymbol();
   void              ImprimeOperacao();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMPSMinningSymbols::CMPSMinningSymbols()
  {
      ImprimeOperacao();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMPSMinningSymbols::~CMPSMinningSymbols()
  {
   EventKillTimer();
   Comment("");
  }
//+------------------------------------------------------------------+

void CMPSMinningSymbols::ImprimeOperacao()
{
   EventSetTimer(Tempo);
   StringSplit(ListaAtivos,';',ArrAtivos);
   hwnd_mfi=iMFI(_Symbol,PERIOD_CURRENT,mfi_value,VOLUME_TICK);

   double mfi_values[];
   ArraySetAsSeries(mfi_values,true);

   if(CopyBuffer(hwnd_mfi,0,0,10,mfi_values)>=0)
     {
      mfi_curr_val=mfi_values[0];
     }

   if(mfi_curr_val<=trigger_compra)
     {
      if(show_alert)
         Alert(_Symbol," MFI [",mfi_curr_val,"] Possibilidade de COMPRA Válida!");

      Print(_Symbol," MFI [",mfi_curr_val,"] Possibilidade de COMPRA Válida!");
     }
   else if(mfi_curr_val>trigger_saida)
     {
      if(show_alert)
         Alert(_Symbol," MFI [",mfi_curr_val,"] Possibilidade de VENDA Válida!");

      Print(_Symbol," MFI [",mfi_curr_val,"] Possibilidade de VENDA Válida!");
     }

   Comment(_Symbol,"   MFI: [",mfi_curr_val,"]");

}


void CMPSMinningSymbols::ChangeSymbol()
  {
   double position=GlobalVariableGet("SymbPosition");
   int HowManySymbols=0;
   int QuantidadeAtivosLista=ArraySize(ArrAtivos);

   if(QuantidadeAtivosLista<=0)
     {
      HowManySymbols=SymbolsTotal(true);

      if(position<HowManySymbols)
        {
         string sname=SymbolName((int)position,true);
         double newVal=position+1;
         GlobalVariableSet("SymbPosition",newVal);
         ChartSetSymbolPeriod(0,sname,PERIOD_CURRENT);
        }
      else
        {
         GlobalVariableSet("SymbPosition",0);
         Comment("");
        }

        }else{
      HowManySymbols=SymbolsTotal(true);
      Comment(position);

      if(position<QuantidadeAtivosLista)
        {
         string sname=ArrAtivos[(int)position];
         double newVal=position+1;
         GlobalVariableSet("SymbPosition",newVal);
         ChartSetSymbolPeriod(0,sname,PERIOD_CURRENT);

        }
      else
        {
         GlobalVariableSet("SymbPosition",0);
         Comment("");
        }
     }
  }
//+------------------------------------------------------------------+
