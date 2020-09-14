     H nomain decedit('0,') datedit(*dmy/) bnddir('CILBND': 'QSNAPI')
     F********************************************************************************************************
     F* C. I. L.
     F* Retourne les informations d'un répertoire IFS via SQL
     F*
     F* !!! Attention !!! 
     F* Modifier les bibliothèques en fonction de votre environnement
     F* ------------------------------------------------------------------------------------------------------
     F*
     F* CRTRPGMOD MODULE(xxx/CIRTVDIR) SRCFILE(xxx/QRPGLESRC) SRCMBR(CIRTVDIR)
     F*      DBGVIEW(*SOURCE) TGTRLS(*PRV)
     F* CRTSRVPGM SRVPGM(xxx/CIRTVDIR) EXPORT(*ALL) replace(*yes)
     F*     MODULE(*SRVPGM) USRPRF(*OWNER) tgtrls(*PRV)
     F*     TEXT('Retourne les informations d''un répertoire IFS')
     F*
 
       // create function xxx/CIRTVDIR (Dir varchar(256))
       //    returns table (
       //      File    varchar(256),
       //      Size    integer,
       //      AccessTime timestamp,
       //      ModifyTime timestamp,
       //      StatusTime timestamp,
       //      NbrLinks   integer,
       //      CCSID      integer,
       //      CodePage   integer,
       //      ObjType    char(11) )
       // external name 'xxx/CIRTVDIR(RTVDIR)'
       // language rpgle
       // parameter style db2sql
       // no sql
       // not deterministic
       // disallow parallel

       // Utilisation :
       // select * from table(CIRTVDIR('/tmp')) as t;



     D Name_type       s            256a   varying template

     D g_UTC_Offset    s             10i 0

      /COPY xxx/QRPGLESRC,CIFSIO_H // HEADER API IFS

     D DirHandle       s               *

     D DirEntPtr       s               *
     D entry           ds                  likeds(dirent)
     D                                     based(DirEntPtr)

     D StmfInfo        ds                  likeds(statds)

     P CIRTVDIR        b                   export
     D                 pi
     D  inDirName                          const like(Name_type)
     D  ouFileName                               like(Name_type)
     D  ouSize                       10i 0
     D  ouLastAccess                   z
     D  ouLastMod                      z
     D  ouLastStatus                   z
     D  ouNbrLinks                   10i 0
     D  ouCCSID                      10i 0
     D  ouCodePage                   10i 0
     D  ouObjType                    11a

     D  NullDirName                   5i 0         const
     D  NullFileName                  5i 0
     D  NullSize                      5i 0
     D  NullLastAccess...
     D                                5i 0
     D  NullLastMod...
     D                                5i 0
     D  NullLastStatus...
     D                                5i 0
     D  NullNbrLinks...
     D                                5i 0
     D  NullCCSID                     5i 0
     D  NullCodePage                  5i 0
     D  NullObjType                   5i 0

     D  ouSqlState                    5a
     D  xxFunction                  517a   varying const
     D  xxSpecific                  128a   varying const
     D  ouErrorMessage...
     D                               70a   varying
     D  inCallType                   10i 0         const

     D Op_Open         c                   -1
     D Op_Fetch        c                    0
     D Op_Close        c                    1

     D NullValue       c                   -1
     D NonNullValue    c                    0

     D FileStatus      s             10i 0

     D FullFileName    s            256a   varying

      /free
        monitor;
           ouSqlState = '00000';
           select;
              when inCallType = Op_Open;
                 DirHandle = opendir(%trim(inDirName)+x'00');
                 if (DirHandle <> *NULL);
                    Get_UTC_Offset ();
                 else;
                    ouSqlState = '03001';
                    ouErrorMessage = 'Directory was not found.';
                 endif;
              when inCallType = Op_Fetch;
                 NullFileName   = NonNullValue;
                 NullSize       = NonNullValue;
                 NullLastAccess = NonNullValue;
                 NullLastMod    = NonNullValue;
                 NullLastStatus = NonNullValue;
                 NullNbrLinks   = NonNullValue;
                 NullCCSID      = NonNullValue;
                 NullCodePage   = NonNullValue;
                 NullObjType    = NonNullValue;

                 DirEntPtr = readdir(DirHandle);
                 if DirEntPtr <> *NULL;
                    ouFileName = %subst(entry.d_name: 1: entry.d_namelen);
                    FullFileName = %trim(inDirName) + '/' + ouFileName;
                    FileStatus = stat (FullFileName: StmfInfo);
                    if FileStatus >= *zero;
                       ouLastAccess = ToTime (StmfInfo.st_atime);
                       ouLastMod    = ToTime (StmfInfo.st_mtime);
                       ouLastStatus = ToTime (StmfInfo.st_ctime);
                       ouNbrLinks   = StmfInfo.st_nlink;
                       ouCCSID      = StmfInfo.st_ccsid;
                       ouCodePage   = StmfInfo.st_codepage;
                       ouObjType    = StmfInfo.st_objtype;
                    else;
                       NullLastAccess = NullValue;
                       NullLastMod    = NullValue;
                       NullLastStatus = NullValue;
                       NullNbrLinks   = NullValue;
                       NullCCSID      = NullValue;
                       NullCodePage   = NullValue;
                       NullObjType    = NullValue;
                    endif;
                    ouSize = StmfInfo.st_size;
                 else;
                    ouSqlState = '02000';
                 endif;
              when inCallType = Op_Close;
                 CloseDir (DirHandle);
                 *inlr = *on;
           endsl;
        on-error;
           ouSqlState = '03002';
        endmon;
       return;
      /end-free
     P                 e
      * ===============================================================
     P ToTime          b
     D                 pi              z
     D  inSeconds                    10i 0 value
      *** locals
     D Epoch           s               z   inz(z'1970-01-01-00.00.00')
      /free
          return Epoch + %seconds(inSeconds) + %seconds(g_UTC_Offset);
      /end-free
     P                 e
      * ==============================================================
     P Get_UTC_Offset  b
     D                 pi

     D CEEUTCO         pr                  extproc('CEEUTCO')
     D   Hours                       10i 0
     D   Minutes                     10i 0
     D   Seconds                      8f
     D   FC                          12a   options(*omit)

     D UTC_Hours       s             10i 0
     D UTC_Minutes     s             10i 0
     D UTC_Seconds     s              8f

      /free
          CEEUTCO (UTC_Hours: UTC_Minutes: UTC_Seconds: *omit);
          g_UTC_Offset = %int(UTC_Seconds);
      /end-free
     P                 e 
