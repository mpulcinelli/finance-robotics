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
   const int brs=Bars(_Symbol,PERIOD_CURRENT,TimeCurrent()-(86400*num_bars),TimeCurrent());
   double highs[];

   CopyHigh(_Symbol,PERIOD_CURRENT,0,brs,highs);

   const int hh_pos=ArrayMaximum(highs);

   TrendCreate(ChartID(),"TLB",0,TimeCurrent()-(86400*num_bars),highs[hh_pos],TimeCurrent(),highs[hh_pos],buy_line_color,STYLE_SOLID,2,false,false,false,true,true);

   ChartRedraw(ChartID());

   preco_entrada=highs[hh_pos];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMPSMinningSymbols::DrawSellLine(double &preco_entrada)
  {
   ClearBuySellLine();
   const int brs=Bars(_Symbol,PERIOD_CURRENT,TimeCurrent()-(86400*num_bars),TimeCurrent());

   double lows[];

   CopyLow(_Symbol,PERIOD_CURRENT,0,brs,lows);

   const int ll_pos=ArrayMinimum(lows);

   TrendCreate(ChartID(),"TLS",0,TimeCurrent()-(86400*num_bars),lows[ll_pos],TimeCurrent(),lows[ll_pos],sell_line_color,STYLE_SOLID,2,false,false,false,true,true);

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

   StdDevChannelCreate(ChartID(),"CH0",0,TimeCurrent()-(86400*num_bars),TimeCurrent(),1,clrLightBlue,STYLE_DASH,1,false,true,false,false,false,false);
   StdDevChannelCreate(ChartID(),"CH1",1,TimeCurrent()-(86400*num_bars),TimeCurrent(),1,clrLightBlue,STYLE_DASH,1,false,true,false,false,false,false);

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
   
      string img = ConvertImageToBase64(fname);

   const int file_handle=FileOpen(InpDirectoryName+"//dados.txt",FILE_READ|FILE_WRITE|FILE_CSV);
   FileWrite(file_handle, img);

   FileFlush(file_handle);
   FileClose(file_handle);



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
   const int handle=FileOpen(fname,FILE_BIN|FILE_READ|FILE_WRITE);

   char binArray[];
   FileReadArray(handle,binArray,0,WHOLE_ARRAY);
  // const string strFile = CharArrayToString(binArray);
   string strFileB64;
   string apnd;
   
   StringAdd(apnd, CharArrayToString(binArray));
   
      Base64Encode(apnd, strFileB64); 
      
      FileClose(handle);
      
   return strFileB64;
}
//+------------------------------------------------------------------+
bool PostToNewsFeed(string filename,string filetype)
  {
   int    res;     // To receive the operation execution result
   char   data[];  // Data array to send POST requests
   char   file[];  // Read the image here

//--- A file is available, try to read it
   if(filename!=NULL && filename!="")
     {
      res=FileOpen(filename,FILE_READ|FILE_BIN);
      if(res<0)
        {
         Print("Error opening the file \""+filename+"\"");
         return(false);
        }
      //--- Reading file data
      if(FileReadArray(res,file)!=FileSize(res))
        {
         FileClose(res);
         Print("Error reading the file \""+filename+"\"");
         return(false);
        }
      //---
      FileClose(res);
     }
//--- Creating the body of the POST request for authorization
   ArrayResize(data,StringToCharArray(str,data,0,WHOLE_ARRAY,CP_UTF8)-1);
//--- Resetting error code
   ResetLastError();
//--- Authorization request
   res=WebRequest("POST","https://www.mql5.com/ru/auth_login",NULL,0,data,data,str);
//--- If authorization failed
   if(res!=200)
     {
      Print("Authorization error #"+(string)res+", LastError="+(string)GetLastError());
      return(false);
     }
//--- Reading the authorization cookie from the server response header
   res=StringFind(str,"Set-Cookie: auth=");
//--- If cookie not found, return an error
   if(res<0)
     {
      Print("Error, authorization data not found in the server response (check login/password)");
      return(false);
     }
//--- Remember the authorization data and form the header for further requests
   auth=StringSubstr(str,res+12);
   auth="Cookie: "+StringSubstr(auth,0,StringFind(auth,";")+1)+"\r\n";
//--- If there is a data file, send it to the server
   if(ArraySize(file)!=0)
     {
      //--- Forming the request body
      str="--"+sep+"\r\n";
      str+="Content-Disposition: form-data; name=\"attachedFile_imagesLoader\"; filename=\""+filename+"\"\r\n";
      str+="Content-Type: "+filetype+"\r\n\r\n";
      res =StringToCharArray(str,data);
      res+=ArrayCopy(data,file,res-1,0);
      res+=StringToCharArray("\r\n--"+sep+"--\r\n",data,res-1);
      ArrayResize(data,ArraySize(data)-1);
      //--- Forming the request header
      str=auth+"Content-Type: multipart/form-data; boundary="+sep+"\r\n";
      //--- Resetting error code
      ResetLastError();
      //--- Request to send an image file to the server
      res=WebRequest("POST","https://www.mql5.com/upload_file",str,0,data,data,str);
      //--- Checking the request result
      if(res!=200)
        {
         Print("Error sending a file to the server #"+(string)res+", LastError="+(string)GetLastError());
         return(false);
        }
      //--- Receiving a link to the image uploaded to the server
      str=CharArrayToString(data);
      if(StringFind(str,"{\"Url\":\"")==0)
        {
         res     =StringFind(str,"\"",8);
         filename=StringSubstr(str,8,res-8);
         //--- If file uploading fails, an empty link will be returned
         if(filename=="")
           {
            Print("File sending to server failed");
            return(false);
           }
        }
     }
//--- Create the body of a request to post an image on the server
   str ="--"+sep+"\r\n";
   str+="Content-Disposition: form-data; name=\"content\"\r\n\r\n";
   str+=text+"\r\n";
//--- The languages in which the post will be available on mql5.com  
   str+="--"+sep+"\r\n";
   str+="Content-Disposition: form-data; name=\"AllLanguages\"\r\n\r\n";
   str+="on\r\n";
//--- If the picture has been uploaded on the server, pass its link
   if(ArraySize(file)!=0)
     {
      str+="--"+sep+"\r\n";
      str+="Content-Disposition: form-data; name=\"attachedImage_0\"\r\n\r\n";
      str+=filename+"\r\n";
     }
//--- The final string of the multipart request
   str+="--"+sep+"--\r\n";
//--- Out the body of the POST request together in one string 
   StringToCharArray(str,data,0,WHOLE_ARRAY,CP_UTF8);
   ArrayResize(data,ArraySize(data)-1);
//--- Prepare the request header   
   str=auth+"Content-Type: multipart/form-data; boundary="+sep+"\r\n";
//--- Request to post a message on the user wall at mql5.com
   res=WebRequest("POST","https://www.mql5.com/ru/users/"+InpLogin+"/wall",str,0,data,data,str);
//--- Return true for successful execution
   return(res==200);
  }