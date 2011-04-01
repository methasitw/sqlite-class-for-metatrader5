//+------------------------------------------------------------------+
//|                                                  sqlite_test.mq5 |
//|                                                            Graff |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Graff"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#include <csqlite.mqh>

CSQLite db;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   Comment("");
   db.connect("test2.db");
   uchar q[];
   uchar out[];
   db.exec("create table if not exists test (name text,value text); insert into test (name,value) values ('test1','test1'); insert into test (name,value) values ('test2','test2'); insert into test (name,value) values ('test3','test3');");
/**/
   u2a("select * from test",q);
   if(sqlite3_prepare(db.db_hwd,q,ArraySize(q),db.db_stmt_h,out)!=SQLITE_OK) Print("DB stmt failure.");
   string r="";
   int i=0;
   while(sqlite3_step(db.db_stmt_h)==SQLITE_ROW)
     {
      i++;
      r+=sqlite3_column_text16(db.db_stmt_h,0)+","+sqlite3_column_text16(db.db_stmt_h,1)+"\n";
     }
   Comment(r);

//---
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  Comment("");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
int u2a(string txt,uchar &out[])
  {
  return(StringToCharArray(txt,out));
  }
//+------------------------------------------------------------------+
