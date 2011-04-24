//+------------------------------------------------------------------+
//|                                                      csqlite.mqh |
//|                                            s.cornushov aka Graff |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Graff"
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#define SQLITE_OK           0   /* Successful result */
/* beginning-of-error-codes */
#define SQLITE_ERROR        1   /* SQL error or missing database */
#define SQLITE_INTERNAL     2   /* Internal logic error in SQLite */
#define SQLITE_PERM         3   /* Access permission denied */
#define SQLITE_ABORT        4   /* Callback routine requested an abort */
#define SQLITE_BUSY         5   /* The database file is locked */
#define SQLITE_LOCKED       6   /* A table in the database is locked */
#define SQLITE_NOMEM        7   /* A malloc() failed */
#define SQLITE_READONLY     8   /* Attempt to write a readonly database */
#define SQLITE_INTERRUPT    9   /* Operation terminated by sqlite3_interrupt()*/
#define SQLITE_IOERR       10   /* Some kind of disk I/O error occurred */
#define SQLITE_CORRUPT     11   /* The database disk image is malformed */
#define SQLITE_NOTFOUND    12   /* Unknown opcode in sqlite3_file_control() */
#define SQLITE_FULL        13   /* Insertion failed because database is full */
#define SQLITE_CANTOPEN    14   /* Unable to open the database file */
#define SQLITE_PROTOCOL    15   /* Database lock protocol error */
#define SQLITE_EMPTY       16   /* Database is empty */
#define SQLITE_SCHEMA      17   /* The database schema changed */
#define SQLITE_TOOBIG      18   /* String or BLOB exceeds size limit */
#define SQLITE_CONSTRAINT  19   /* Abort due to constraint violation */
#define SQLITE_MISMATCH    20   /* Data type mismatch */
#define SQLITE_MISUSE      21   /* Library used incorrectly */
#define SQLITE_NOLFS       22   /* Uses OS features not supported on host */
#define SQLITE_AUTH        23   /* Authorization denied */
#define SQLITE_FORMAT      24   /* Auxiliary database format error */
#define SQLITE_RANGE       25   /* 2nd parameter to sqlite3_bind out of range */
#define SQLITE_NOTADB      26   /* File opened that is not a database file */
#define SQLITE_ROW         100  /* sqlite3_step() has another row ready */
#define SQLITE_DONE        101  /* sqlite3_step() has finished executing */

#define SQLITE3_STATIC     0 /*for sqlite3_bind_text16*/
#define SQLITE_TRANSIENT   -1 /*for sqlite3_bind_text16*/
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
#import "sqlite3.dll"
uint sqlite3_open16(string filename,/* Database filename (UTF-8) */
                    uint &db_h       /* OUT: SQLite db handle */
                    );
uint sqlite3_finalize(uint h);
uint sqlite3_close(uint h);

uint sqlite3_prepare16_v2(
                          uint h,/* Database handle */
                          string q,/* SQL statement, UTF-16 encoded */
                          uint nByte,/* Maximum length of zSql in bytes. */
                          uint &ppStmt,/* OUT: Statement handle */
                          string pointer/* OUT: Pointer to unused portion of zSql */
                          );

uint sqlite3_exec(
                  uint h,/* An open database */
                  uchar &SqlQ[],/* SQL to be evaluated */
                  uint callback,/* Callback function */
                  string s,/* 1st argument to callback */
                  string error                              /* Error msg written here UCHAR */
                  );
uint sqlite3_column_count(uint stmt_h);

uint sqlite3_step(uint stmt_h);

uint sqlite3_reset(uint sqlite3_stmt);

uint sqlite3_finalize(uint sqlite3_stmt);

string sqlite3_column_text16(uint stmt_h,uint iCol);

string sqlite3_errmsg16(uint h); // error message

uint sqlite3_next_stmt(uint h,uint stmt_h); /* 2nd param can be NULL*/

uint sqlite3_memory_used(void);

// Binds
int sqlite3_bind_double(uint sqlite3_stmt,uint colnum,double inp_double);
int sqlite3_bind_int(uint sqlite3_stmt,uint colnum,int inp_int);
int sqlite3_bind_text16(uint sqlite3_stmt,uint colnum,string txt,uint size_in_bytes,int param);

