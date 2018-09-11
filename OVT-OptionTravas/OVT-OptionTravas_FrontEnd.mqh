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

   CEdit             m_edit;                          // the display field object
   CButton           m_button1;                       // the button object
   CButton           m_button2;                       // the button object
   CButton           m_button3;                       // the fixed button object
   CSpinEdit         m_spin_edit;                     // the up-down object
   CDatePicker       m_date;                          // the datepicker object
   CListView         m_list_view;                     // the list object
   CComboBox         m_combo_box;                     // the dropdown list object
   CRadioGroup       m_radio_group;                   // the radio buttons group object
   CCheckGroup       m_check_group;                   // the check box group object



public:
                     OVTOptionTravasFrontEnd();
                    ~OVTOptionTravasFrontEnd();
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

protected:
   //--- create dependent controls
   bool              CreateEdit(void);
   bool              CreateButton1(void);
   bool              CreateButton2(void);
   bool              CreateButton3(void);
   bool              CreateSpinEdit(void);
   bool              CreateDate(void);
   bool              CreateListView(void);
   bool              CreateComboBox(void);
   bool              CreateRadioGroup(void);
   bool              CreateCheckGroup(void);
   //--- handlers of the dependent controls events
   void              OnClickButton1(void);
   void              OnClickButton2(void);
   void              OnClickButton3(void);
   void              OnChangeSpinEdit(void);
   void              OnChangeDate(void);
   void              OnChangeListView(void);
   void              OnChangeComboBox(void);
   void              OnChangeRadioGroup(void);
   void              OnChangeCheckGroup(void);

  };
  
EVENT_MAP_BEGIN(OVTOptionTravasFrontEnd)
   ON_EVENT(ON_CLICK,m_button1,OnClickButton1)
   ON_EVENT(ON_CLICK,m_button2,OnClickButton2)
   ON_EVENT(ON_CLICK,m_button3,OnClickButton3)
   ON_EVENT(ON_CHANGE,m_spin_edit,OnChangeSpinEdit)
   ON_EVENT(ON_CHANGE,m_date,OnChangeDate)
   ON_EVENT(ON_CHANGE,m_list_view,OnChangeListView)
   ON_EVENT(ON_CHANGE,m_combo_box,OnChangeComboBox)
   ON_EVENT(ON_CHANGE,m_radio_group,OnChangeRadioGroup)
   ON_EVENT(ON_CHANGE,m_check_group,OnChangeCheckGroup)
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
   if(!CreateEdit())
      return(false);
   if(!CreateButton1())
      return(false);
/*   if(!CreateButton2())
      return(false);
   if(!CreateButton3())
      return(false);
   if(!CreateSpinEdit())
      return(false);
   if(!CreateListView())
      return(false);
   if(!CreateDate())
      return(false);
   if(!CreateRadioGroup())
      return(false);
   if(!CreateCheckGroup())
      return(false);
   if(!CreateComboBox())
      return(false);*/
//--- succeed
   return(true);
  }
  
   void OVTOptionTravasFrontEnd::OnClickButton1(void){}
   void OVTOptionTravasFrontEnd::OnClickButton2(void){}
   void OVTOptionTravasFrontEnd::OnClickButton3(void){}
   void OVTOptionTravasFrontEnd::OnChangeSpinEdit(void){}
   void OVTOptionTravasFrontEnd::OnChangeDate(void){}
   void OVTOptionTravasFrontEnd::OnChangeListView(void){}
   void OVTOptionTravasFrontEnd::OnChangeComboBox(void){}
   void OVTOptionTravasFrontEnd::OnChangeRadioGroup(void){}
   void OVTOptionTravasFrontEnd::OnChangeCheckGroup(void){} 
   
bool OVTOptionTravasFrontEnd::CreateEdit(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=ClientAreaWidth()-INDENT_RIGHT;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_edit.Create(m_chart_id,m_name+"Edit",m_subwin,x1,y1,x2,y2))
      return(false);
   //if(!m_edit.ReadOnly(false))
      //return(false);
   if(!Add(m_edit))
      return(false);
//--- succeed
   return(true);
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