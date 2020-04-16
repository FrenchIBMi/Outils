 CMD        PROMPT('Contrôler validité certificats')

 /* Magasin de certificat */
 PARM       KWD(KEYSTR) TYPE(*PNAME) LEN(128) DFT(*SYSTEM) +
              SPCVAL((*SYSTEM) (*OBJECTSIGNING) (*SIGNATUREVERIFICATION)) +
              MAX(1) CASE(*MIXED) PROMPT('Magasin de certificats')

 /* Mot de passe */
 PARM       KWD(KEYSTRPWD) TYPE(*CHAR) LEN(128) MAX(1) CASE(*MIXED) +
              PROMPT('Mot de passe')

 /* Label du certificat */
 PARM       KWD(CRTLBL) TYPE(*CHAR) LEN(128) DFT(*ALL) SPCVAL((*ALL)) +
              MAX(1) CASE(*MIXED) PROMPT('Label du certificat')

 /* Type de certificat : server, CA ou les deux */
 PARM       KWD(CRTTYP) TYPE(*CHAR) LEN(7) RSTD(*YES) DFT(*SERVER) +
              VALUES('*ALL' '*CA' '*SERVER') MAX(1) PROMPT('Type de +
              certificats')

 /* Durée de péremption recherchée */
 PARM       KWD(EXP) TYPE(*DEC) LEN(3 0) DFT(30) RANGE(0 365) MAX(1) +
              PROMPT('Délai d''expiration (jours)')

 /* Message dans la joblog ou *SYSOPR */
 PARM       KWD(NOTIFY) TYPE(*CHAR) LEN(7) RSTD(*YES) DFT(*JOBLOG) +
              VALUES('*JOBLOG' '*SYSOPR' '*BOTH') MAX(1) PROMPT('Type de +
              notification') 
