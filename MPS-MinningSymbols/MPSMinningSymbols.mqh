//+------------------------------------------------------------------+
//|                                            MPSMinningSymbols.mqh |
//|                        Copyright 2018, Márcio Pulcinelli         |
//|                                http://omniavincittrading.com.br/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

input int Tempo=2; // TEMPO DE ATUALIZAÇÃO
input string ListaAtivos=""; // LISTA DE ATIVOS PARA EXIBIÇÃO (Sep --> ;)

input int mfi_value=14; // VALOR MFI
input int force_value=14; // VALOR FORCE INDEX
input double trigger_compra_mfi= 30; // ENTRADA MFI < x
input double trigger_saida_mfi = 70; // SAIDA MFI > x

input double trigger_compra_force=-0.001; // ENTRADA FORCE < x
input double trigger_saida_force=0.001; // SAIDA FORCE > x

input bool show_alert=false; // EXIBIR ALERTAS?
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+




class CMPSMinningSymbols
  {

   enum OPER_MFI
     {
      MFI_COMPRA,
      MFI_VENDA,
      MFI_FORA
     };

   enum OPER_FORCE
     {
      FORCE_COMPRA,
      FORCE_VENDA,
      FORCE_FORA
     };

private:

   string            ArrAtivos[];

   int               hwnd_mfi;
   int               hwnd_force;
   double            mfi_curr_val;
   double            force_curr_val;
   int               symb_position;
public:
                     CMPSMinningSymbols();
                    ~CMPSMinningSymbols();

   void              ChangeSymbol();
   void              ImprimeOperacao();
   OPER_FORCE        GetForce(string simb);
   OPER_MFI          GetMFI(string simb);
   void              GetListaAtivos();
   void              SetInitPosition();

  };
//+------------------------------------------------------------------+
//| Inicialização da classe.                                         
//+------------------------------------------------------------------+
CMPSMinningSymbols::CMPSMinningSymbols()
  {
   EventSetTimer(Tempo);

   GetListaAtivos();
   SetInitPosition();
  }
//+------------------------------------------------------------------+
//| <Márcio Pulcinell>
//| 
//| Recuperar a operação segundo critérios do MFI
//| 
//+------------------------------------------------------------------+
OPER_MFI CMPSMinningSymbols::GetMFI(string simb)
  {

   hwnd_mfi=iMFI(simb,PERIOD_CURRENT,mfi_value,VOLUME_TICK);

   double mfi_values[];

   ArraySetAsSeries(mfi_values,true);

   if(CopyBuffer(hwnd_mfi,0,0,10,mfi_values)>=0)
     {
      mfi_curr_val=mfi_values[0];
     }
   else
     {
      return OPER_MFI::MFI_FORA;
     }

   if(mfi_curr_val<=trigger_compra_mfi)
     {
      return OPER_MFI::MFI_COMPRA;
     }
   else if(mfi_curr_val>trigger_saida_mfi)
     {
      return OPER_MFI::MFI_VENDA;
     }

   return OPER_MFI::MFI_FORA;

  }
//+------------------------------------------------------------------+
//| <Márcio Pulcinell>
//| 
//| Recuperar a operação segundo critérios do Force Index.
//| 
//+------------------------------------------------------------------+
OPER_FORCE CMPSMinningSymbols::GetForce(string simb)
  {
   hwnd_force=iForce(simb,PERIOD_CURRENT,force_value,MODE_SMA,VOLUME_TICK);

   double force_values[];

   ArraySetAsSeries(force_values,true);

   if(CopyBuffer(hwnd_force,0,0,10,force_values)>=0)
     {
      force_curr_val=force_values[0];
     }
   else
     {
      return OPER_FORCE::FORCE_FORA;
     }

   if(force_curr_val<=trigger_compra_force)
     {
      return OPER_FORCE::FORCE_COMPRA;
     }
   else if(force_curr_val>=trigger_saida_force)
     {
      return OPER_FORCE::FORCE_VENDA;
     }

   return OPER_FORCE::FORCE_FORA;

  }
//+------------------------------------------------------------------+
//| Destrutor da classe.                                            |
//+------------------------------------------------------------------+
CMPSMinningSymbols::~CMPSMinningSymbols()
  {
   EventKillTimer();
   Comment("");
  }
//+------------------------------------------------------------------+
//| Recupera os simbolos para exibição no gráfico.
//| - Caso a lista de ativos não seja preenchida no expert, 
//| - serão usados os símbolos do market watch.
//+------------------------------------------------------------------+
void CMPSMinningSymbols::GetListaAtivos()
  {
   const int tamanho=StringLen(ListaAtivos);

   if(tamanho>0)
     {
      StringSplit(ListaAtivos,';',ArrAtivos);
     }
   else
     {
      const int simb_total=SymbolsTotal(true);
      ArrayResize(ArrAtivos,simb_total);
      for(int i=0;i<simb_total;i++)
        {
         const string sname=SymbolName(i,true);
         ArrAtivos[i]=sname;
        }
     }
  }
//+------------------------------------------------------------------+
//| Este método tem o objetivo de exibir os resultados 
//| dos critérios aplicados.
//+------------------------------------------------------------------+
void CMPSMinningSymbols::ImprimeOperacao()
  {
   const OPER_FORCE force=GetForce(_Symbol);
   const OPER_MFI mfi=GetMFI(_Symbol);

   if(mfi==MFI_COMPRA && force==FORCE_COMPRA)
     {
      if(show_alert)
         Alert(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[COMPRA]");

      Print(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[COMPRA]");
     }
   else if(mfi==MFI_VENDA && force==FORCE_VENDA)
     {
      if(show_alert)
         Alert(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[VENDA]");

      Print(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[VENDA]");
     }

   Comment(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[VENDA]");

  }
//+------------------------------------------------------------------+
//| Método responsável por trocar o símbolo no gráfico.
//+------------------------------------------------------------------+
void CMPSMinningSymbols::ChangeSymbol()
  {
   const int qtd_simb_lista=ArraySize(ArrAtivos);

   const string sname=ArrAtivos[symb_position];

   ChartSetSymbolPeriod(0,sname,PERIOD_CURRENT);

   if(symb_position>=qtd_simb_lista-1)
     {
      symb_position=0;
     }
   else
     {
      symb_position+=1;
     }
  }
//+------------------------------------------------------------------+
//| Inicializa a posição de leitura dos gráficos.
//+------------------------------------------------------------------+
void CMPSMinningSymbols::SetInitPosition()
  {
   symb_position=0;
  }
//+------------------------------------------------------------------+
