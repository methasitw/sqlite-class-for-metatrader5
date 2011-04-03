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
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
#import "sqlite3.dll"
uint sqlite3_open16(string filename,/* Database filename (UTF-8) */
                    uint &db_h       /* OUT: SQLite db handle */
                    );
uint sqlite3_finalize(uint h);
uint sqlite3_close(uint h);

uint sqlite3_prepare(
                     uint h,/* Database handle */
                     uchar &zSql[],/* SQL statement, UTF-8 encoded */
                     uint nByte,/* Maximum length of zSql in bytes. */
                     uint &ppStmt,/* OUT: Statement handle */
                     uchar &pzTail[]/* OUT: Pointer to unused portion of zSql */
                     );

uint sqlite3_prepare_v2(
                        uint h,/* Database handle */
                        uchar &zSql[],/* SQL statement, UTF-8 encoded */
                        uint nByte,/* Maximum length of zSql in bytes. */
                        uint &ppStmt,/* OUT: Statement handle */
                        uchar &pzTail[]/* OUT: Pointer to unused portion of zSql */
                        );

uint sqlite3_prepare16(
                       uint h,/* Database handle */
                       string q,/* SQL statement, UTF-16 encoded */
                       uint nByte,/* Maximum length of zSql in bytes. */
                       uint &ppStmt,/* OUT: Statement handle */
                       uint pointer=0/* OUT: Pointer to unused portion of zSql */
                       );

uint sqlite3_prepare16_v2(
                          uint h,/* Database handle */
                          string q,/* SQL statement, UTF-16 encoded */
                          uint nByte,/* Maximum length of zSql in bytes. */
                          uint &ppStmt,/* OUT: Statement handle */
                          uint pointer=0/* OUT: Pointer to unused portion of zSql */
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

string sqlite3_column_text16(uint stmt_h,uint iCol);

string sqlite3_errmsg16(uint h); // error message

uint sqlite3_next_stmt(uint h,uint stmt_h); // 2nd param can be NULL

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
   //uint              get_array(string query,string &out[][1]);
   uint              get_array(string query,sql_results &out[]);
   void             ~CSQLite(); // деструктор
private:
   int               db_hwd; // db connection handle
   uchar             db_stmt[];
   int               db_stmt_h; // query handle
   string            db_host_file;
   int               u2a(string txt,uchar &out[]){ return(StringToCharArray(txt,out)); }
  };
//+------------------------------------------------------------------+
//|   SQLite connection func
//+------------------------------------------------------------------+
bool CSQLite::connect(string db_file)
  {
   if(sqlite3_open16(db_file,db_hwd)!=SQLITE_OK){ Print("SQLite init failure. Error "+sqlite3_errmsg16(db_hwd)); return(false); }
   db_host_file=db_file;
   return(true);
  }
//+------------------------------------------------------------------+
//|   деструктор  
//+------------------------------------------------------------------+
void CSQLite::~CSQLite()
  {
   uint stmt_h_kill;
   while(stmt_h_kill=sqlite3_next_stmt(db_hwd,NULL))
     {
      if(sqlite3_finalize(stmt_h_kill)!=SQLITE_OK) Print("SQLite finalization failure. Error "+sqlite3_errmsg16(db_hwd));
     }

   if(sqlite3_close(db_hwd)!=SQLITE_OK) Print("SQLite close failure. Error "+sqlite3_errmsg16(db_hwd));
  }
//+------------------------------------------------------------------+
//|   SQLite one way execution function. This wont return result(s)
//+------------------------------------------------------------------+
bool CSQLite::exec(string query)
  {
   uchar q[];
   u2a(query,q);
   if(sqlite3_exec(db_hwd,q,NULL,NULL,NULL)!=SQLITE_OK){ Print("SQLite exec failure. Error "+sqlite3_errmsg16(db_hwd)); return(false); }
   ArrayFree(q);
   return(true);
  }
//+------------------------------------------------------------------+
//|   This fanction will return only the first column of the first row (A:1)
//+------------------------------------------------------------------+
string CSQLite::get_cell(string query)
  {
   uchar out[];
   uchar q[];
   u2a(query,q);
   if(sqlite3_prepare_v2(db_hwd,q,ArraySize(q),db_stmt_h,out)!=SQLITE_OK) Print("SQLite prepare failure. Error "+sqlite3_errmsg16(db_hwd));
   ArrayFree(q); ArrayFree(out);
   if(sqlite3_column_count(db_stmt_h)>1) Print("Warning! Query returned more than one cell. Function get_cell will return only one cell.");
   if(sqlite3_step(db_stmt_h)!=SQLITE_ROW) {Print("Error: get_cell query didnt returned results."); sqlite3_finalize(db_stmt_h); return(NULL);}
   string r=sqlite3_column_text16(db_stmt_h,0);
   sqlite3_finalize(db_stmt_h);
   return(r);
  }
//+------------------------------------------------------------------+
//|   This fanction will return only the first column of the first row (A:1)
//+------------------------------------------------------------------+
//uint CSQLite::get_array(string query,string &out[][1])
uint CSQLite::get_array(string query,sql_results &out[])
  {
   uchar prep_out[];
   uchar q[];
   u2a(query,q);
   if(sqlite3_prepare_v2(db_hwd,q,ArraySize(q),db_stmt_h,prep_out)!=SQLITE_OK) Print("SQLite prepare failure. Error "+sqlite3_errmsg16(db_hwd));
   ArrayFree(q); ArrayFree(prep_out);
   uint column_count=sqlite3_column_count(db_stmt_h);
   uint i=0;
   while(sqlite3_step(db_stmt_h)==SQLITE_ROW)
     {
      ArrayResize(out,i+1);
      ArrayResize(out[i].value,column_count);
      for(uint j=0;j<column_count;j++)
        {
         out[i].value[j]=sqlite3_column_text16(db_stmt_h,j);
        }
      i++;
     }
/*while(sqlite3_step(db_stmt_h)==SQLITE_ROW)
     {
      ArrayResize(out,((i+1)*(column_count+1))*2);
      for(uint j=0;j<column_count;j++)
        {
         //ArrayResize(out,ArraySize(out)+2);
         Comment(i+" "+j+" ArSize "+ArraySize(out));
         out[i][j]=sqlite3_column_text16(db_stmt_h,j);

        }

      i++;
     }*/
   sqlite3_finalize(db_stmt_h);
   return(i);
  }
//+------------------------------------------------------------------+
