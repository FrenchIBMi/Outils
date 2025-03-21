**free

// "Dump" des données d'une table sous forme d'instructions INSERT :
//   insert into matable values(1, 'donnée 1.1', 'donnée 1.2', '2023.07.04') ;
//   insert into matable values(2, 'donnée 2.1', NULL, '2023.07.04') ;
// Le fichier de sortie est encodée en UTF-8

// Limites :
// 1. Types de colonnes non supportées actuellement : CLOB, BLOB, DATALINK, XML, GRAPHIC, VARGRAPHIC
// 2. Pas plus de 16Mo par enregistrement
// 3. On ne gère pas les alias, partitions, IASP
// 4. 250 colonnes maximum
// 5. Zones {VAR}CHAR CCSID 65535
// 6. Sélection des zones
// 7. En cas de multi-membre, seul le premier membre est traité

// @todo :
// - meilleure gestion des messages
// - Choix du retour à la ligne : LF, CR, CRLF
// - Performance

ctl-opt actgrp(*new) ;

// Variables globales
dcl-s g_Lib  char(10) ;
dcl-s g_File char(10) ;

dcl-ds g_Desc_t qualified template ;
  position  int(10)      ;
  nom       varchar(10) ;
  type      varchar(8)  ;
  length    int(10)     ;
  numscl    int(10)      ;
  nullable  char(1)     ;
  precision int(10)      ;
  ccsid     int(10)      ;
end-ds ;
dcl-s  g_DescLen uns(3) inz ;
dcl-ds g_Desc dim(250) likeds(g_Desc_t) inz;


// Paramètres
dcl-pi *n ;
  p_QualFile    char(20)  const ;  // Bibliothèque + fichier
  p_script      char(128) const ;  // nom du fichier à générer sur l'IFS
end-pi ;

// Options de compilation SQL
exec sql Set Option Commit = *NONE,
                    DatFmt = *ISO,
                    TimFmt = *ISO,
                    DecMpt = *PERIOD,
                    CLOSQLCSR = *ENDMOD,
                    DYNUSRPRF = *OWNER,
                    NAMING = *SQL ;


// Contrôles des paramètres
if not chkParms( p_QualFile : p_script : g_Lib : g_File ) ;
  snd-msg *ESCAPE %MSG('CPF9897' : 'QCPFMSG' : 'Paramètres obligatoires')
                  %TARGET(*CALLER:1) ;
  return ;
endif ;

// Vérification existence du fichier BD
if not chkFile( g_Lib : g_File ) ;
  snd-msg *ESCAPE %MSG('CPF3012' : 'QCPFMSG' : g_File + g_Lib ) %TARGET(*CALLER:1) ;
  return ;
endif ;

// Retrouver la description des colonnes du fichier
if not rtvFileDesc( g_Lib : g_File : g_DescLen : g_Desc ) ;
  snd-msg *ESCAPE %MSG('CPF9897' : 'QCPFMSG' :
                       'Erreur lors de la récupèration de la description du fichier')
                  %TARGET(*CALLER:1) ;
  return ;
endif ;

// Création du fichier script
if not crtEmptyScript( p_script ) ;
  snd-msg *ESCAPE %MSG('CPF9897' : 'QCPFMSG' :
                       'Erreur lors de la création du script')
                  %TARGET(*CALLER:1) ;
  return ;
endif ;

// Extraction des données
if not dmpData( p_script : g_Lib : g_File : g_DescLen : g_Desc ) ;
  snd-msg *ESCAPE %MSG('CPF9897' : 'QCPFMSG' :
                       'Erreur lors de l''extraction des données')
                  %TARGET(*CALLER:1) ;
  return ;
endif ;

// fin
snd-msg *INFO %MSG('CPF9897' : 'QCPFMSG' :
                   'Extraction terminée')
              %TARGET(*CALLER:1) ;
return ;

// ======================================================================

// Contrôle des paramètres reçus
dcl-proc chkParms ;
  dcl-pi *n ind ;
    p_QualFile  char(20)     const ;
    p_script    varchar(128) const ;
    g_Lib       char(10) ;
    g_File      char(10) ;
  end-pi ;

  g_Lib  = %upper(%subst(p_QualFile : 11 : 10 )) ;
  g_File = %upper(%subst(p_QualFile :  1 : 10 )) ;

  // Contrôle à minima (on verra bien si le fichier existe !)
  return (g_File <> *blanks and g_Lib <> *blanks) ;

end-proc ;



