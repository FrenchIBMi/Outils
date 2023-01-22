**free

// UDTF : liste des applications DCM ET des certificats associés
// Possibilité de filtrer par type d'application (serveur ou client)
// et par la présence ou l'absence de certificat


// A améliorer :
// ********************************************************
// - gestion du tableau : passer en dynamique ?
// - gestion des CCSID des ID et magasins de certificat


// Compilation :
// CRTRPGMOD MODULE(NB/LSTDCMAPP) SRCFILE(NB/QRPGLESRC)
//           OPTION(*EVENTF)
// Liage
// CRTPGM PGM(NB/LSTDCMAPP) MODULE(NB/LSTDCMAPP)
//        BNDSRVPGM((QICSS/QYCDCUSG *DEFER)) ACTGRP(*CALLER)
//

// API QycdRetrieveCertUsageInfo
// https://www.ibm.com/docs/api/v1/content/ssw_ibm_i_75/apis/qycdrcui.htm#HDRRCUINF1


// Prototype
dcl-ds ERRC0100_t template qualified ;
  BytPrv int(10)   inz( %Size( ERRC0100_t )) ;
  BytAvl int(10)   inz ;
  MsgId  char(7)   inz ;
  *n     char(1)       ;
  MsgDta char(512) inz ;
end-ds ;

dcl-ds AppSelCrit_t qualified ;
  NumberOfSelectionCriteria   int(10)  inz(0) ;
//  dcl-ds Criteria ;
//    SizeOfCriteriaEntry       int(10)  inz(%size(SizeOfCriteriaEntry)) ;
//    ComparisonOperator        int(10)  inz ;
//    ApplicationControlKey     int(10)  inz ;
//    LengthOfComparisonData    int(10)  inz ;
//    ComparisonData            chatr(1) inz ;
//  end-ds ;
end-ds;


dcl-ds RCUI0200_t qualified ;
  BytesReturned                            int(10) inz ;
  BytesAvailable                           int(10) inz(%size(RCUI0200_t)) ;
  OffsetToFirstApplicationEntry            int(10) inz ;
  NumberOfApplicationEntriesReturned       int(10) inz ;
  data                                     char(50000) inz(x'00');
end-ds ;

dcl-ds RCUI0200_entry_t qualified ;
  DisplacementToNextApplicationEntry             int(10) inz ;
  ApplicationID                                  char(100) ;
  ExitProgramName                                char(10) ;
  ExitProgramLibraryName                         char(10) ;
  Threadsafe                                     char(1) ;
  QMLTTHDACNSystemValueUsage                     char(1) ;
  MultithreadedJobAction                         char(1) ;
  ApplicationDescriptionIndicator                char(1) ;
  ApplicationDescriptionMessageFileName          char(10) ;
  ApplicationDescriptionMessageFileLibraryName   char(10) ;
  ApplicationDescriptionMessageID                char(7) ;
  ApplicationTextDescription                     char(50) ;
  LimitCACertificatesTrustedIndicator            char(1) ;
  CertificateAssignedIndicator                   char(1) ;
  CertificateIDType                              char(1) ;
  CertificateIDConvertedIndicator                char(1) ;
  CertificateStoreConvertedIndicator             char(1) ;
  NumberOfCertificates                           int(5) ;
  DisplacementToCertificateID                    int(10) ;
  LengthOfCertificateID                          int(10) ;
  CCSIDOfCertificateID                           int(10) ;
  DisplacementToCertificateStore                 int(10) ;
  LengthOfCertificateStore                       int(10) ;
  CCSIDOfCertificateStore                        int(10) ;
  ApplicationType                                char(1) ;
  ApplicationUserProfile                         char(10) ;
  *n                                             char(1) ;
  ClientAuthenticationRequired                   char(1) ;
  PerformCRLProcessing                           char(1) ;
  ApplicationDescriptionMessageText              char(330) ;
  data                                           char(500) ;
  // certificate ID
  // certificate store
end-ds ;

