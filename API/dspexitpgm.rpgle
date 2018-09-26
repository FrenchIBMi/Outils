**free

// Example d'utilisation de l'API QusRetrieveExitInformation pour lister
// l'ensemble des points d'exit enregistrés

// Compilation :
// CRTBNDRPG PGM(YOURLIB/DSPEXITPGM)
//           SRCSTMF('/home/.../dspexitpgm.rpgle')
//           DBGVIEW(*SOURCE)

ctl-opt actgrp(*new) ;

// -----------------------------------------------------------------
// Définitions pour l'API
// -----------------------------------------------------------------

// EPI Error
dcl-ds ERRC0100 qualified inz ;
  BytPrv   int(10)   inz( %Size( ERRC0100 )) ;
  BytAvl   int(10)   inz ;
  MsgId    char(7)   inz ;
  reserved char(1)   inz ;
  MsgDta   char(256) inz ;
end-ds ;

// procédure
dcl-pr QusRtvExitInfo extproc('QusRetrieveExitInformation') ;
  ContinuationHandle            char(16) const ;
  ReceiverVariable              likeds( EXTI0200 ) ;
  LengthOfReceiverVariable      int(10)  const ;
  FormatName                    char(8)  const ;
  ExitPointName                 char(20) const ;
  ExitPointFormatName           char(8)  const ;
  ExitProgramNumber             int(10)  const ;
  ExitProgramSelectionCriteria  likeds( ExitProgramSelectionCriteria ) const ;
  ErrorCode                     likeds( ERRC0100 ) ;
end-pr ;

// DS pour format EXTI0200
dcl-ds EXTI0200 qualified inz ;
  BytesReturned                        int(10) ;
  BytesAvailable                       int(10) ;
  ContinuationHandle                   char(16) ;
  OffsetToFirstExitProgramEntry        int(10) ;
  NumberOfExitProgramEntriesReturned   int(10) ;
  LengthOfExitProgramEntry             int(10) ;
  Entries                              char(65535) ;
end-ds;

// Informations pour chaque programme d'exit :
dcl-s ptrEXTI0200Info pointer inz(*null) ;
dcl-ds EXTI0200Info qualified based( ptrEXTI0200Info ) ;
  OffsetToNextExitProgramEntry int(10) ;
  ExitPointName                char(20) ;
  ExitPointFormatName          char(8) ;
  RegisteredExitPoint          char(1) ;
  CompleteEntry                char(1) ;
  Reserved                     char(2) ;
  ExitProgramNumber            int(10) ;
  ExitProgramName              char(10) ;
  ExitProgramLibraryName       char(10) ;
  ExitProgramDataCCSID         int(10) ;
  OffsetToExitProgramData      int(10) ;
  LengthOfExitProgramData      int(10) ;
  Threadsafe                   char(1) ;
  MultithreadedJobAction       char(1) ;
  QMLTTHDACNSystemValue        char(1) ;
end-ds ;

// Critères de sélection
dcl-ds ExitProgramSelectionCriteria qualified inz ;
  NumberOfSelectionCriteria         int(10) inz(0) ;
  dcl-ds criteria dim(10) inz ;
    SizeOfCriteriaEntry             int(10) ;
    ComparisonOperator              int(10) ;
    StartPositionInExitProgramData  int(10) ;
    LengthOfComparisonData          int(10) ;
    ComparisonData                  char(64) ;
  end-ds ;
end-ds;


// ----------------------------------------------------------------------------
// Variables programme
// ----------------------------------------------------------------------------
dcl-s ContinuationHandle char(16) inz ;        // pas assez de place pour tout récupèrer
dcl-s continue           ind      inz(*on) ;   // appel suivant
dcl-s i                  int(10)  inz ;        // pour parcours des résultats

// ----------------------------------------------------------------------------
// Corps du programme
// ----------------------------------------------------------------------------


affiche('Début du programme');

dow continue ;

  // Appel API
  QusRtvExitInfo( ContinuationHandle :
                  EXTI0200 :                       // ReceiverVariable
                  %size( EXTI0200 ) :              // LengthOfReceiverVariable
                  'EXTI0200' :                     // FormatName
                  '*REGISTERED' :                  // ExitPointName
                  '*ALL' :                         // ExitPointFormatName
                  -1 :                             // ExitProgramNumber (-1 = *ALL)
                  ExitProgramSelectionCriteria :   // Critères de sélection
                  ERRC0100 ) ;                     // Error Code

  // Appel OK ?
  if ERRC0100.BytAvl > 0 ;
    affiche('Erreur : ' + ERRC0100.MsgId ) ;
    return ;
  endif ;

  // positionnement sur la première entrée
  ptrEXTI0200Info = %addr( EXTI0200 ) + EXTI0200.OffsetToFirstExitProgramEntry ;
  // Lister les points d'exit et leur programme
  for i = 1 to EXTI0200.NumberOfExitProgramEntriesReturned ;

    // Extraction des infos : ici on affiche pour l'exemple
    affiche( 'N°' + %char(i) + ' ' +
             EXTI0200Info.ExitPointName + '(' +
             EXTI0200Info.ExitPointFormatName + '), ' +
             %trim(EXTI0200Info.ExitProgramLibraryName) + '/' + %trim(EXTI0200Info.ExitProgramName) ) ;

    // entrée suivante
    if i < EXTI0200.NumberOfExitProgramEntriesReturned ;
      ptrEXTI0200Info = %addr( EXTI0200 ) + EXTI0200Info.OffsetToNextExitProgramEntry ;
    endif ;

  endfor ;

  // faut-il continuer ?
  continue = ( ContinuationHandle <> *blanks ) ;

enddo ;


affiche('Fin du programme');
// ciao !
return ;



// Afficher à l'écran
// ----------------------------------
dcl-proc affiche ;
  dcl-pi *n ;
    p_msg varchar(512) const ;
  end-pi ;

  dcl-s msg char(52) ;

  msg = p_msg ;
  dsply msg ;
end-proc ;
