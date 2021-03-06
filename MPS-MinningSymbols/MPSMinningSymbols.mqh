//+------------------------------------------------------------------+
//|                                            MPSMinningSymbols.mqh |
//|                        Copyright 2018, Márcio Pulcinelli         |
//|                                http://omniavincittrading.com.br/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Márcio Pulcinelli"
#property link      "http://omniavincittrading.com.br/"
#property version   "1.00"

#include "..\Drawings\ObjectDrawings.mqh"
#include "..\Libs\Base64.mqh"

sinput string SEP0="*********************************************"; //******************* CONFIG *******************

input int Tempo=2; // TEMPO DE ATUALIZAÇÃO
input string ListaAtivos=""; // LISTA DE ATIVOS PARA EXIBIÇÃO (Sep --> ;)
input bool show_alert=false; // EXIBIR ALERTAS?
input bool save_chart_image=false; // SALVAR IMAGEM DO GRÁFICO
input bool repeat_cicle =false; // LOOP
input string ext_imagem=".gif"; // USAR EXTENSÃO ( .GIF, .PNG ou .BMP )
input color buy_line_color= clrAzure;// COR DA LINHA DE COMPRA
input color sell_line_color = clrRed;// COR DA LINHA DE VENDA
input string InpFileName="Operacoes.csv";  // ARQUIVO COM OPERACOES
input string InpDirectoryName="Data"; // DIRETÓRIO PARA SALVAR
sinput string SEP1="*********************************************"; //******************* INDICADORES *******************
input int mfi_value=14; // VALOR MFI
input int force_value=14; // VALOR FORCE INDEX
input double trigger_compra_mfi= 30; // ENTRADA MFI < x
input double trigger_saida_mfi = 70; // SAIDA MFI > x
input double trigger_compra_force=-0.001; // ENTRADA FORCE < x
input double trigger_saida_force=0.001; // SAIDA FORCE > x

sinput string SEP2="*********************************************"; //******************* DIVERGÊNCIA *******************
input int num_bars=15; // NUMERO DE BARRAS