dcl-pr QycdRetrieveCertUsageInfo extproc('QycdRetrieveCertUsageInfo') ;
  ReceiverVariable              likeds(RCUI0200_t) ;
  LengthOfReceiverVariable      int(10)               const ;
  FormatName                    char(8)               const ;
  ApplicationSelectionCriteria  likeds(AppSelCrit_t)  const ;
  ErrorCode                     likeDs(ERRC0100_t) ;
end-pr ;


dcl-s  result_set_out        uns(5) ;
dcl-s  result_set_len        uns(5) ;
dcl-ds result_set qualified dim(500) ;
  ApplicationID                                  varchar(100) ;
  ExitProgramName                                char(10) ;
  ExitProgramLibraryName                         char(10) ;
  Threadsafe                                     char(1) ;
  QMLTTHDACNSystemValueUsage                     char(1) ;
  MultithreadedJobAction                         char(1) ;
  ApplicationDescriptionIndicator                char(1) ;
  ApplicationDescriptionMessageFileName          char(10) ;
  ApplicationDescriptionMessageFileLibraryName   char(10) ;
  ApplicationDescriptionMessageID                char(7) ;
  ApplicationTextDescription                     varchar(50) ;
  LimitCACertificatesTrustedIndicator            char(1) ;
  CertificateAssignedIndicator                   char(1) ;
  ApplicationType                                varchar(7) ;
  ApplicationUserProfile                         varchar(10) ;
  ClientAuthenticationRequired                   char(1) ;
  PerformCRLProcessing                           char(1) ;
  ApplicationDescriptionMessageText              varchar(330) ;
  CertificateID_Label                            varchar(100) ;
  Certificate_Store                              varchar(100) ;
end-ds ;


// Type d'appel
dcl-c CALL_OPEN          -1 ;
dcl-c CALL_FETCH          0 ;
dcl-c CALL_CLOSE          1 ;
// Nullité des paramètres
dcl-c PARM_NULL          -1 ;
dcl-c PARM_NOT_NULL       0 ;
// Code état SQL
dcl-c SQL_STATE_EOF  '02000' ;
// Sélection des applications :
dcl-c APPLICATION_ALL     '*ALL' ;
dcl-c APPLICATION_WITH    '*WITH' ;
dcl-c APPLICATION_WITHOUT '*WITHOUT' ;
dcl-c APPLICATION_TYPE_ALL     '*ALL' ;
dcl-c APPLICATION_TYPE_SERVER  '*SERVER' ;
dcl-c APPLICATION_TYPE_CLIENT  '*CLIENT' ;


