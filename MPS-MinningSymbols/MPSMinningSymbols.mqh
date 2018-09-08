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

sinput string SEP2="*********************************************"; // DIVERGÊNCIA
input int num_bars = 15; // NUMERO DE BARRAS
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

   enum DIVERGENCIA
     {
      DIVERGENCIA_ALTA,
      DIVERGENCIA_BAIXA,
      SEM_DIVERGENCIA
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
   DIVERGENCIA       FindDivergences();
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
//|                                                                  |
//+------------------------------------------------------------------+
DIVERGENCIA CMPSMinningSymbols::FindDivergences()
  {

   StdDevChannelDelete(ChartID(),"CH0");
   StdDevChannelDelete(ChartID(),"CH1");

   ChartRedraw(ChartID());

   StdDevChannelCreate(ChartID(),"CH0",0,TimeCurrent()-(86400*num_bars),TimeCurrent(),1,clrLightBlue,STYLE_DASH,1,false,true,false,false,false,false);
   StdDevChannelCreate(ChartID(),"CH1",1,TimeCurrent()-(86400*num_bars),TimeCurrent(),1,clrLightBlue,STYLE_DASH,1,false,true,false,false,false,false);

   Sleep(500);

   ChartRedraw(ChartID());
   const double chart_1 = ObjectGetDouble(ChartID(),"CH0",OBJPROP_PRICE,0);
   const double chart_2 = ObjectGetDouble(ChartID(),"CH0",OBJPROP_PRICE,1);

   const double ind_1 = ObjectGetDouble(ChartID(),"CH1",OBJPROP_PRICE,0);
   const double ind_2 = ObjectGetDouble(ChartID(),"CH1",OBJPROP_PRICE,1);


   //Print("chart_1:",chart_1," chart_2:",chart_2," ind_1:",ind_1," ind_2:",ind_2);

   if(chart_1>chart_2 && ind_1<ind_2)
     {
         return DIVERGENCIA_ALTA;
     }
   else if(chart_1<chart_2 && ind_1>ind_2)
     {
         return DIVERGENCIA_BAIXA;
     }

   return SEM_DIVERGENCIA;
   
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
   
   const DIVERGENCIA diver=FindDivergences();

   if(mfi==COMPRA && force==COMPRA)
     {
      if(show_alert)
         Alert(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[COMPRA] - DIVERG = ", EnumToString(diver));

      Print(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[COMPRA] - DIVERG = ", EnumToString(diver));
     }
   else if(mfi==VENDA && force==VENDA)
     {
      if(show_alert)
         Alert(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[VENDA] - DIVERG = ", EnumToString(diver));

      Print(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[VENDA] - DIVERG = ", EnumToString(diver));
     }

   Comment(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:  - DIVERG = ", EnumToString(diver));

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

//+------------------------------------------------------------------+ 
//| Create standard deviation channel by the given coordinates       | 
//+------------------------------------------------------------------+ 
bool StdDevChannelCreate(const long            chart_ID=0,        // chart's ID 
                         const string          name="Channel",    // channel name 
                         const int             sub_window=0,      // subwindow index  
                         datetime              time1=0,           // first point time 
                         datetime              time2=0,           // second point time 
                         const double          deviation=1.0,     // deviation  
                         const color           clr=clrRed,        // channel color 
                         const ENUM_LINE_STYLE style=STYLE_SOLID, // style of channel lines 
                         const int             width=1,           // width of channel lines 
                         const bool            fill=false,        // filling the channel with color 
                         const bool            back=false,        // in the background 
                         const bool            selection=true,    // highlight to move 
                         const bool            ray_left=false,    // channel's continuation to the left 
                         const bool            ray_right=false,   // channel's continuation to the right 
                         const bool            hidden=true,       // hidden in the object list 
                         const long            z_order=0)         // priority for mouse click 
  {
//--- set anchor points' coordinates if they are not set 
   ChangeChannelEmptyPoints(time1,time2);
//--- reset the error value 
   ResetLastError();
//--- create a channel by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_STDDEVCHANNEL,sub_window,time1,0,time2,0))
     {
      Print(__FUNCTION__,
            ": failed to create standard deviation channel! Error code = ",GetLastError());
      return(false);
     }
//--- set deviation value affecting the channel width 
   ObjectSetDouble(chart_ID,name,OBJPROP_DEVIATION,deviation);
//--- set channel color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set style of the channel lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the channel lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- enable (true) or disable (false) the mode of filling the channel 
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the channel for moving 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the channel's display to the left 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);
//--- enable (true) or disable (false) the mode of continuation of the channel's display to the right 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete the channel                                               | 
//+------------------------------------------------------------------+ 
bool StdDevChannelDelete(const long   chart_ID=0,     // chart's ID 
                         const string name="Channel") // channel name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete the channel 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete the channel! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+-------------------------------------------------------------------------+ 
//| Check the values of the channel's anchor points and set default values  | 
//| for empty ones                                                          | 
//+-------------------------------------------------------------------------+ 
void ChangeChannelEmptyPoints(datetime &time1,datetime &time2)
  {
//--- if the second point's time is not set, it will be on the current bar 
   if(!time2)
      time2=TimeCurrent();
//--- if the first point's time is not set, it is located 9 bars left from the second one 
   if(!time1)
     {
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time2,10,temp);
      //--- set the first point 9 bars left from the second one 
      time1=temp[0];
     }
  }
//+------------------------------------------------------------------+