// Contrôle existance du fichier BD
dcl-proc chkFile ;
  dcl-pi *n ind ;
    g_Lib       char(10) ;
    g_File      char(10) const ;
  end-pi ;

  dcl-s l_exist char(1) inz('N') ;
  dcl-s l_Lib   char(10) inz ;

  // Recherche / contrôle de la bibliothèque
  exec sql
      SELECT X.OBJLIB into :l_Lib
      FROM TABLE (QSYS2.OBJECT_STATISTICS(:g_Lib, '*FILE', :g_File ) ) AS X  ;
  if l_Lib = *blanks ;
    return *off ;
  endif ;
  g_Lib = l_Lib ;

  // C'est bien une table ou un fichier physique ?
  exec sql
     select 'O' into :l_exist
     from qsys2.systables
     where system_table_schema = TRIM( :g_Lib ) and
           system_table_name = TRIM( :g_File ) and
           table_type in ('T', 'P') ;

  return (l_exist = 'O') ;

end-proc ;


// Analyser la structure du fichier BD
dcl-proc rtvFileDesc ;
  dcl-pi *n ind ;
    g_Lib       char(10) const ;
    g_File      char(10) const ;
    g_DescLen   uns(3) ;
    g_Desc      dim(250) likeds(g_Desc_t) ;
  end-pi ;

  exec sql
    declare c_col cursor for
      select ORDINAL_POSITION,
             SYSTEM_COLUMN_NAME,
             DATA_TYPE,
             LENGTH,
             coalesce(NUMERIC_SCALE, 0),
             IS_NULLABLE ,
             coalesce(NUMERIC_PRECISION, 0) ,
             coalesce(ccsid, 0)
      from qsys2.syscolumns
        where system_table_schema = :g_Lib and
        system_table_name = :g_File
      order by ORDINAL_POSITION
      LIMIT 250 ;

  exec sql open c_col ;
  exec sql fetch from c_col for 250 ROWS into :g_Desc ;
  exec sql get diagnostics :g_DescLen = ROW_COUNT ;
  exec sql close c_col ;

  return ( g_DescLen > 0 ) ;
end-proc ;



// Créer (ou vider) le script en sortie
dcl-proc crtEmptyScript ;
  dcl-pi *n ind ;
    p_script    varchar(128) const ;
  end-pi ;

  exec sql
    CALL QSYS2.IFS_WRITE_UTF8(PATH_NAME => TRIM( :p_script ),
                              LINE => '',
                              OVERWRITE => 'REPLACE',
                              END_OF_LINE => 'NONE');

  return (SqlCode = 0) ;
end-proc ;



// Extraction des données :
dcl-proc dmpData ;
  dcl-pi *n ind ;
    p_script    varchar(128) const ;
    g_Lib       char(10) const ;
    g_File      char(10) const ;
    g_DescLen   uns(3)   const;
    g_Desc      dim(250) likeds(g_Desc_t) const ;
  end-pi ;

  dcl-s l_err ind inz(*off) ;
  dcl-s l_ColList   varchar(20000) inz('') ;
  dcl-s l_sqlSelect varchar(32000) inz('') ;
  dcl-s l_sqlValue  sqltype(clob : 16000000) ccsid(1208) ;

  // Constitution de la liste des colonnes
  l_ColList = getColList(g_DescLen : g_Desc) ;

  // Constitution de la requête SQL dynamique
  l_sqlSelect = getSqlStmt(g_Lib : g_File : g_DescLen : g_Desc ) ;
  exec sql PREPARE S1 FROM :l_sqlSelect;
  exec sql DECLARE C1 CURSOR FOR S1;
  exec sql OPEN C1 ;
  exec sql fetch C1 into :l_sqlValue ;
  l_err = SqlCode < 0 ;
  dow SqlCode >= 0 and SqlCode <> 100 ;
    // Ecriture dans le script
    exec sql SET :l_sqlValue = 'insert into ' ||
                                trim(:g_Lib) || '.' || trim(:g_File) ||
                                ' values(' || :l_sqlValue || ');' ;
    exec sql CALL QSYS2.IFS_WRITE_UTF8(PATH_NAME => TRIM( :p_script ),
                                       LINE => :l_sqlValue,
                                       OVERWRITE => 'APPEND',
                                       END_OF_LINE => 'CRLF') ;
    // Enreg suivant
    exec sql fetch C1 into :l_sqlValue ;
    l_err = l_err or SqlCode < 0 ;
  enddo ;

  return not l_err ;

  on-exit ;
    exec sql CLOSE C1 ;
end-proc ;