// Paramètres
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
dcl-pi *n ;
  // Paramètres en entrée définis dans CREATE FUNCTION
  i_ApplicationCertificate                           varchar(8) const ;
  i_ApplicationType                                  varchar(10) const ;
  // Paramètres en sortie définis dans CREATE FUNCTION
  o_ApplicationID                                    varchar(100) ;
  o_ExitProgramName                                  char(10) ;
  o_ExitProgramLibraryName                           char(10) ;
  o_Threadsafe                                       char(1) ;
  o_QMLTTHDACNSystemValueUsage                       char(1) ;
  o_MultithreadedJobAction                           char(1) ;
  o_ApplicationDescriptionIndicator                  char(1) ;
  o_ApplicationDescriptionMessageFileName            char(10) ;
  o_ApplicationDescriptionMessageFileLibraryName     char(10) ;
  o_ApplicationDescriptionMessageID                  char(7) ;
  o_ApplicationTextDescription                       varchar(50) ;
  o_LimitCACertificatesTrustedIndicator              char(1) ;
  o_CertificateAssignedIndicator                     char(1) ;
  o_ApplicationType                                  varchar(11) ;
  o_ApplicationUserProfile                           char(10) ;
  o_ClientAuthenticationRequired                     char(1) ;
  o_PerformCRLProcessing                             char(1) ;
  o_ApplicationDescriptionMessageText                varchar(330) ;
  o_CertificateID_Label                              varchar(100) ;
  o_Certificate_Store                                varchar(100) ;
  // Indicateurs de valeur nulle entrée
  i_ApplicationCertificate_i                         int(5) const ;
  i_ApplicationType_i                                int(5) const ;
  // Indicateurs de valeur nulle sortie
  o_ApplicationID_i                                  int(5);
  o_ExitProgramName_i                                int(5);
  o_ExitProgramLibraryName_i                         int(5);
  o_Threadsafe_i                                     int(5);
  o_QMLTTHDACNSystemValueUsage_i                     int(5);
  o_MultithreadedJobAction_i                         int(5);
  o_ApplicationDescriptionIndicator_i                int(5);
  o_ApplicationDescriptionMessageFileName_i          int(5);
  o_ApplicationDescriptionMessageFileLibraryName_i   int(5);
  o_ApplicationDescriptionMessageID_i                int(5);
  o_ApplicationTextDescription_i                     int(5);
  o_LimitCACertificatesTrustedIndicator_i            int(5);
  o_CertificateAssignedIndicator_i                   int(5);
  o_ApplicationType_i                                int(5);
  o_ApplicationUserProfile_i                         int(5);
  o_ClientAuthenticationRequired_i                   int(5);
  o_PerformCRLProcessing_i                           int(5);
  o_ApplicationDescriptionMessageText_i              int(5);
  o_CertificateID_Label_i                            int(5);
  o_Certificate_Store_i                              int(5);
  // paramètres standards (STYLE SQL)
  state char(5) ;
  qualified_function varchar(517) ;
  function_name varchar(128) ;
  message varchar(1000) ;
  call_type int(10) ;
end-pi ;




// Exécution
select ;
when call_type = CALL_OPEN ;
  doOpen() ;
when call_type = CALL_FETCH ;
  doFetch() ;
when call_type = CALL_CLOSE ;
  doClose() ;
endsl ;


return ;




// Open : appel de l'API
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
dcl-proc doOpen ;

// variables locales
dcl-s  nbAppli  int(10) inz ;
dcl-s  nbcertif int(10) inz ;

dcl-s  CertificateID_entry varchar(500:2) based(pcertificateID_entry);
dcl-s  pCertificateID_entry pointer ;

