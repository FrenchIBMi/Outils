**FREE
Ctl-Opt dftactgrp(*no) actgrp(*caller);
//*******************************************************************************************************
// C.I.L LAMBALLE                                                                   S.Bourreau 24/02/12
// Test existence et droits d accès sur fichier IFS                                   Fiche n°
//
// Ex. d'appel : CALL PGM(CHKIFSOBJ) PARM('/home/qpgmr8/catjur.csv' ' ')
//-------------------------------------------------------------------------------------------------------
Dcl-Pr p_CHKIFSOBJ extpgm('CHKIFSOBJ');
  *n              Char(256)       const; // paramètre entrée
  *n              Char(256);             // paramètre sortie
End-Pr;
Dcl-Pi p_CHKIFSOBJ;
  yy_l256         Char(256)       const; // paramètre entrée
  xx_l256         Char(256);             // paramètre sortie
End-Pi;

Dcl-Ds yy_CHKIFSOBJ Len(256);
  yy_lfic         Char(255);             // Chemin complet du fichier IFS
End-Ds;

Dcl-Ds xx_CHKIFSOBJ Len(256);
  xx_cret         Char(1);     // Code retour
End-Ds;
//-------------------------------------------------------------------------------------------------------
// PROTOTYPES
Dcl-Pr access Int(10) ExtProc('access');
  Path            Pointer         Value Options(*string);
  amode           Int(10)         Value;
End-Pr;
//-------------------------------------------------------------------------------------------------------
// Flag pour droits d'accès de l'API IFS access()
//      F_OK = Le fichier existe
//      R_OK = Droit accès
//      W_OK = Droit écriture
//      X_OK = Droit execution ou recherche
//-------------------------------------------------------------------------------------------------------
Dcl-C F_OK            0;
Dcl-C R_OK            4;
Dcl-C W_OK            2;
Dcl-C X_OK            1;
//-------------------------------------------------------------------------------------------------------

// initialisation zones "paramètres"
yy_CHKIFSOBJ = yy_l256;
xx_CHKIFSOBJ = xx_l256;

// traitement
Clear xx_CHKIFSOBJ;
exsr sp_CHKIFSOBJ;
*inlr = '1';

// initialisation paramètre retour
xx_l256 = xx_CHKIFSOBJ;

//-----------------------------------------------------------------------------------------------------
// traitement CHKIFSOBJ
//-----------------------------------------------------------------------------------------------------
begsr sp_CHKIFSOBJ;
  eval      xx_cret = '0';
  // Test si le fichier existe dans l'IFS
  If access(%trim(yy_lfic): F_OK) = 0;
    eval      xx_cret = '1';
    // Test si droits en lecture sur le fichier de l'IFS
    If access(%trim(yy_lfic): R_OK) = 0;
      eval      xx_cret = '2';
      // Test si droits en écriture sur le fichier de l'IFS
      If access(%trim(yy_lfic): W_OK) = 0;
        eval      xx_cret = '3';
        // Test si droits en éxécution sur le fichier de l'IFS
        If access(%trim(yy_lfic): X_OK) = 0;
          eval      xx_cret = '4';
        EndIf;//X_OK
      EndIf;  //W_OK
    EndIf;    //R_OK
  EndIf;      //F_OK
endsr;
//----------------------------------------------------------------------------------------------------- 
