      // =================================================================================================
      // Service...... :
      // Application.. : Audit ODBC
      // Objet........ : Log des requêtes SQL
      // Création..... : 02/06/22 par Sébastien BOURREAU
      // Modifications :
      //   +  /  /   par
      // =================================================================================================
      // A positionner sur les points d'exit :
      // - QIBM_QZDA_SQL1 format ZDAQ0100
      // =================================================================================================

      /Copy QSYSINC/QRPGLESRC,EZDAEP

       dcl-s fonction_libelle varchar(30) inz;

     DAccepte          S              1
     C     *Entry        PLIST
     C                   Parm                    Accepte
     C                   Parm                    EZDQSQLF

       // On accepte toutes les connexions car on veut juste logger
       Accepte = *on;

       EXEC SQL
         SET OPTION commit = *none,
                               SRTSEQ = *LANGIDSHR,
                               CLOSQLCSR = *ENDMOD;

       select;
       when EZDFID04 = X'00001800';
         fonction_libelle = 'Prepare';
       when EZDFID04 = X'00001803';
         fonction_libelle = 'Prepare and describe';
       when EZDFID04 = X'00001804';
         fonction_libelle = 'Open/Describe';
       when EZDFID04 = X'00001805';
         fonction_libelle = 'Execute';
       when EZDFID04 = X'00001806';
         fonction_libelle = 'Execute immediate';
       when EZDFID04 = X'00001809';
         fonction_libelle = 'Connect';
       when EZDFID04 = X'0000180C';
         fonction_libelle = 'Stream fetch';
       when EZDFID04 = X'0000180D';
         fonction_libelle = 'Prepare and execute';
       when EZDFID04 = X'0000180E';
         fonction_libelle = 'Open and fetch';
       when EZDFID04 = X'0000180F';
         fonction_libelle = 'Create package';
       when EZDFID04 = X'00001810';
         fonction_libelle = 'Clear package';
       when EZDFID04 = X'00001811';
         fonction_libelle = 'Delete package';
       when EZDFID04 = X'00001812';
         fonction_libelle = 'Execute or open';
       when EZDFID04 = X'00001815';
         fonction_libelle = 'Return package information';
       endsl;

       EXEC SQL
         INSERT INTO log.ODBCSQL_AUDIT (
               utilisateur,
               fonction,
               fonction_libelle,
               requete_sql
             )
           VALUES
             (
               :EZDUP04,
               :EZDFID04,
               :fonction_libelle
               :EZDSQLST
             );

       Return; 