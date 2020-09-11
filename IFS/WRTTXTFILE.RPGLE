**FREE
Ctl-Opt dftactgrp(*no) actgrp(*caller);
//*******************************************************************************************************
// C.I.L LAMBALLE                                                                  S.Bourreau 11/09/2020
// Exemple ecriture d'un fichier IFS dans l'IFS
//-------------------------------------------------------------------------------------------------------
/copy xxx/QRPGLESRC,CIFSIO_H // Header API IFS

// Variables
DCL-S data char(9999);

Dcl-Pr p_WRTTXTFILE extpgm('WRTTXTFILE');
  *n              Char(256)       const; // paramètre entrée
  *n              Char(256);             // paramètre sortie
End-Pr;
Dcl-Pi p_WRTTXTFILE;
  yy_l256         Char(256)       const; // paramètre entrée
  xx_l256         Char(256);             // paramètre sortie
End-Pi;

Dcl-Ds yy_WRTTXTFILE Len(256);
  yy_lfic         Char(255);             // Chemin complet du fichier IFS
End-Ds;

Dcl-Ds xx_WRTTXTFILE Len(256);
  xx_cret         Char(1);     // Code retour
End-Ds;

// initialisation zones "paramètres"
yy_WRTTXTFILE = yy_l256;
xx_WRTTXTFILE = xx_l256;

// Changement de CCSID du job (Nécessaire pour les JOB en CCSID 65535 !)
//QCMDEXC('CHGJOB CCSID(1147)': 20);

// traitement
Clear xx_WRTTXTFILE;
xx_cret = '1';

exsr sp_openFile;
if xx_cret = '1';
  exsr sp_WRTTXTFILE;
  exsr closeFile;
endif; // xx_cret = '1';

// Retour au CCSID d'origine
//QCMDEXC('CHGJOB CCSID(*SYSVAL)': 21);

*inlr = '1';

// initialisation paramètre retour
xx_l256 = xx_WRTTXTFILE;

//-----------------------------------------------------------------------------------------------------
// traitement WRTTXTFILE
//-----------------------------------------------------------------------------------------------------
begsr sp_WRTTXTFILE;

  data = 'Test d''écriture dans l''IFS';

  data = %trim(data)
        + CRLF;

  callp write(fd: %addr(data): %len(%trimr(data)));

endsr; // sp_WRTTXTFILE
//-----------------------------------------------------------------------------------------------------
// Création / Ouverture du fichier
//-----------------------------------------------------------------------------------------------------
begsr sp_openFile;

  // Create an empty file with the right CCSID and code page
  flags = O_TRUNC+O_CREAT+O_WRONLY;
  mode  = S_IWUSR+S_IRUSR+S_IRGRP+S_IROTH;

  // Ouverture du fichier
  //  fd = open(%trimr(yy_lfic): flags: mode: 1252);
  fd = open(%trimr(yy_lfic): flags : mode);

  if fd < 0;
    xx_cret = '0';
  endif;// fd < 0

endsr;// sp_openFile
//-----------------------------------------------------------------------------------------------------
begsr closeFile;
  callp close(fd);
endsr; // closeFile
//----------------------------------------------------------------------------------------------------- 