#import
//+------------------------------------------------------------------+
//|   struct to export sql results
//+------------------------------------------------------------------+
struct sql_results// sql results export struct
  {
   string            value[];
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSQLite
  {
public:
   bool              connect(string db_file);
   bool              exec(string query);
   string            get_cell(string query);
   uint              get_array(string query,sql_results &out[]);
   // Transactions
   bool              prepare_insert_transaction(string TableName);
   bool              begin_transaction(void) { return(exec("BEGIN;"));}
   bool              commit_transaction(void){ return(exec("COMMIT;"));}
   // Binds http://www.sqlite.org/c3ref/bind_blob.html
   bool              bind_int(uint colnum,int inp_int){return(sqlite3_bind_int(db_stmt_h,colnum,inp_int)==SQLITE_OK ? true : false);}
   bool              bind_double(uint colnum,double inp_double){return(sqlite3_bind_double(db_stmt_h,colnum,inp_double)==SQLITE_OK ? true : false);}
   bool              bind_text(uint colnum,string inp_str){return(sqlite3_bind_text16(db_stmt_h,colnum,inp_str,StringLen(inp_str)*2,SQLITE3_STATIC)==SQLITE_OK ? true : false);}

   uint              step(void){ return(sqlite3_step(db_stmt_h)); }
   bool              reset(void){ return(sqlite3_reset(db_stmt_h)==SQLITE_OK ? true : false);} /*http://www.sqlite.org/c3ref/reset.html*/
   bool              finalize(void){ return(sqlite3_finalize(db_stmt_h)==SQLITE_OK ? true : false);} /*http://www.sqlite.org/c3ref/finalize.html*/
   uint              memory_used(void) {return(sqlite3_memory_used());} /*http://www.sqlite.org/c3ref/memory_highwater.html*/
   string            error(void){return(sqlite3_errmsg16(db_hwd));}
   void             ~CSQLite(); // destructor
private:
   uchar             db_stmt[];
   int               db_stmt_h; // query handle
   string            db_host_file;
   int               u2a(string txt,uchar &out[]){ return(StringToCharArray(txt,out)); }
   bool              prepare(string query);
protected:
   int               db_hwd; // db connection handle   
  };
//+------------------------------------------------------------------+
//| SQLite connection func
//+------------------------------------------------------------------+
bool CSQLite::connect(string db_file)
  {
   if(sqlite3_open16(db_file,db_hwd)!=SQLITE_OK){ Print("SQLite init failure. Error "+error()); return(false); }
   db_host_file=db_file;
   return(true);
  }
//+------------------------------------------------------------------+
//| destructor  
//+------------------------------------------------------------------+
void CSQLite::~CSQLite()
  {
   uint stmt_h_kill;
   while(stmt_h_kill=sqlite3_next_stmt(db_hwd,NULL))
     {
      if(sqlite3_finalize(stmt_h_kill)!=SQLITE_OK) Print("SQLite finalization failure. Error "+error());
     }

   if(sqlite3_close(db_hwd)!=SQLITE_OK) Print("SQLite close failure. Error "+error());
  }
//+-----------------------------------------------------------------+
//| prepare func wrapper
//+-----------------------------------------------------------------+
bool CSQLite::prepare(string query)
  {
   if(sqlite3_prepare16_v2(db_hwd,query,StringLen(query)*2,db_stmt_h,NULL)!=SQLITE_OK || !db_stmt_h)
     {
      Print("SQLite preparation failure. Error "+error());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| SQLite one way execution function. This wont return result(s)
//+------------------------------------------------------------------+
bool CSQLite::exec(string query)
  {
   uchar q[];
   u2a(query,q);
   if(sqlite3_exec(db_hwd,q,NULL,NULL,NULL)!=SQLITE_OK){ Print("SQLite exec failure. Error "+error()); return(false); }
   ArrayFree(q);
   return(true);
  }
//+------------------------------------------------------------------+
//| SQLite prepare insert transaction
//+------------------------------------------------------------------+
bool CSQLite::prepare_insert_transaction(string TableName)
  {
//Getting column names
   string query="PRAGMA table_info('"+TableName+"');";
   sql_results columns[];
   get_array(query,columns);
//End of Getting column names
//Generating transactional insert query
   string names,vals;
   for(int i=0;i<ArraySize(columns);i++)
     {
      names+=columns[i].value[1]+",";
      vals+="?,";
     }
   string insq="INSERT INTO "+TableName+" ("+names+") VALUES ("+vals+");";
   StringReplace(insq,",)",")"); //removing last ,s
                                 //End of Generating transactional insert query 
   ArrayFree(columns);

   return(prepare(insq));
  }
//+------------------------------------------------------------------+
//| This fanction will return only the first column of the first row (A:1)
//+------------------------------------------------------------------+
string CSQLite::get_cell(string query)
  {
   prepare(query);
   if(sqlite3_column_count(db_stmt_h)>1) Print("Warning! Query returned more than one cell. Function get_cell will return only one cell.");
   if(step()!=SQLITE_ROW) {Print("Error: get_cell query didnt returned results."); sqlite3_finalize(db_stmt_h); return(NULL);}
   string r=sqlite3_column_text16(db_stmt_h,0);
   reset();
   finalize();
   return(r);
  }
//+------------------------------------------------------------------+
//| This fanction will return string array as *sql_results*
//+------------------------------------------------------------------+
uint CSQLite::get_array(string query,sql_results &out[])
  {
   prepare(query);
   uint column_count=sqlite3_column_count(db_stmt_h);
   uint i=0;
   while(step()==SQLITE_ROW)
     {
      ArrayResize(out,i+1);
      ArrayResize(out[i].value,column_count);
      for(uint j=0;j<column_count;j++)
        {
         out[i].value[j]=sqlite3_column_text16(db_stmt_h,j);
        }
      i++;
     }

   reset();
   finalize();
   return(i);
  }
//+------------------------------------------------------------------+
