**free

// crtbnddir nb/ssl
// ADDBNDDIRE BNDDIR(NB/SSL) OBJ((QICSS/QYCUCERTI))

ctl-opt actgrp(*new) bnddir('NB/SSL');

//------------------------------------------------------------------------
// Lister les certificats serveur ou CA d'un magasin qui expirent dans XX jours
//------------------------------------------------------------------------

// API
//------------------------------------------------------------------------

// API Error
dcl-ds ERRC0100_t template qualified ;
  BytPrv int(10)   inz( %Size( ERRC0100_t )) ;
  BytAvl int(10)   inz ;
  MsgId  char(7)   inz ;
  *n     char(1)       ;
  MsgDta char(512) iNZ ;
end-ds ;

// Send Program Message
dcl-pr QMHSNDPM extpgm('QMHSNDPM');
  MsgID              char(7)      const;
  MsgFile            char(20)     const;
  MsgDta             char(32767)  const   options(*varsize);
  MsgDtaLen          int(10)      const;
  MsgType            char(10)     const;
  MsgQ               char(10)     const;
  MsgQNbr            int(10)      const;
  MsgKey             char(4);
  ErrorDs            likeds(ERRC0100_t);
end-pr;


// Send Non Program Message
dcl-pr QMHSNDM extpgm('QMHSNDM');
  MsgID              char(7)      const;
  MsgFile            char(20)     const;
  MsgDta             char(32767)  const   options(*varsize);
  MsgDtaLen          int(10)      const;
  MsgType            char(10)     const;
  MsgQList           char(10)     const;
  MsgQNbr            int(10)      const;
  MsgQReply          char(20)     const;
  MsgKey             char(4);
  ErrorDs            likeds(ERRC0100_t);
end-pr;

// API QycuRetrieveCertificateInfo
dcl-pr QycuRetrieveCertificateInfo extproc('QycuRetrieveCertificateInfo') ;
  ReceiverVariable                   char(16000000) options(*varsize) ;
  LengthOfReceiverVariable           int(10)      const ;
  FormatOfCertificateInformation     char(8)      const ;
  CertificateStoreName               char(256)    const options(*varsize) ;
  LengthOfCertificateStoreName       int(10)      const ;
  FormatOfCertificateStoreName       char(8)      const ;
  CertificateStorePassword           char(128)    const options(*varsize) ;
  LengthOfCertificateStorePassword   int(10)      const ;
  CCSIDOfCertificateStorePassword    int(10)      const ;
  SelectionControl                   char(258)    const options(*varsize) ;
  ErrorCode                          likeDs(ERRC0100_t) ;
end-pr ;

// Critères de sélection : EXPIRATIONDAYS
dcl-ds SelControl_EXP_t qualified template ;
  LengthOfSelectionControl           int(10) inz(%size(SelControl_EXP_t)) ;
  NumberOfSelectionPairs             int(10) inz(1) ;
  OffsetsToSelectionPairs            int(10) inz dim(1) ;
  dcl-ds sel_EXPIRATIONDAYS ;
    LengthOfSelectionPair              int(10)
                                       inz( %size( SelControl_EXP_t.sel_EXPIRATIONDAYS ) ) ;
    SelectionName                      char(20)  inz('EXPIRATIONDAYS') ;
    SelectionValue                     zoned(4)  inz(30) ;
  end-ds ;
end-ds ;

// Critères de sélection : EXPIRATIONDAYS + CERTIFICATETYPE
dcl-ds SelControl_EXP_TYPE_t qualified template ;
  LengthOfSelectionControl           int(10) inz(%size(SelControl_EXP_TYPE_t)) ;
  NumberOfSelectionPairs             int(10) inz(2) ;
  OffsetsToSelectionPairs            int(10) inz dim(2) ;
  dcl-ds sel_EXPIRATIONDAYS ;
    LengthOfSelectionPair              int(10)
                                       inz( %size( SelControl_EXP_TYPE_t.sel_EXPIRATIONDAYS ) ) ;
    SelectionName                      char(20)  inz('EXPIRATIONDAYS') ;
    SelectionValue                     zoned(4)  inz(30) ;
  end-ds ;
  dcl-ds sel_CERTIFICATETYPE ;
    LengthOfSelectionPair              int(10)
                                       inz( %size( SelControl_EXP_TYPE_t.sel_CERTIFICATETYPE ) ) ;
    SelectionName                      char(20)  inz('CERTIFICATETYPE') ;
    SelectionValue                     char(1)   inz(SELECTION_SERVER_CERTIFICATES) ;
  end-ds ;
