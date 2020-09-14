     F********************************************************************************************************
     F* Header API IFS                                                                     
     F*-------------------------------------------------------------------------------------------------------
     D fd              S             10I 0
     D flags           S             10U 0
     D mode            S             10U 0
     D CRLF            C                   const(x'0d25')                       Retour chariot + Fin de ligne 
     D CR              C                   const(x'0d')                         Retour chariot  
     D LF              C                   const(x'25')                         Fin de ligne
     D TAB             C                   const(x'05')                         Tabulation Horizontale
     D**********************************************************************
     D*  Flags for use in open()
     D*
     D* More than one can be used -- add them together.
     D**********************************************************************
     D*                                            Reading Only
     D O_RDONLY        C                   1
     D*                                            Writing Only
     D O_WRONLY        C                   2
     D*                                            Reading & Writing
     D O_RDWR          C                   4
     D*                                            Create File if not exist
     D O_CREAT         C                   8
     D*                                            Exclusively create
     D O_EXCL          C                   16
     D*                                            Assign a CCSID
     D O_CCSID         C                   32
     D*                                            Truncate File to 0 bytes
     D O_TRUNC         C                   64
     D*                                            Append to File
     D O_APPEND        C                   256
     D*                                            Synchronous write
     D O_SYNC          C                   1024
     D*                                            Sync write, data only
     D O_DSYNC         C                   2048
     D*                                            Sync read
     D O_RSYNC         C                   4096
     D*                                            No controlling terminal
     D O_NOCTTY        C                   32768
     D*                                            Share with readers only
     D O_SHARE_RDONLY  C                   65536
     D*                                            Share with writers only
     D O_SHARE_WRONLY  C                   131072
     D*                                            Share with read & write
     D O_SHARE_RDWR    C                   262144
     D*                                            Share with nobody.
     D O_SHARE_NONE    C                   524288
     D*                                            Assign a code page
     D O_CODEPAGE      C                   8388608
     D*                                            Open in text-mode
     D O_TEXTDATA      C                   16777216
     D*                                            Allow text translation
     D*                                            on newly created file.
     D* Note: O_TEXT_CREAT requires all of the following flags to work:
     D*           O_CREAT+O_TEXTDATA+(O_CODEPAGE or O_CCSID)
     D O_TEXT_CREAT    C                   33554432
     D*                                            Inherit mode from dir
     D O_INHERITMODE   C                   134217728
     D*                                            Large file access
     D*                                            (for >2GB files)
     D O_LARGEFILE     C                   536870912
     D**********************************************************************
     D*      Mode Flags.
     D*         basically, the mode parm of open(), creat(), chmod(),etc
     D*         uses 9 least significant bits to determine the
     D*         file's mode. (peoples access rights to the file)
     D*
     D*           user:       owner    group    other
     D*           access:     R W X    R W X    R W X
     D*           bit:        8 7 6    5 4 3    2 1 0
     D*
     D* (This is accomplished by adding the flags below to get the mode)
     D**********************************************************************
     D*                                         owner authority
     D S_IRUSR         C                   256
     D S_IWUSR         C                   128
     D S_IXUSR         C                   64
     D S_IRWXU         C                   448
     D*                                         group authority
     D S_IRGRP         C                   32
     D S_IWGRP         C                   16
     D S_IXGRP         C                   8
     D S_IRWXG         C                   56
     D*                                         other people
     D S_IROTH         C                   4
     D S_IWOTH         C                   2
     D S_IXOTH         C                   1
     D S_IRWXO         C                   7
     D*---------------------------------------------------------------------
     D* open() -- Open File
     D*
     D* int open(const char *path, int oflag, . . .);
     D*
     D*     path = path name of file to open
     D*    oflag = open flags
     D*     mode = file mode, aka permissions.  (Reqd with O_CREAT flag)
     D* codepage = code page to assign to file  (Reqd with O_CODEPAGE flag)
     D*
     D* Returns the file descriptor of the opened file
     D*         or -1 if an error occurred
     D*---------------------------------------------------------------------
     D open            PR            10I 0 extproc('open')
     D   path                          *   value options(*string)
     D   oflag                       10I 0 value
     D   mode                        10U 0 value options(*nopass)
     D   codepage                    10U 0 value options(*nopass)
     D*---------------------------------------------------------------------
     D* write() -- Write to stream file
     D*
     D* int write(int fildes, const void *buf, size_t nbyte);
     D*
     D*   fildes = file descriptor to write to
     D*      buf = pointer to data to be written
     D*    nbyte = number of bytes to write
     D*
     D* Returns the number of bytes written
     D*         or a -1 if an error occurred
     D*---------------------------------------------------------------------
     D write           PR            10I 0 extproc('write')
     D   fildes                      10I 0 value
     D   buf                           *   value
     D   nbyte                       10U 0 value
     D*---------------------------------------------------------------------
     D* read() -- Read from stream file
     D*
     D* int read(int fildes, void *buf, size_t nbyte);
     D*
     D*   fildes = file descriptor to read from
     D*      buf = pointer to memory to read into
     D*    nbyte = maximum number of bytes to read
     D*
     D* Returns the number of bytes read
     D*         or a -1 if an error occurred
     D*---------------------------------------------------------------------
     D read            PR            10I 0 extproc('read')
     D   fildes                      10I 0 value
     D   buf                           *   value
     D   nbyte                       10U 0 value
     D*---------------------------------------------------------------------
     D* close() -- Close file descriptor
     D*
     D* int close(int fildes);
     D*
     D*   fildes = file descriptor to close
     D*
     D* Returns 0 if successful
     D*         or a -1 if an error occurred
     D*---------------------------------------------------------------------
     D/if not defined(CLOSE_PROTOTYPE)
     D close           PR            10I 0 extproc('close')
     D   fildes                      10I 0 value
     D/define CLOSE_PROTOTYPE
     D/endif
     D**********************************************************************
     D* Access mode flags for access()
     D*
     D*   F_OK = File Exists
     D*   R_OK = Read Access
     D*   W_OK = Write Access
     D*   X_OK = Execute or Search
     D**********************************************************************
     D F_OK            C                   0
     D R_OK            C                   4
     D W_OK            C                   2
     D X_OK            C                   1
     D*--------------------------------------------------------------------
     D* Determine file accessibility
     D*
     D* int access(const char *path, int amode)
     D*
     D*--------------------------------------------------------------------
     D access          PR            10I 0 ExtProc('access')
     D   Path                          *   Value Options(*string)
     D   amode                       10I 0 Value
     D*--------------------------------------------------------------------
     D* Change file permissions
     D*
     D* int chmod(const char *path, mode_t mode)
     D*--------------------------------------------------------------------
     D chmod           PR            10I 0 ExtProc('chmod')
     D   path                          *   Value options(*string)
     D   mode                        10U 0 Value
     D*--------------------------------------------------------------------
     D* Rename a file or directory.
     D*
     D* int rename(const char *old, const char *new);
     D*--------------------------------------------------------------------
     D rename          PR            10I 0 ExtProc('Qp0lRenameKeep')
     D   old                           *   Value options(*string)
     D   new                           *   Value options(*string)
     D*--------------------------------------------------------------------
     D* Remove Link to File.  (deletes 1 reference to a file.  If this
     D*   is the last reference, the file itself is deleted.  See
     D*   Chapter 3 for more info)
     D*
     D* int unlink(const char *path)
     D*--------------------------------------------------------------------
     D unlink          PR            10I 0 ExtProc('unlink')
     D   path                          *   Value options(*string)
      **********************************************************************
      * File Information Structure, Large File Enabled (stat64)
      *   struct stat64 {                                                    */
      *     mode_t         st_mode;       /* File mode                       */
      *     ino_t          st_ino;        /* File serial number              */
      *     uid_t          st_uid;        /* User ID of the owner of file    */
      *     gid_t          st_gid;        /* Group ID of the group of fileA2A*/
      *     off64_t        st_size;       /* For regular files, the file     */
      *                                      size in bytes                   */
      *     time_t         st_atime;      /* Time of last access             */
      *     time_t         st_mtime;      /* Time of last data modification2A*/
      *     time_t         st_ctime;      /* Time of last file status changeA*/
      *     dev_t          st_dev;        /* ID of device containing file    */
      *     size_t         st_blksize;    /* Size of a block of the file     */
      *     nlink_t        st_nlink;      /* Number of links                 */
      *     unsigned short st_codepage;   /* Object data codepage            */
      *     unsigned long long st_allocsize; /* Allocation size of the file2A*/
      *     unsigned int   st_ino_gen_id; /* File serial number generationAid*/
      *                                                                      */
      *     qp0l_objtype_t st_objtype;    /* AS/400 object type              */
      *     char           st_reserved2[5]; /* Reserved                  @B4A*/
      *     dev_t          st_rdev;       /* Device ID (if character specialA*/
      *                                   /* or block special file)      @B4A*/
      *     dev64_t        st_rdev64;     /* Device ID - 64 bit form     @B4A*/
      *     dev64_t        st_dev64;      /* ID of device containing file@-2A*/
      *                                   /* 64 bit form.                @B4A*/
      *     nlink32_t      st_nlink32;    /* Number of links-32 bit      @B5A*/
      *     char           st_reserved1[26]; /* Reserved            @B4A @B5C*/
      *     unsigned short st_ccsid;      /* Object data ccsid           @AAA*/
      *  };                                                                  */
      *
      **********************************************************************
     D statds64        DS                  qualified
     D                                     BASED(Template)
     D  st_mode                      10U 0
     D  st_ino                       10U 0
     D  st_uid                       10U 0
     D  st_gid                       10U 0
     D  st_size                      20I 0
     D  st_atime                     10I 0
     D  st_mtime                     10I 0
     D  st_ctime                     10I 0
     D  st_dev                       10U 0
     D  st_blksize                   10U 0
     D  st_nlink                      5U 0
     D  st_codepage                   5U 0
     D  st_allocsize                 20U 0
     D  st_ino_gen_id                10U 0
     D  st_objtype                   11A
     D  st_reserved2                  5A
     D  st_rdev                      10U 0
     D  st_rdev64                    20U 0
     D  st_dev64                     20U 0
     D  st_nlink32                   10U 0
     D  st_reserved1                 26A
     D  st_ccsid                      5U 0
      **********************************************************************
      * File Information Structure (stat)
      *   struct stat {
      *     mode_t         st_mode;       /* File mode                       */
      *     ino_t          st_ino;        /* File serial number              */
      *     nlink_t        st_nlink;      /* Number of links                 */
      *     unsigned short st_reserved2;  /* Reserved                    @B4A*/
      *     uid_t          st_uid;        /* User ID of the owner of file    */
      *     gid_t          st_gid;        /* Group ID of the group of file   */
      *     off_t          st_size;       /* For regular files, the file
      *                                      size in bytes                   */
      *     time_t         st_atime;      /* Time of last access             */
      *     time_t         st_mtime;      /* Time of last data modification  */
      *     time_t         st_ctime;      /* Time of last file status change */
      *     dev_t          st_dev;        /* ID of device containing file    */
      *     size_t         st_blksize;    /* Size of a block of the file     */
      *     unsigned long  st_allocsize;  /* Allocation size of the file     */
      *     qp0l_objtype_t st_objtype;    /* AS/400 object type              */
      *     char           st_reserved3;  /* Reserved                    @B4A*/
      *     unsigned short st_codepage;   /* Object data codepage            */
      *     unsigned short st_ccsid;      /* Object data ccsid           @AAA*/
      *     dev_t          st_rdev;       /* Device ID (if character special */
      *                                   /* or block special file)      @B4A*/
      *     nlink32_t      st_nlink32;    /* Number of links-32 bit      @B5C*/
      *     dev64_t        st_rdev64;     /* Device ID - 64 bit form     @B4A*/
      *     dev64_t        st_dev64;      /* ID of device containing file -  */
      *                                   /* 64 bit form.                @B4A*/
      *     char           st_reserved1[36]; /* Reserved                 @B4A*/
      *     unsigned int   st_ino_gen_id; /* File serial number generation id
      *  };
      *                                                                  @A2A*/
      **********************************************************************
     D p_statds        S               *
     D statds          DS                  qualified
     D                                     BASED(p_statds)
     D  st_mode                      10U 0
     D  st_ino                       10U 0
     D  st_nlink                      5U 0
     D* st_pad                        2A
     D  st_reserved2                  5U 0
     D  st_uid                       10U 0
     D  st_gid                       10U 0
     D  st_size                      10I 0
     D  st_atime                     10I 0
     D  st_mtime                     10I 0
     D  st_ctime                     10I 0
     D  st_dev                       10U 0
     D  st_blksize                   10U 0
     D  st_allocsize                 10U 0
     D  st_objtype                   11A
     D  st_reserved3                  1A
     D  st_codepage                   5U 0
     D  st_ccsid                      5U 0
     D  st_rdev                      10U 0
     D  st_nlink32                   10U 0
     D  st_rdev64                    20U 0
     D  st_dev64                     20U 0
     D  st_reserved1                 36A
     D  st_ino_gen_id                10U 0
     D*--------------------------------------------------------------------
     D* Get File Information
     D*
     D* int stat(const char *path, struct stat *buf)
     D*--------------------------------------------------------------------
     D stat            PR            10I 0 ExtProc('stat')
     D   path                          *   value options(*string)
     D   buf                               likeds(statds)
      *--------------------------------------------------------------------
      * Get File Information, Large File Enabled
      *
      * int stat(const char *path, struct stat64 *buf)
      *--------------------------------------------------------------------
     D stat64          PR            10I 0 ExtProc('stat64')
     D   path                          *   value options(*string)
     D   buf                               likeds(statds64)
     D**********************************************************************
     D* "whence" constants for use with lseek()
     D**********************************************************************
     D SEEK_SET        C                   CONST(0)
     D SEEK_CUR        C                   CONST(1)
     D SEEK_END        C                   CONST(2)
     D*--------------------------------------------------------------------
     D* Set File Read/Write Offset
     D*
     D* off_t lseek(int fildes, off_t offset, int whence)
     D*--------------------------------------------------------------------
     D lseek           PR            10I 0 ExtProc('lseek')
     D   fildes                      10I 0 value
     D   offset                      10I 0 value
     D   whence                      10I 0 value
     D*--------------------------------------------------------------------
     D* Get File Information from descriptor
     D*
     D* int fstat(int fildes, struct stat *buf)
     D*--------------------------------------------------------------------
     D fstat           PR            10I 0 ExtProc('fstat')
     D   fildes                      10I 0 value
     D   buf                           *   value
     D**********************************************************************
     D*
     D* Directory Entry Structure (dirent)
     D*
     D* struct dirent {
     D*   char           d_reserved1[16];  /* Reserved                       */
     D*   unsigned int   d_reserved2;      /* Reserved                       */
     D*   ino_t          d_fileno;         /* The file number of the file    */
     D*   unsigned int   d_reclen;         /* Length of this directory entry
     D*                                     * in bytes                       */
     D*   int            d_reserved3;      /* Reserved                       */
     D*   char           d_reserved4[8];   /* Reserved                       */
     D*   qlg_nls_t      d_nlsinfo;        /* National Language Information
     D*                                     * about d_name                   */
     D*   unsigned int   d_namelen;        /* Length of the name, in bytes
     D*                                     * excluding NULL terminator      */
     D*   char           d_name[_QP0L_DIR_NAME]; /* Name...null terminated   */
     D*
     D* };
     D*
     D**********************************************************************
     D p_dirent        s               *
     D dirent          ds                  based(p_dirent)
     D   d_reserv1                   16A
     D   d_reserv2                   10U 0
     D   d_fileno                    10U 0
     D   d_reclen                    10U 0
     D   d_reserv3                   10I 0
     D   d_reserv4                    8A
     D   d_nlsinfo                   12A
     D     nls_ccsid                 10I 0 OVERLAY(d_nlsinfo:1)
     D     nls_cntry                  2A   OVERLAY(d_nlsinfo:5)
     D     nls_lang                   3A   OVERLAY(d_nlsinfo:7)
     D     nls_reserv                 3A   OVERLAY(d_nlsinfo:10)
     D   d_namelen                   10U 0
     D   d_name                     640A
     D*--------------------------------------------------------------------
     D* Make Directory
     D*
     D* int mkdir(const char *path, mode_t mode)
     D*--------------------------------------------------------------------
     D mkdir           PR            10I 0 ExtProc('mkdir')
     D   path                          *   Value options(*string)
     D   mode                        10U 0 Value
     D*--------------------------------------------------------------------
     D* Remove Directory
     D*
     D* int rmdir(const char *path)
     D*--------------------------------------------------------------------
     D rmdir           PR            10I 0 ExtProc('rmdir')
     D   path                          *   value options(*string)
     D*--------------------------------------------------------------------
     D* Change Directory
     D*
     D* int chdir(const char *path)
     D*--------------------------------------------------------------------
     D chdir           PR            10I 0 ExtProc('chdir')
     D   path                          *   Value Options(*string)
     D*--------------------------------------------------------------------
     D* Open a Directory
     D*
     D* DIR *opendir(const char *dirname)
     D*--------------------------------------------------------------------
     D opendir         PR              *   EXTPROC('opendir')
     D  dirname                        *   VALUE options(*string)
     D*--------------------------------------------------------------------
     D* Read Directory Entry
     D*
     D* struct dirent *readdir(DIR *dirp)
     D*--------------------------------------------------------------------
     D readdir         PR              *   EXTPROC('readdir')
     D  dirp                           *   VALUE
     D*--------------------------------------------------------------------
     D* Close a directory
     D*
     D* int closedir(DIR *dirp)
     D*--------------------------------------------------------------------
     D closedir        PR            10I 0 EXTPROC('closedir')
     D  dirhandle                      *   VALUE
     D*--------------------------------------------------------------------
     D* Get Current Working Directory
     D*
     D* char *getcwd(char *buf, int size);
     D*--------------------------------------------------------------------
     D getcwd          PR              *   EXTPROC('getcwd')
     D  buf                            *   VALUE
     D  size                         10I 0 VALUE
      //----------------------------------------------------------------------------------------------------- 