dcl-ds rcvVar        likeds(RCUI0200_t) inz(*likeds) ;
dcl-s  rcvVar_length int(10)    inz(%size(rcvVar))  ;
dcl-ds crit          likeds(AppSelCrit_t) inz(*likeds) ;
dcl-ds error         likeds(ERRC0100_t) inz(*likeds) ;
dcl-ds entry likeds(RCUI0200_entry_t) based( pEntry ) ;
dcl-s  pEntry pointer ;


  // Contrôle des paramètres en entrée
  if i_ApplicationCertificate_i = PARM_NULL or
     i_ApplicationType_i = PARM_NULL ;
    state = '38999' ;
    message = 'Valeur nulle non supportée pour APPLICATION_CERTIFICATE et APPLICATION_TYPE ' ;
    return ;
  endif ;


  if i_ApplicationCertificate <> APPLICATION_ALL and
     i_ApplicationCertificate <> APPLICATION_WITH and
     i_ApplicationCertificate <> APPLICATION_WITHOUT ;
    state = '38999' ;
    message = 'La valeur de APPLICATION_CERTIFICATE doit être *ALL, *WITH ou *WITHOUT' ;
    return ;
  endif ;
  if i_ApplicationType <> APPLICATION_TYPE_ALL and
     i_ApplicationType <> APPLICATION_TYPE_CLIENT and
     i_ApplicationType <> APPLICATION_TYPE_SERVER  ;
    state = '38999' ;
    message = 'La valeur de APPLICATION_TYPE doit être *ALL, *CLIENT ou *SERVER' ;
    return ;
  endif ;

  // Traitement
  QycdRetrieveCertUsageInfo( rcvVar :
                             rcvVar_length :
                             'RCUI0200' :
                             crit :
                             error) ;

  // Erreur à l'appel de l'API
  if error.BytAvl > 0 ;
    state = '38999' ;
    message = 'Erreur lors de l''appel de l''API QycdRetrieveCertUsageInfo : ' + error.MsgId ;
    return ;
  endif ;

  // Aucune données en retour
  if rcvVar.bytesReturned = 0 or rcvVar.NumberOfApplicationEntriesReturned = 0 ;
    state = '38998' ;
    message = 'Aucun résultat trouvé' ;
    return ;
  endif ;

  // On calcul, on stocke !
  clear result_set ;
  result_set_len = 0 ;

  pEntry = %addr( rcvVar ) + rcvVar.OffsetToFirstApplicationEntry ;
  // Parcours des applications
  for nbAppli = 1 to rcvVar.NumberOfApplicationEntriesReturned ;

    // Application en cours
    result_set_len += 1 ;
    eval-corr result_set( result_set_len ) = entry ;

    // Certificate assigned indicator => 0 => aucun certif, 1 => oui
    if entry.CertificateAssignedIndicator = '1' ;

      result_set(result_set_len).Certificate_store =
         %str(pEntry + entry.DisplacementToCertificateStore) ;

      if entry.CertificateIDType = '1' ;
         result_set( result_set_len ).CertificateID_Label =
            %str(pEntry + entry.DisplacementToCertificateID) ;
      endif ;

      if entry.CertificateIDType = '2' ;
        pCertificateID_entry = pEntry + entry.DisplacementToCertificateID ;
        for nbcertif = 1 to entry.NumberOfCertificates ;
          result_set( result_set_len ).CertificateID_Label = CertificateID_entry ;
          // Si certificat à suivre : on prépare un poste
          if nbcertif + 1 <= entry.NumberOfCertificates ;
            result_set_len += 1 ;
            result_set( result_set_len ) = result_set( result_set_len - 1 ) ;
          endif ;
          pCertificateID_entry += ( %len(CertificateID_entry) + 2 ) ;
        endfor ;
      endif ;

    endif ;

    // Déplacement appli suivantes :
    pEntry += entry.DisplacementToNextApplicationEntry ;

endfor ;

end-proc ;



// Fetch : Parcours du résultat
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
dcl-proc doFetch ;