end-ds ;

// Critères de sélection : CERTIFICATELABEL
dcl-ds SelControl_LBL_t qualified template ;
  LengthOfSelectionControl           int(10) inz(%size(SelControl_EXP_TYPE_t)) ;
  NumberOfSelectionPairs             int(10) inz(1) ;
  OffsetsToSelectionPairs            int(10) inz dim(1) ;
  dcl-ds sel_CERTIFICATELABEL ;
    LengthOfSelectionPair              int(10)
                                       inz( %size( SelControl_LBL_t.sel_CERTIFICATELABEL ) ) ;
    SelectionName                      char(20)  inz('CERTIFICATELABEL') ;
    SelectionValue                     char(128) inz ;
  end-ds ;
end-ds ;

dcl-c SELECTION_SERVER_CERTIFICATES const('0') ;
dcl-c SELECTION_CA_CERTIFICATES const('0') ;

// Décodage valeurs retour
dcl-ds RTCI0200_t qualified template ;
  bytesReturned                      int(10) ;
  bytesAvailable                     int(10) ;
  OffsetToFirstCertificateEntry      int(10) ;
  NumberOfCertificateEntriesReturned int(10) ;
// ... entrées
end-ds;

dcl-ds RTCI0200_Entry_t qualified template ;
  DisplacementToNextCertificateEntry int(10) ;
  ValidityPeriodEnd                  char(14) ;
  Reserved                           char(2) ;
  DisplacementToCertificateLabel     int(10) ;
  LengthOfCertificateLabel           int(10) ;
  DisplacementToSubjectsCommonName   int(10) ;
  LengthOfSubjectsCommonName         int(10) ;
// ARRAY(*) of CHAR Certificate information fields
end-ds;

// Variables globales
//------------------------------------------------------------------------

// pour utilisation API
dcl-s  datas     char(1000000) inz ;
dcl-ds errorDS   likeds( ERRC0100_t ) inz(*likeds) ;
dcl-ds RTCI0200 likeds( RTCI0200_t ) based( RTCI0200_Ptr ) ;
dcl-ds RTCI0200_Entry likeds( RTCI0200_Entry_t ) based( RTCI0200_Entry_Ptr ) ;
dcl-s  certificateInformationField char(256) based(certificateInformationField_Ptr) ;

// travail
dcl-s  wMsgDta char(512) ;
dcl-s  wI int(10) ;
dcl-s  wNbExp int(10) ;
dcl-s  wDate date ;
dcl-s  wTime time ;

// Programme
//------------------------------------------------------------------------


// Paramètres
//- - - - - - -
dcl-pi *n ;
  p_KeyStr    char(128)   const ;   // Magasin de certificats
  p_KeyStrPwd char(128)   const ;   // Mot de passe
  p_CrtLbl    char(128)   const ;   // Label du certificat
  p_CrtTyp    char(7)     const ;   // Type de certificat
  p_Exp       packed(3:0) const ;   // Délai d'expiration (jours)
  p_Notify    char(7)     const ;   // *JOBLOG *SYSOPR *BOTH
end-pi;


// Recerche en fonction des critères
// ---------------------------------
if p_CrtLbl <> '*ALL' ;
  rechLibelle() ;
else ;
  rechType() ;
endif ;
if errorDS.BytAvl > 0 ;
  if errorDS.MsgDta <> *blanks ;
    sendProgramMessage( %trim( errorDS.MsgDta ) : '*ESCAPE' ) ;
  else ;
    sendProgramMessage( 'Erreur lors de l''exécution de la commande.' : '*ESCAPE' ) ;
  endif ;
  return ;
endif ;


