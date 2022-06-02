      // =================================================================================================
      // Service...... :
      // Application.. : Audit ODBC
      // Objet........ : Log des connexions SQL (OBDC / JDBC)
      // Création..... : 02/06/22 par Sébastien BOURREAU
      // Modifications :
      //   +  /  /   par
      // =================================================================================================
      // A positionner sur les points d'exit :
      // - QIBM_QZDA_INIT format ZDAI0100
      // =================================================================================================

      /Copy QSYSINC/QRPGLESRC,EZDAEP

     DAccepte          S              1
     C     *Entry        PLIST
     C                   Parm                    Accepte
     C                   Parm                    EZDQSQLF

       // Exemple de blocage à adapter au besoin
       If EZDUP = 'BOURREAU' Or
        %Subst(EZDUP:1:1)='Q';
         Accepte = *On;
       Else;
         Accepte =*Off;
       EndIf;

       EXEC SQL
         SET OPTION commit = *none,
                               SRTSEQ = *LANGIDSHR,
                               CLOSQLCSR = *ENDMOD;

       EXEC SQL
         INSERT INTO log.ODBCINI_AUDIT (
               utilisateur,
               interface_type,
               interface_name,
               interface_level
             )
           VALUES
             (
               :ezdup,
               :ezdit,
               :ezdin,
               :ezdil
             );

       Return; 