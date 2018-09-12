//+------------------------------------------------------------------+
//|                                    OVT-OptionTravas_FrontEnd.mqh |
//|                             Copyright 2018, OmniaVincit Trading. |
//|                                   https://www.omniavincit.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, OmniaVincit Trading."
#property link      "https://www.omniavincit.com.br"
#property version   "1.00"

#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\DatePicker.mqh>
#include <Controls\ListView.mqh>
#include <Controls\ComboBox.mqh>
#include <Controls\SpinEdit.mqh>
#include <Controls\RadioGroup.mqh>
#include <Controls\CheckGroup.mqh>

//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (100)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//--- for the indication area
#define EDIT_HEIGHT                         (40)      // size by Y coordinate
//--- for group controls
#define GROUP_WIDTH                         (150)     // size by X coordinate
#define LIST_HEIGHT                         (179)     // size by Y coordinate
#define RADIO_HEIGHT                        (56)      // size by Y coordinate
#define CHECK_HEIGHT                        (93)      // size by Y coordinate



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OVTOptionTravasFrontEnd : public CAppDialog
  {
private:

   CButton           m_button1;                       // the button object
   CListView         m_list_view_opc_1;                     // the list object
   CListView         m_list_view_opc_2;                     // the list object
   CComboBox         m_combo_box_ativo;                     // the dropdown list object



public:
                     OVTOptionTravasFrontEnd();
                    ~OVTOptionTravasFrontEnd();
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

protected:
   //--- create dependent controls
   bool              CreateButton1(void);
   bool              CreateListViewOpc1(void);
   bool              CreateListViewOpc2(void);
   bool              CreateComboBox(void);
   //--- handlers of the dependent controls events
   void              OnClickButton1(void);
   void              OnChangeListViewOpc1(void);
   void              OnChangeListViewOpc2(void);
   void              OnChangeComboBox(void);

   bool              LoadListOp1_Items(string itm);

  };
  
EVENT_MAP_BEGIN(OVTOptionTravasFrontEnd)
   ON_EVENT(ON_CLICK,m_button1,OnClickButton1)
   ON_EVENT(ON_CHANGE,m_list_view_opc_1,OnChangeListViewOpc1)
   ON_EVENT(ON_CHANGE,m_list_view_opc_2,OnChangeListViewOpc2)
   ON_EVENT(ON_CHANGE,m_combo_box_ativo,OnChangeComboBox)
EVENT_MAP_END(CAppDialog)  
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
OVTOptionTravasFrontEnd::OVTOptionTravasFrontEnd()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
OVTOptionTravasFrontEnd::~OVTOptionTravasFrontEnd()
  {
  }
//+------------------------------------------------------------------+
bool OVTOptionTravasFrontEnd::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//--- create dependent controls
   if(!CreateButton1())
      return(false);
   if(!CreateListViewOpc1())
      return(false);      
      
      
/*   if(!CreateButton2())
      return(false);
   if(!CreateButton3())
      return(false);
   if(!CreateSpinEdit())
      return(false);

   if(!CreateDate())
      return(false);
   if(!CreateRadioGroup())
      return(false);
   if(!CreateCheckGroup())
      return(false);*/
   if(!CreateComboBox())
      return(false);
//--- succeed
   return(true);
  }
  
   void OVTOptionTravasFrontEnd::OnClickButton1(void){}
   void OVTOptionTravasFrontEnd::OnChangeListViewOpc1(void){}
   void OVTOptionTravasFrontEnd::OnChangeListViewOpc2(void){}

   void OVTOptionTravasFrontEnd::OnChangeComboBox(void)
   {
      Print("Combo selecionada");
   }
   

bool OVTOptionTravasFrontEnd::CreateButton1(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(EDIT_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button1.Create(m_chart_id,m_name+"Button1",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button1.Text("Button1"))
      return(false);
   if(!Add(m_button1))
      return(false);
//--- succeed
   return(true);
  }
  
bool OVTOptionTravasFrontEnd::CreateComboBox(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(EDIT_HEIGHT+CONTROLS_GAP_Y)+
          (BUTTON_HEIGHT+CONTROLS_GAP_Y)+
          (EDIT_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+GROUP_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_combo_box_ativo.Create(m_chart_id,m_name+"ComboBox",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_combo_box_ativo))
      return(false);
   m_combo_box_ativo.ItemAdd("PETR");
   m_combo_box_ativo.ItemAdd("VALE");
//--- succeed
   return(true);
  }
  
bool OVTOptionTravasFrontEnd::CreateListViewOpc1(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+GROUP_WIDTH+2*CONTROLS_GAP_X;
   int y1=INDENT_TOP+(EDIT_HEIGHT+CONTROLS_GAP_Y)+
          (BUTTON_HEIGHT+CONTROLS_GAP_Y)+
          (EDIT_HEIGHT+2*CONTROLS_GAP_Y);
   int x2=x1+GROUP_WIDTH;
   int y2=y1+LIST_HEIGHT-CONTROLS_GAP_Y;
//--- create
   if(!m_list_view_opc_1.Create(m_chart_id,m_name+"ListView",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_list_view_opc_1))
      return(false);
//--- fill out with strings
  // for(int i=0;i<16;i++)
     // if(!m_list_view_opc_1.AddItem("Item "+IntegerToString(i)))
     //    return(false);
//--- succeed
   return(true);
  }  
  
  
  bool OVTOptionTravasFrontEnd::LoadListOp1_Items(string itm)
  {
      if(!m_list_view_opc_1.ItemAdd(itm))
         return(false);
      
      return(true);
  }
    