// Parcours des résultats
// -------------------------

// Entête :
RTCI0200_Ptr = %addr( datas ) ;

// Liste   des certificats et date de fin de validité :
RTCI0200_Entry_Ptr = RTCI0200_Ptr + RTCI0200.OffsetToFirstCertificateEntry ;

for wI = 1 to RTCI0200.NumberOfCertificateEntriesReturned ;
  // Extraire les infos du certificats
  // ---------------------------------

  // Validity period end
  wDate = %date( %subst( RTCI0200_Entry.ValidityPeriodEnd : 1 : 8 ) : *iso0 ) ;
  wTime = %time( %subst( RTCI0200_Entry.ValidityPeriodEnd : 9 : 6 ) : *iso0 ) ;

  // Recherche par libellé : il faut tester la date
  if (p_CrtLbl = '*ALL') or ( p_CrtLbl <> '*ALL' and  wDate <= %date() + %days(p_Exp) ) ;

    // Traiter le certificat
    wNbExp += 1 ;

    // Certificate label
    certificateInformationField_Ptr = RTCI0200_Entry_Ptr +
                                      RTCI0200_Entry.DisplacementToCertificateLabel ;
    wMsgDta = 'Certificate label = ' + %subst( certificateInformationField : 1 :
                                              RTCI0200_Entry.LengthOfCertificateLabel ) ;
    // Certificate common name
    certificateInformationField_Ptr = RTCI0200_Entry_Ptr +
                                      RTCI0200_Entry.DisplacementToSubjectsCommonName ;
    wMsgDta = %trim(wMsgDta) + ', Common name = ' +
             %subst( certificateInformationField : 1 :
                     RTCI0200_Entry.LengthOfSubjectsCommonName ) ;
    wMsgDta = %trim( wMsgDta ) + ', expire le ' + %char( wDate : *eur ) + ' à ' + %char( wTime ) ;

    if p_Notify <> '*SYSOPR' ;
      sendProgramMessage( %trim( wMsgDta ) : '*DIAG' ) ;
    endif ;
    if p_Notify <> '*JOBLOG' ;
      sendMessageSysopr( %trim( wMsgDta ) ) ;
    endif ;

  endif ;


  // prochain certificat
  // ---------------------------------
  RTCI0200_Entry_Ptr += RTCI0200_Entry.DisplacementToNextCertificateEntry ;
endfor ;

if p_Notify <> '*SYSOPR' ;
  if wI > 0 ;
    sendProgramMessage( 'Des certificats (' +
                        %trim(%char(wNbExp)) +
                        ') arrivent à expiration. ' +
                        'Regardez la joblog pour la liste.' : '*ESCAPE' ) ;
  else ;
    sendProgramMessage( 'Aucun certificat expiré.' : '*DIAG' ) ;
  endif ;
endif ;

return ;



// Recherche par libellé
// ---------------------
dcl-proc rechLibelle ;

  // variables
  dcl-ds SelControl_LBL      likeds(SelControl_LBL_t)      inz(*likeds) ;

  // Filtre de sélection
  SelControl_LBL.OffsetsToSelectionPairs(1) = %addr( SelControl_LBL.sel_CERTIFICATELABEL )
                                            - %addr( SelControl_LBL ) ;
  SelControl_LBL.sel_CERTIFICATELABEL.SelectionValue = %trim( p_CrtLbl ) ;
  SelControl_LBL.sel_CERTIFICATELABEL.LengthOfSelectionPair =
       %size( SelControl_LBL.sel_CERTIFICATELABEL.LengthOfSelectionPair ) +
       %size( SelControl_LBL.sel_CERTIFICATELABEL.SelectionName ) +
       %len( %trim( p_CrtLbl ) ) ;
  // Taille du bloc de sélection
  SelControl_LBL.LengthOfSelectionControl = %size( SelControl_LBL.LengthOfSelectionControl ) +
                                            %size( SelControl_LBL.NumberOfSelectionPairs ) +
                                            %size( SelControl_LBL.OffsetsToSelectionPairs ) +
                                        SelControl_LBL.sel_CERTIFICATELABEL.LengthOfSelectionPair ;

  // Appel API
  QycuRetrieveCertificateInfo( datas :
                               %len(datas) :
                               'RTCI0200' :
                               p_KeyStr :
                               %len( %trim(p_KeyStr) ) :
                               'OBJN0100' :
                               p_KeyStrPwd :
                               %len(%trim(p_KeyStrPwd)) :
                               37 : // US !
                               SelControl_LBL :
                               errorDS ) ;

