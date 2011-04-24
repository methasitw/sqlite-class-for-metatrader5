//+------------------------------------------------------------------+
//|                                                  sqlite_test.mq5 |
//|                                            s.cornushov aka Graff |
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

   db.connect(":memory:");
//db.connect("test.db");
   db.exec("create table if not exists test (name text,value text); insert into test (name,value) values ('test1','test1'); insert into test (name,value) values ('test2','test2'); insert into test (name,value) values ('test3','test3');");

// Testing Trasactions
   db.prepare_insert_transaction("test");

   db.reset();
   db.bind_text(1,"bind 1");
   db.bind_text(2,"bind 2");
   if(db.step()!=SQLITE_DONE) Print("INSERT ERR No= ");

   db.reset();
   db.bind_int(1,3);
   db.bind_int(2,4);
   if(db.step()!=SQLITE_DONE) Print("INSERT ERR No= ");

   db.reset();
   db.bind_double(1,5.2);
   db.bind_double(2,6.6);
   if(db.step()!=SQLITE_DONE) Print("INSERT ERR No= ");

   db.finalize();

   string r;
   sql_results rez[];

   db.get_array("select * from test",rez);
   for(int i=0;i<ArraySize(rez);i++)
     {
      for(int j=0;j<ArraySize(rez[i].value);j++)
        {
         r+=rez[i].value[j]+"|";
        }
      r+="\n";
     }
   ArrayFree(rez);
   Comment(r+"\nUsed memory: "+DoubleToString(db.memory_used(),0));
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