sinput string SEP3="*********************************************"; //******************* OPERACAO *******************
input double stop_loss=0.05; // STOP LOSS (%)
input double take_profit=0.15; // TAKE PROFIT (%)
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
   long              GetListaAtivos(string &ativos[]);
   void              SetInitPosition();
   void              SetNextPosition();
   DIVERGENCIA       FindDivergences();
   void              DrawBuyLine(double &preco_entrada);
   void              DrawSellLine(double &preco_entrada);
   void              ClearBuySellLine();
   void              SaveChartToImage();
   void              SaveOperationsToFile(string simb,string operacao,double compra,double tp,double sl);
   string            ConvertImageToBase64(string fname);
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
void CMPSMinningSymbols::ClearBuySellLine()
  {
   TrendDelete(ChartID(),"TLB");
   TrendDelete(ChartID(),"TLS");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMPSMinningSymbols::DrawBuyLine(double &preco_entrada)
  {
   ClearBuySellLine();
   const int brs=Bars(_Symbol,PERIOD_CURRENT,TimeCurrent()-(PeriodSeconds(PERIOD_CURRENT)*num_bars),TimeCurrent());
   double highs[];

   CopyHigh(_Symbol,PERIOD_CURRENT,0,brs,highs);

   const int hh_pos=ArrayMaximum(highs);

   TrendCreate(ChartID(),"TLB",0,TimeCurrent()-(PeriodSeconds(PERIOD_CURRENT)*num_bars),highs[hh_pos],TimeCurrent(),highs[hh_pos],buy_line_color,STYLE_SOLID,2,false,false,false,true,true);

   ChartRedraw(ChartID());

   preco_entrada=highs[hh_pos];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMPSMinningSymbols::DrawSellLine(double &preco_entrada)
  {
   ClearBuySellLine();
   const int brs=Bars(_Symbol,PERIOD_CURRENT,TimeCurrent()-(PeriodSeconds(PERIOD_CURRENT)*num_bars),TimeCurrent());

   double lows[];

   CopyLow(_Symbol,PERIOD_CURRENT,0,brs,lows);

   const int ll_pos=ArrayMinimum(lows);

   TrendCreate(ChartID(),"TLS",0,TimeCurrent()-(PeriodSeconds(PERIOD_CURRENT)*num_bars),lows[ll_pos],TimeCurrent(),lows[ll_pos],sell_line_color,STYLE_SOLID,2,false,false,false,true,true);

   ChartRedraw(ChartID());

   preco_entrada=lows[ll_pos];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DIVERGENCIA CMPSMinningSymbols::FindDivergences()
  {

   StdDevChannelDelete(ChartID(),"CH0");
   StdDevChannelDelete(ChartID(),"CH1");

   ChartRedraw(ChartID());

   StdDevChannelCreate(ChartID(),"CH0",0,TimeCurrent()-(PeriodSeconds(PERIOD_CURRENT)*num_bars),TimeCurrent(),1,clrLightBlue,STYLE_DASH,1,false,true,false,false,false,false);
   StdDevChannelCreate(ChartID(),"CH1",1,TimeCurrent()-(PeriodSeconds(PERIOD_CURRENT)*num_bars),TimeCurrent(),1,clrLightBlue,STYLE_DASH,1,false,true,false,false,false,false);

   Print(PeriodSeconds(PERIOD_CURRENT), " ", num_bars);

   Sleep(500);

   ChartRedraw(ChartID());
   const double chart_1 = ObjectGetDouble(ChartID(),"CH0",OBJPROP_PRICE,0);
   const double chart_2 = ObjectGetDouble(ChartID(),"CH0",OBJPROP_PRICE,1);

   const double ind_1 = ObjectGetDouble(ChartID(),"CH1",OBJPROP_PRICE,0);
   const double ind_2 = ObjectGetDouble(ChartID(),"CH1",OBJPROP_PRICE,1);

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
long CMPSMinningSymbols::GetListaAtivos(string &ativos[])
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

   return ArraySize(ativos);
  }
//+------------------------------------------------------------------+
//| Este método tem o objetivo de exibir os resultados 
//| dos critérios aplicados.
//+------------------------------------------------------------------+
void CMPSMinningSymbols::ImprimeOperacao()
  {
   double mfi_curr_val=0.0;
   double force_curr_val=0.0;
   double preco_entrada = 0.0;
   string tipo_operacao= "FORA";
   const OPERACAO force=GetForce(_Symbol,force_curr_val);
   const OPERACAO mfi=GetMFI(_Symbol,mfi_curr_val);
   const DIVERGENCIA diver=FindDivergences();

   if(mfi==COMPRA && force==COMPRA)
     {
      if(show_alert)
         Alert(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[COMPRA] - DIVERG = ",EnumToString(diver));

      Print(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[COMPRA] - DIVERG = ",EnumToString(diver));

      DrawBuyLine(preco_entrada);

      tipo_operacao="COMPRAR";

      SaveOperationsToFile(_Symbol,tipo_operacao,preco_entrada,preco_entrada+preco_entrada*take_profit,preco_entrada-preco_entrada*stop_loss);
     }
   else if(mfi==VENDA && force==VENDA)
     {
      if(show_alert)
         Alert(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[VENDA] - DIVERG = ",EnumToString(diver));

      Print(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[VENDA] - DIVERG = ",EnumToString(diver));

      DrawSellLine(preco_entrada);

      tipo_operacao="VENDER";

      SaveOperationsToFile(_Symbol,tipo_operacao,preco_entrada,preco_entrada-preco_entrada*take_profit,preco_entrada+preco_entrada*stop_loss);
     }
   else if(diver==DIVERGENCIA_ALTA)
     {
      if(show_alert)
         Alert(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[COMPRA] - DIVERG = ",EnumToString(diver));

      DrawBuyLine(preco_entrada);

      Print(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[COMPRA] - DIVERG = ",EnumToString(diver));
      tipo_operacao="COMPRAR";

      SaveOperationsToFile(_Symbol,tipo_operacao,preco_entrada,preco_entrada+preco_entrada*take_profit,preco_entrada-preco_entrada*stop_loss);
     }
   else if(diver==DIVERGENCIA_BAIXA)
     {
      if(show_alert)
         Alert(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[VENDA] - DIVERG = ",EnumToString(diver));

      DrawSellLine(preco_entrada);

      Print(_Symbol," MFI[",mfi_curr_val,"]:FORCE[",force_curr_val,"]:OP[VENDA] - DIVERG = ",EnumToString(diver));
      tipo_operacao="VENDER";

      SaveOperationsToFile(_Symbol,tipo_operacao,preco_entrada,preco_entrada-preco_entrada*take_profit,preco_entrada+preco_entrada*stop_loss);
     }
   else
     {
      ClearBuySellLine();
     }

   string latv[];
   long qtd=GetListaAtivos(latv);

   Comment("\nATIVO [ ",_Symbol," ] ",symb_position," / ",qtd-1,"\n\n - MFI [",mfi_curr_val,"]\n - FORCE [",force_curr_val,"]\n - DIVERG = ",EnumToString(diver),"\n - OPERAÇÃO = ",tipo_operacao);

   SaveChartToImage();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMPSMinningSymbols::SaveOperationsToFile(string simb,string operacao,double compra,double tp,double sl)
  {
   const int file_handle=FileOpen(InpDirectoryName+"//"+InpFileName,FILE_READ|FILE_WRITE|FILE_CSV);
   FileSeek(file_handle,0,SEEK_END);

   string cp=DoubleToString(compra,2);
   StringReplace(cp,".",",");

   string stp=DoubleToString(tp,2);
   StringReplace(stp,".",",");

   string ssl=DoubleToString(sl,2);
   StringReplace(ssl,".",",");

   FileWrite(file_handle,
             simb,
             operacao,
             cp,
             stp,
             ssl);

   FileFlush(file_handle);
   FileClose(file_handle);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMPSMinningSymbols::SaveChartToImage()
  {
   if(save_chart_image)
     {
      const int height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
      const int width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);

      MqlDateTime str1;
      TimeToStruct(TimeCurrent(),str1);
      const string fname=_Symbol+"-"+IntegerToString(str1.year,4,'0')+IntegerToString(str1.mon,2,'0')+IntegerToString(str1.day,2,'0')+ext_imagem;
      ChartScreenShot(ChartID(),fname,width,height,ALIGN_RIGHT);
     }
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
      if(!repeat_cicle) return;

      SetInitPosition();
     }
   else
     {
      SetNextPosition();
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
//|                                                                  |
//+------------------------------------------------------------------+
void CMPSMinningSymbols::SetNextPosition()
  {
   symb_position+=1;
  }
//+------------------------------------------------------------------+

string CMPSMinningSymbols::ConvertImageToBase64(string fname)
  {

   ResetLastError();
   
   char binArray[];
   
   //string filename=terminal_data_path+"\\MQL5\\Files\\XPCM11-20180912.gif";
   string filename="09-03-2017 00-07-56.png";

   int handle=FileOpen(filename,FILE_BIN|FILE_READ|FILE_WRITE);
   
   FileReadArray(handle,binArray,0,WHOLE_ARRAY);
   
string img="";

   for(int i=0;i < (ArraySize(binArray)-1);i++)
     {
      img+=CharToString(binArray[i]);
      StringAdd(img,CharToString(binArray[i]));
     }

   Print(img);
   string strFileB64;


Print(GetLastError());
   
   
   FileFlush(handle);
   Print("handle  ", handle);
   FileClose(handle);


   
  Base64Encode(img, strFileB64); 

   return strFileB64;
  }
//+------------------------------------------------------------------+
