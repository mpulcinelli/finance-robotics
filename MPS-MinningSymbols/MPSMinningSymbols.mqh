//+------------------------------------------------------------------+
//|                                            MPSMinningSymbols.mqh |
//|                        Copyright 2018, Márcio Pulcinelli         |
//|                                http://omniavincittrading.com.br/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

sinput string SEP0="*********************************************"; // CONFIG

input int Tempo=2; // TEMPO DE ATUALIZAÇÃO
input string ListaAtivos=""; // LISTA DE ATIVOS PARA EXIBIÇÃO (Sep --> ;)
input bool show_alert=false; // EXIBIR ALERTAS?

sinput string SEP1="*********************************************"; // INDICADORES
input int mfi_value=14; // VALOR MFI
input int force_value=14; // VALOR FORCE INDEX
input double trigger_compra_mfi= 30; // ENTRADA MFI < x
input double trigger_saida_mfi = 70; // SAIDA MFI > x
input double trigger_compra_force=-0.001; // ENTRADA FORCE < x
input double trigger_saida_force=0.001; // SAIDA FORCE > x
//+------------------------------------------------------------------+
//| Expert para mining baseado em MFI e Force Index.
//+------------------------------------------------------------------+
class CMPSMinningSymbols
  {

   enum OPERACAO
     {
      COMPRA,
      VENDA,
      FORA
     };

private:

   int               symb_position;

public:
                     CMPSMinningSymbols();
                    ~CMPSMinningSymbols();

   void              ChangeSymbol();
   void              ImprimeOperacao();

private:

   OPERACAO          GetForce(string simb,double &current_val);
   OPERACAO          GetMFI(string simb,double &current_val);
   void              GetListaAtivos(string &ativos[]);
   void              SetInitPosition();

  };
//+------------------------------------------------------------------+
//| Inicialização da classe.                                         
//+------------------------------------------------------------------+
CMPSMinningSymbols::CMPSMinningSymbols()
  {
   EventSetTimer(Tempo);
   SetInitPosition();
  }
//+------------------------------------------------------------------+
//| <Márcio Pulcinell>
//| 
//| Recuperar a operação segundo critérios do MFI
//| 
//+------------------------------------------------------------------+
OPERACAO CMPSMinningSymbols::GetMFI(string simb,double &current_val)
  {

   const int hwnd_mfi=iMFI(simb,PERIOD_CURRENT,mfi_value,VOLUME_TICK);

   double mfi_values[];

   ArraySetAsSeries(mfi_values,true);

   if(CopyBuffer(hwnd_mfi,0,0,10,mfi_values)>=0)
     {
      current_val=mfi_values[0];
     }
   else
     {
      current_val=-1;
      return OPERACAO::FORA;
     }

   if(current_val<=trigger_compra_mfi)
     {
      return OPERACAO::COMPRA;
     }
   else if(current_val>trigger_saida_mfi)
     {
      return OPERACAO::VENDA;
     }

   return OPERACAO::FORA;

  }
//+------------------------------------------------------------------+
//| <Márcio Pulcinell>
//| 
//| Recuperar a operação segundo critérios do Force Index.
//| 
//+------------------------------------------------------------------+
OPERACAO CMPSMinningSymbols::GetForce(string simb,double &current_val)
  {
   const int hwnd_force=iForce(simb,PERIOD_CURRENT,force_value,MODE_SMA,VOLUME_TICK);

   double force_values[];

   ArraySetAsSeries(force_values,true);

   if(CopyBuffer(hwnd_force,0,0,10,force_values)>=0)
     {
      current_val=force_values[0];
     }
   else
     {
      current_val=-1;
      return OPERACAO::FORA;
     }

   if(current_val<=trigger_compra_force)
     {
      return OPERACAO::COMPRA;
     }
   else if(current_val>=trigger_saida_force)
     {
      return OPERACAO::VENDA;
     }

   return OPERACAO::FORA;

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
void CMPSMinningSymbols::GetListaAtivos(string &ativos[])
  {
   const int tamanho=StringLen(ListaAtivos);
   
   string ArrAtivos[];
   
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
     
     ArrayCopy(ativos,ArrAtivos);
  }
//+------------------------------------------------------------------+
//| Este método tem o objetivo de exibir os resultados 
//| dos critérios aplicados.
//+------------------------------------------------------------------+
void CMPSMinningSymbols::ImprimeOperacao()
  {
   double mfi_curr_val=0.0;
   double force_curr_val=0.0;
   const OPERACAO force=GetForce(_Symbol,force_curr_val);
   const OPERACAO mfi=GetMFI(_Symbol,mfi_curr_val);

   if(mfi==COMPRA && force==COMPRA)
     {
      if(show_alert)
         Alert(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[COMPRA]");

      Print(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[COMPRA]");
     }
   else if(mfi==VENDA && force==VENDA)
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

   string ArrAtivos[];

   GetListaAtivos(ArrAtivos);
   
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
