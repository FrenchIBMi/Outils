 CMD        PROMPT('Dump SQL d''une table')

 /* Fichier BD */
 PARM       KWD(FILE) TYPE(OBJQUAL)  +
              MIN(1) MAX(1) PROMPT('Fichier BD à exporter')

 /* Script SQL */
 PARM       KWD(SQLSCRIPT) TYPE(*PNAME) LEN(128)  +
              MIN(1) MAX(1) CASE(*MIXED) PROMPT('Script SQL à générer')

 /* Eléments qualifiés */
 OBJQUAL: QUAL       TYPE(*NAME) LEN(10) MIN(1)
          QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL((*LIBL) (*CURLIB)) +
                          PROMPT('Bibliothèque ')