// Ne retourner que si correspond à la sélection
dcl-s l_OK ind inz(*off) ;

  // Alimentation paramètres en sortie
  result_set_out += 1 ;

  dow not l_OK and
      result_set_out <= result_set_len ;
    // Le poste correspond-il à la sélection ?
    l_OK = (i_ApplicationCertificate = APPLICATION_ALL
            or
            i_ApplicationCertificate = APPLICATION_WITH and
               result_set(result_set_out).CertificateID_Label <> ''
            or
            i_ApplicationCertificate = APPLICATION_WITHOUT and
               result_set(result_set_out).CertificateID_Label = '')
           and
           (i_ApplicationType = APPLICATION_TYPE_ALL
            or
            i_ApplicationType = APPLICATION_TYPE_CLIENT and
              result_set(result_set_out).ApplicationType = '2'
            or
            i_ApplicationType = APPLICATION_TYPE_SERVER and
              result_set(result_set_out).ApplicationType = '1') ;
    // Sélection valide : sortir de boucle
    if not l_OK ;
      result_set_out += 1 ;
    endif ;
  enddo ;

  // Si plus aucune sélection
  if not l_OK and
     result_set_out >= result_set_len ;
    state = SQL_STATE_EOF ;  // EOF
    return ;
  endif ;

  // Sinon on prend l'enreg
  o_ApplicationID = %trim(result_set( result_set_out ).ApplicationID) ;
  o_ApplicationID_i = PARM_NOT_NULL ;
  o_ExitProgramName = %trim(result_set( result_set_out ).ExitProgramName ) ;
  o_ExitProgramName_i = PARM_NOT_NULL ;
  o_ExitProgramLibraryName = %trim(result_set( result_set_out ).ExitProgramLibraryName ) ;
  o_ExitProgramLibraryName_i = PARM_NOT_NULL ;
  o_Threadsafe = %trim(result_set( result_set_out ).Threadsafe ) ;
  o_Threadsafe_i = PARM_NOT_NULL ;
  o_QMLTTHDACNSystemValueUsage = %trim(result_set( result_set_out ).QMLTTHDACNSystemValueUsage ) ;
  o_QMLTTHDACNSystemValueUsage_i = PARM_NOT_NULL ;
  o_MultithreadedJobAction = %trim(result_set( result_set_out ).MultithreadedJobAction ) ;
  o_MultithreadedJobAction_i = PARM_NOT_NULL ;
  o_ApplicationDescriptionIndicator =
        %trim(result_set( result_set_out ).ApplicationDescriptionIndicator ) ;
  o_ApplicationDescriptionIndicator_i = PARM_NOT_NULL ;
  o_ApplicationDescriptionMessageFileName =
        %trim(result_set( result_set_out ).ApplicationDescriptionMessageFileName ) ;
  o_ApplicationDescriptionMessageFileName_i = PARM_NOT_NULL ;
  o_ApplicationDescriptionMessageFileLibraryName =
        %trim(result_set( result_set_out ).ApplicationDescriptionMessageFileLibraryName ) ;
  o_ApplicationDescriptionMessageFileLibraryName_i = PARM_NOT_NULL ;
  o_ApplicationDescriptionMessageID =
      %trim(result_set( result_set_out ).ApplicationDescriptionMessageID ) ;
  o_ApplicationDescriptionMessageID_i = PARM_NOT_NULL ;
  o_ApplicationTextDescription =
      %trim(result_set( result_set_out ).ApplicationTextDescription ) ;
  o_ApplicationTextDescription_i = PARM_NOT_NULL ;
  o_LimitCACertificatesTrustedIndicator =
      %trim(result_set( result_set_out ).LimitCACertificatesTrustedIndicator ) ;
  o_LimitCACertificatesTrustedIndicator_i = PARM_NOT_NULL ;
  o_CertificateAssignedIndicator =
      %trim(result_set( result_set_out ).CertificateAssignedIndicator ) ;
  o_CertificateAssignedIndicator_i = PARM_NOT_NULL ;
  select ;
    when result_set( result_set_out ).ApplicationType = '1' ;
      o_ApplicationType = '*SERVER' ;
    when result_set( result_set_out ).ApplicationType = '2' ;
      o_ApplicationType = '*CLIENT' ;
    when result_set( result_set_out ).ApplicationType = '4' ;
      o_ApplicationType = '*OBJSIGNING' ;
  endsl ;
  o_ApplicationType_i = PARM_NOT_NULL ;
  o_ApplicationUserProfile =
      %trim(result_set( result_set_out ).ApplicationUserProfile ) ;
  o_ApplicationUserProfile_i = PARM_NOT_NULL ;
  o_ClientAuthenticationRequired =
      %trim(result_set( result_set_out ).ClientAuthenticationRequired ) ;
  o_ClientAuthenticationRequired_i = PARM_NOT_NULL ;
  o_PerformCRLProcessing = %trim(result_set( result_set_out ).PerformCRLProcessing ) ;
  o_PerformCRLProcessing_i = PARM_NOT_NULL ;
  o_ApplicationDescriptionMessageText =
      %trim(result_set( result_set_out ).ApplicationDescriptionMessageText ) ;
  o_ApplicationDescriptionMessageText_i = PARM_NOT_NULL ;
  o_CertificateID_Label = %trim(result_set( result_set_out ).CertificateID_Label) ;
  if o_CertificateID_Label <> '' ;
    o_CertificateID_Label_i = PARM_NOT_NULL ;
  else ;
    o_CertificateID_Label_i = PARM_NULL ;
  endif ;
  o_Certificate_Store = %trim(result_set( result_set_out ).Certificate_Store) ;
  o_Certificate_Store_i = o_CertificateID_Label_i ;

end-proc ;



// Close : nettoyage
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
dcl-proc doClose ;

  result_set_out = 0 ;
  result_set_len = 0 ;
  return ;

end-proc ;