end-proc ;


// Recherche type / date
// ---------------------
dcl-proc rechType ;

  // variables
  dcl-ds SelControl_EXP_TYPE likeds(SelControl_EXP_TYPE_t) inz(*likeds) ;
  dcl-ds SelControl_EXP      likeds(SelControl_EXP_t)      inz(*likeds) ;
  dcl-s  selectionControl    char(80)                      inz ;

  // Filtre de sélection
  if p_CrtTyp = '*ALL' ;
    SelControl_EXP.sel_EXPIRATIONDAYS.SelectionValue = p_Exp ;
    SelControl_EXP.OffsetsToSelectionPairs(1) = %addr( SelControl_EXP.sel_EXPIRATIONDAYS )
                                                  - %addr( SelControl_EXP ) ;
    selectionControl = SelControl_EXP ;
  else ;
    SelControl_EXP_TYPE.sel_EXPIRATIONDAYS.SelectionValue = p_Exp ;
    SelControl_EXP_TYPE.OffsetsToSelectionPairs(1) = %addr( SelControl_EXP_TYPE.sel_EXPIRATIONDAYS )
                                                  - %addr( SelControl_EXP_TYPE ) ;
    // Type de certificat
    if p_CrtTyp = '*SERVER' ;
      SelControl_EXP_TYPE.sel_CERTIFICATETYPE.SelectionValue = SELECTION_SERVER_CERTIFICATES ;
    else ;
      SelControl_EXP_TYPE.sel_CERTIFICATETYPE.SelectionValue = SELECTION_CA_CERTIFICATES ;
    endif ;
    SelControl_EXP_TYPE.OffsetsToSelectionPairs(2) =
              %addr( SelControl_EXP_TYPE.sel_CERTIFICATETYPE ) - %addr( SelControl_EXP_TYPE ) ;
    selectionControl = SelControl_EXP_TYPE ;
  endif ;

  // Appel API
  QycuRetrieveCertificateInfo( datas :
                               %len(datas) :
                               'RTCI0200' :
                               p_KeyStr :
                               %len( %trim(p_KeyStr) ) :
                               'OBJN0100' :
                               p_KeyStrPwd :
                               %len(%trim(p_KeyStrPwd)) :
                               37 : // US !
                               SelectionControl :
                               errorDS ) ;

end-proc ;



// Envoyer un message en *ESCAPE / *DIAG dans la JOBLOG
// ----------------------------------------------------
dcl-proc sendProgramMessage ;
  dcl-pi *n ;
    p_MsgDta     char(512)    const   options(*varsize);
    p_MsgType    char(10)     const;
  end-pi;

  dcl-s MsgKey char(4) ;
  dcl-ds ErrorDS likeds( ERRC0100_t ) inz(*likeds) ;

  qmhsndpm( 'CPF9897' : 'QCPFMSG   *LIBL' : p_MsgDta : %len(%trim(p_MsgDta)) :
  p_MsgType : '*PGMBDY' : 1 : MsgKey : ErrorDS );

end-proc ;


// Envoyer un message dans *SYSOPR
// -------------------------------
dcl-proc sendMessageSysopr ;
  dcl-pi *n ;
    p_MsgDta     char(512)    const   options(*varsize);
  end-pi;

  dcl-s MsgKey char(4) ;
  dcl-ds ErrorDS likeds( ERRC0100_t ) inz(*likeds) ;

  QMHSNDM( 'CPF9897' : 'QCPFMSG   *LIBL' : p_MsgDta : %len(%trim(p_MsgDta)) :
  '*INFO' : '*SYSOPR' : 1 : '' : MsgKey : ErrorDS ) ;

end-proc ; 