// Constitution de la liste des valeurs
dcl-proc getColList ;
  dcl-pi *n varchar(65000) ;
    g_DescLen   uns(3)   const ;
    g_Desc      dim(250) likeds(g_Desc_t) const ;
  end-pi ;

  dcl-s l_ColList varchar(65000) inz('') ;
  dcl-s l_cpt     int(10) inz ;

  l_ColList = %trim(g_Desc(1).nom) ;
  for l_Cpt = 2 to g_DescLen ;
    l_ColList += ( ', ' + %trim( g_Desc(l_Cpt).nom ) );
  endfor ;

  return l_ColList ;
end-proc ;



// Constitution de l'instruction SQL
dcl-proc getSqlStmt ;
  dcl-pi *n varchar(65000) ;
    g_Lib       char(10) const ;
    g_File      char(10) const ;
    g_DescLen   uns(3)   const ;
    g_Desc      dim(250) likeds(g_Desc_t) const ;
  end-pi ;

  dcl-s l_sqlStmt varchar(65000) inz('') ;
  dcl-s l_cpt     uns(5) inz ;
  dcl-s l_nomCol  varchar(12) inz ;

  l_sqlStmt = 'select ' ;


  // Formatage en fonction du type de donnée
  for l_cpt = 1 to g_DescLen ;

    if l_cpt > 1 ;
      l_sqlStmt += ' || '', '' ||' ;
    endif ;

    // Calcul du nom de la colonne (pour les colonnes ayant déjà "")
    if %subst(g_Desc( l_cpt ).nom : 1 : 1 ) = '"' ;
      l_nomCol = %trim(g_Desc( l_cpt ).nom) ;
    else ;
      l_nomCol = '"' + %trim(g_Desc( l_cpt ).nom) + '"' ;
    endif ;
    // Gestion des valeurs nulles si besoin
    if g_Desc( l_cpt ).nullable = 'Y' ;
      l_sqlStmt += ( ' case when ' + l_nomCol + ' is null then ''NULL'' else ') ;
    endif ;

    select ;

    when g_Desc( l_cpt ).type = 'CHAR' and g_Desc( l_cpt ).ccsid <> 65535 ;
      l_sqlStmt += ( ''''''''' || replace(cast(' + l_nomCol + ' as char(' +
                     %char(g_Desc(l_cpt).length) +
                        ') ccsid 1208) , '''''''', '''''''''''') || ''''''''' ) ;

    when g_Desc( l_cpt ).type = 'CHAR' and g_Desc( l_cpt ).ccsid = 65535 ;
      l_sqlStmt += ( ''''''''' || replace(cast(' + l_nomCol + ' as char(' +
                     %char(g_Desc(l_cpt).length) +
                        ') ccsid 1147) , '''''''', '''''''''''') || ''''''''' ) ;

    when g_Desc( l_cpt ).type = 'VARCHAR' and g_Desc( l_cpt ).ccsid <> 65535 ;
     l_sqlStmt += ( ''''''''' || replace(cast(' + l_nomCol + ' as varchar(' +
                     %char(g_Desc(l_cpt).length) +
                        ') ccsid 1208) , '''''''', '''''''''''') || ''''''''' ) ;

    when g_Desc( l_cpt ).type = 'VARCHAR' and g_Desc( l_cpt ).ccsid = 65535 ;
     l_sqlStmt += ( ''''''''' || replace(cast(' + l_nomCol + ' as varchar(' +
                     %char(g_Desc(l_cpt).length) +
                        ') ccsid 1147) , '''''''', '''''''''''') || ''''''''' ) ;

    when g_Desc( l_cpt ).type = 'BIGINT' or
         g_Desc( l_cpt ).type = 'DECIMAL' or
         g_Desc( l_cpt ).type = 'INTEGER' or
         g_Desc( l_cpt ).type = 'NUMERIC' or
         g_Desc( l_cpt ).type = 'SMALLINT' or
         g_Desc( l_cpt ).type = 'BIGINT' ;
      l_sqlStmt += ( 'trim(char(' + l_nomCol + '))' ) ;

    when g_Desc( l_cpt ).type = 'DATE' or
         g_Desc( l_cpt ).type = 'TIME' ;
      l_sqlStmt += ( ''''''''' || trim(char(' + l_nomCol +
                                            ', iso)) || ''''''''' ) ;

    when g_Desc( l_cpt ).type = 'TIMESTMP' ;
      l_sqlStmt += ( ''''''''' || trim(char(' + l_nomCol +
                                            ')) || ''''''''' ) ;

    endsl ;

    // Si valeur nulle possible
    if g_Desc( l_cpt ).nullable = 'Y' ;
      l_sqlStmt += (' end ') ;
    endif ;

  endfor ;

  return l_sqlStmt + ' from ' + %trim(g_Lib) + '.' + %trim(g_File);
end-proc ;
