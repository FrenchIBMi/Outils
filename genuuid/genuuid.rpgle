**free


// Options de compilation
// -------------------------------------------------------------------------------------------------
ctl-opt nomain ;


// Inclusion du prototype commun
// -------------------------------------------------------------------------------------------------
/include genuuidpr


// Déclarations globales
// -------------------------------------------------------------------------------------------------

// Prototypes pour API & MI

// cvthc : Convert Hex to Character
// https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_74/rzatk/CVTHC.htm
dcl-pr cvthc extproc('cvthc') ;
  result     char(65534)  options(*varsize) ;
  source     char(32767)  options(*varsize) ;
  resultSize int(10)      value ;
end-pr ;

// QlgConvertCase : Convert Case
// https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_74/apis/QLGCNVCS.htm
dcl-pr convertCase extproc('QlgConvertCase') ;
  ctrlBlock     char(22)     const options(*varsize) ;
  inString      char(65535)  const options(*varsize) ;
  outString     char(65535)        options(*varsize) ;
  inLength      int(10)      const ;
  apiErrorDS    char(300)          options(*varsize) ;
end-pr ;


// Prototype pour appel fonction MI _GENUUID
// https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_74/rzatk/GENUUID.htm
dcl-pr genUUID_ extproc('_GENUUID') ;
  UUID_Template pointer value ;
end-pr ;


// Générer un UUID
// -------------------------------------------------------------------------------------------------
dcl-proc genuuid export ;
  dcl-pi *n char(36) ;
  end-pi;

  // Déclarations locales
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  // Valeur de retour
  dcl-s uuid char(36) inz ;


  // Formatted request control block required by QlgConvertCase.
  dcl-ds FRCB qualified ;
    reqType       int(10)    inz(1) ;
    CCSID         int(10)    inz(0) ;
    CvtTo         int(10)    inz(0) ;
    Reserved      char(10)   inz(*allx'00') ;
  end-ds;

  // Structure erreur standard pour API
  dcl-ds ERRC0100 qualified ;
    bytesProvided       int(10)    inz( %size(ERRC0100) ) ;
    bytesAvailable      int(10)    inz ;
    exceptionID         char(7)    inz ;
    reserved            char(1)    inz( x'00' ) ;
    data                char(250)  inz ;
  end-ds;

  // Structure pour appel GENUUID
  dcl-ds UUID_template qualified ;
    bytes_provided      uns(10)    inz( %size(UUID_template) ) ;
    bytes_available     uns(10)    inz ;
    version             int(3)     inz( 1 ) ;
    reserved            char(7)    inz( *allx'00' ) ;
    uuid                char(16)   inz ;
  end-ds ;

  // Corps
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  //  Initialisation des structures pour appel API MI _GENUUID
  genUUID_(%addr(UUID_Template));

  // Conversion du GUUID (encodage)
  cvthc( uuid : UUID_template.uuid : %len(UUID_template.uuid)*2 );
  frcb.cvtto = 1 ; // Conversion en minuscule

  // Conversion en minuscule
  convertcase( FRCB : uuid : uuid :
               %len(uuid) : ERRC0100 );

  // Constitution de l'UUID
  uuid = %subst(uuid:1:8) + '-' +
         %subst(uuid:9:4) + '-' +
         %subst(uuid:13:4) + '-' +
         %subst(uuid:17:4) + '-' +
         %subst(uuid:21:12);

  return uuid ;
end-proc; 
