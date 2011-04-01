//+------------------------------------------------------------------+
//|                                                      csqlite.mqh |
//|                                                            Graff |
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
int sqlite3_open16(string filename,/* Database filename (UTF-8) */
                   int &db_h       /* OUT: SQLite db handle */
                   );
int sqlite3_finalize(int h);
int sqlite3_close(int h);

int sqlite3_prepare(
                    int h,/* Database handle */
                    uchar &zSql[],/* SQL statement, UTF-8 encoded */
                    int nByte,/* Maximum length of zSql in bytes. */
                    int &ppStmt,/* OUT: Statement handle */
                    uchar &pzTail[]/* OUT: Pointer to unused portion of zSql */
                    );
int sqlite3_exec(
                 int h,/* An open database */
                 uchar &SqlQ[],/* SQL to be evaluated */
                 int callback,/* Callback function */
                 string s,/* 1st argument to callback */
                 string error                              /* Error msg written here UCHAR */
                 );
int sqlite3_column_count(int stmt_h);

int sqlite3_step(int stmt_h);

string sqlite3_column_text16(int stmt_h,int iCol);

string sqlite3_errmsg16(int h); // error message

int sqlite3_next_stmt(int h,int stmt_h); // 2nd param can be NULL

#import
//+------------------------------------------------------------------+
//|  Main class
//+------------------------------------------------------------------+
class CSQLite
  {
public:
   bool              connect(string db_file);
   bool              exec(string query);
   void             ~CSQLite(); // деструктор
                                //private:
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
//|   Destuctor
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
