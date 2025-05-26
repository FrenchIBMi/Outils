**free

// Compilation / liage :
// CRTRPGMOD MODULE(NB/VLDLUDTF) SRCFILE(NB/QRPGLESRC) 
//           OPTION(*EVENTF) DBGVIEW(*SOURCE)
// CRTSRVPGM SRVPGM(NB/VLDLUDTF) EXPORT(*ALL) ACTGRP(*CALLER)

// Implémentation de la fonction UDTF VALIDATION_LIST_ENTRIES
// Liste les entrées d'une liste de validation
// Utilise l'API QsyFindFirstValidationLstEntry et QsyFindNextValidationLstEntry

// @todo :
// - ajouter le support de la conversion de CCSID
// - améliorer la gestion des erreurs


ctl-opt nomain option(*srcstmt : *nodebugio) ;


// Déclarations pour APIs : QsyFindFirstValidationLstEntry et QsyFindNextValidationLstEntry

dcl-ds Qsy_Qual_Name_T qualified template ;
  name char(10) inz ;
  lib  char(10) inz ;
end-ds ;

dcl-ds Qsy_Entry_ID_Info_T qualified template ;
  Entry_ID_Len int(10) inz ;
  Entry_ID_CCSID uns(10) inz ;
  Entry_ID    char(100) inz ;
end-ds ;

dcl-ds Qsy_Rtn_Vld_Lst_Ent_T qualified template ;
  dcl-ds Entry_ID_Info likeds( Qsy_Entry_ID_Info_T) inz ;

  dcl-ds Encr_Data_Info ;
    Encr_Data_len   int(10) inz;
    Encr_Data_CCSID uns(10) inz;
    Encr_Data       char(600) inz ;
  end-ds ;

  dcl-ds Entry_Data_Info  ;
    Entry_Data_len   int(10) ;
    Entry_Data_CCSID uns(10) ;
    Entry_Data       char(1000) ;
  end-ds ;

  Reserved          char(4) inz ;
  Entry_More_Info   char(100) inz ;
end-ds ;

dcl-pr QsyFindFirstValidationLstEntry int(10) extproc('QsyFindFirstValidationLstEntry');
  vldList       likeds(Qsy_Qual_Name_T) const ;
  vldListEntry  likeds(Qsy_Rtn_Vld_Lst_Ent_T) ;
end-pr ;

dcl-pr QsyFindNextValidationLstEntry int(10) extproc('QsyFindNextValidationLstEntry');
  vldList       likeds(Qsy_Qual_Name_T) const ;
  entryIdInfo   likeds(Qsy_Entry_ID_Info_T)   ;
  vldListEntry  likeds(Qsy_Rtn_Vld_Lst_Ent_T) ;
end-pr ;

// Retrouver le code erreur de l'API
dcl-pr getErrNo int(10) ;
end-pr ;
// Code erreur
dcl-c EACCES   3401 ;
dcl-c EAGAIN   3406 ;
dcl-c EDAMAGE  3484 ;
dcl-c EINVAL   3021 ;
dcl-c ENOENT   3025 ;
dcl-c ENOREC   3026 ;
dcl-c EUNKNOWN 3474 ;

// Retrouver le libellé du code erreur
dcl-pr strError pointer extproc(*CWIDEN : 'strerror') ;
  errNo int(10) value ;
end-pr ;

// gestion UDTF
dcl-c CALL_OPEN     -1;
dcl-c CALL_FETCH     0;
dcl-c CALL_CLOSE     1;
dcl-c PARM_NULL     -1;
dcl-c PARM_NOTNULL   0;


// Liste les entrées de la liste de validation
// ==========================================================================
dcl-proc vldl_list export ;

// Déclarations globales
  dcl-s  ret int(10) inz ;
  dcl-s  errno int(10) inz ;
  dcl-ds vldListEntry likeds(Qsy_Rtn_Vld_Lst_Ent_T) inz static ;
  dcl-ds vldlname  likeds(Qsy_Qual_Name_T) inz          static ;
  dcl-s  first ind inz(*on)                             static ;


  dcl-pi *n ;
    // input parms
    pvldl_lib  varchar(10) const ;
    pvldl_name varchar(10) const ;
    // output columns
    pEntry_ID    varchar(100) ;
    pEntry_Data  varchar(1000) ;
    // null indicators
    pvldl_lib_n    int(5) const ;
    pvldl_name_n   int(5) const ;
    pEntry_ID_n    int(5)       ;
    pEntry_Data_n  int(5)       ;
    // db2sql
    pstate    char(5);
    pFunction varchar(517) const;
    pSpecific varchar(128) const;
    perrorMsg varchar(1000);
    pCallType int(10) const;
  end-pi ;


// Paramètres en entrée
  if pvldl_name_n = PARM_NULL or pvldl_lib_n = PARM_NULL;
    pstate = '38999' ;
    perrorMsg = 'VALIDATION_LIST_LIBRARY ou VALIDATION_LIST_NAME est null' ;
    return ;
  endif ;

  select;
    when ( pCallType = CALL_OPEN );
    // appel initial : initialisation des variables statiques
      vldlname.name = pvldl_name ;
      vldlname.Lib  = pvldl_lib ;
      clear vldListEntry ;
      first = *on ;

    when ( pCallType = CALL_FETCH );
    // retrouver l'entrée suivante
      exsr doFetch ;

    when ( pCallType = CALL_CLOSE );
    // rien à faire

  endsl;


  // traitement de l'entrée suivante
  begsr doFetch ;
    if first ;
      ret = QsyFindFirstValidationLstEntry( vldlname : vldListEntry);
      first = *off ;
    else ;
      ret = QsyFindNextValidationLstEntry( vldlname :
                                           vldListEntry.Entry_ID_Info : vldListEntry);
    endif ;

    if ret = 0 ;
      // Entrée trouvée
      monitor ;
        pEntry_ID   = %left(vldListEntry.Entry_ID_Info.Entry_ID :
                          vldListEntry.Entry_ID_Info.Entry_ID_Len);
        pEntry_Data = %left(vldListEntry.Entry_Data_Info.Entry_Data :
                          vldListEntry.Entry_Data_Info.Entry_Data_len) ;
        pEntry_ID_n   = PARM_NOTNULL ;
        pEntry_Data_n = PARM_NOTNULL ;
      on-error ;
        // Erreur de conversion
        pstate = '38999' ;
        perrorMsg = 'Erreur de conversion' ;
      endmon ;
    else ;
      // Entrée non trouvée : erreur ou fin de lecture
      errno = getErrNo() ;
      select ;
        when errno in %list( ENOENT : ENOREC ) ; // fin de lecture
          pstate = '02000' ;
          return ;
        other ; // Erreur
          pstate = '38999' ;
          perrorMsg = %str(strError(errno)) ;
      endsl ;
    endif ;
  endsr ;

end-proc ;



// Retrouver le code erreur de l'API
dcl-proc getErrNo ;

  dcl-pr getErrNoPtr pointer ExtProc('__errno') ;
  end-pr ;

  dcl-pi *n int(10) ;
  end-pi;

  dcl-s errNo int(10) based(errNoPtr) ;

  errNoPtr = getErrNoPtr() ;
  return errNo ;

end-proc;
