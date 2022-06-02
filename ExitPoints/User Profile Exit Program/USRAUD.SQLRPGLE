**free
// =================================================================================================
// Service...... :
// Application.. : Profils Utilisateur
// Objet........ : Envoi d'un message lors d'une opération sur les profils utilisateur *ALLOBJ
// Création..... : 05/05/22 par Sébastien BOURREAU
// Modifications :
//   +  /  /   par
// =================================================================================================
// A positionner sur les points d'exit :
// - QIBM_QSY_CRT_PROFILE 
// - QIBM_QSY_CHG_PROFILE 
// - QIBM_QSY_DLT_PROFILE
// =================================================================================================

/DEFINE CtlOpt_OPTION
Ctl-Opt OPTION(*SRCSTMT :*NODEBUGIO:*NOUNREF) EXPROPTS(*ALWBLANKNUM) DEBUG(*RETVAL);

// _____________________________ Déclarations ______________________________________________________

///copy ROUTINES/QRPGLESRC,C_SDSFREEC // Data structure d'informations programme

// _____________________________ Interface _________________________________________________________

dcl-pr USRAUD ExtPgm('USRAUD');
  UsrInfo char(38) const;
end-pr;

dcl-pi USRAUD;
  UsrInfo char(38) const;
end-pi;

// Declare procedure for QcmdExc call
dcl-pr Execute ExtPgm('QCMDEXC');
  Command char(500) const Options(*varsize);
  CommandLength Packed(15:5) const;
end-pr;

// Declare datastructure for breaking down the info
dcl-ds UsrSub;
  pExtPgm CHAR(20);
  pExtFmt CHAR(8);
  pUsrPrf CHAR(10);
end-ds;

dcl-s textMessage varchar(200) inz;
dcl-s usage char(10) inz;
dcl-s CmdString char(200);

dcl-ds userInfo qualified;
  authorizationName varchar(10);
  status varchar(10);
  textDescription varchar(50);
end-ds;

// _____________________________ Début du code _____________________________________________________

EXEC SQL
  SET OPTION commit = *none,
                        SRTSEQ = *LANGIDSHR,
                        CLOSQLCSR = *ENDMOD;

// Bring in the information
UsrSub = UsrInfo;

Select;
When pExtFmt = 'CHGP0100';
  Usage = 'changed';
When pExtFmt = 'CRTP0100';
  Usage = 'created';
When pExtFmt = 'DLTP0100';
  Usage = 'deleted';
When pExtFmt = 'DLTP0200';
  Usage = 'deleted';
When pExtFmt = 'RSTP0200';
  Usage = 'restored';
Endsl;

clear userInfo;

// Vérifier si nouveau profil possède des droits spéciaux.
EXEC SQL
  SELECT u.authorization_name,
         u.status,
         IFNULL(u.text_description, '')
    INTO :userinfo
    FROM qsys2.user_info u
         LEFT JOIN qsys2.user_info g
           ON g.authorization_name = u.group_profile_name
    WHERE u.authorization_name = :pUsrPrf
          AND ((u.special_authorities LIKE '%*ALLOBJ%'
              AND u.authorization_name NOT LIKE 'Q%')
            OR (IFNULL(g.special_authorities, '') LIKE '%*ALLOBJ%'));

// Si oui, envoi d'un message d'alerte
if userInfo.authorizationName <> *blanks;

  textMessage = '{"text": "'
    + 'User Profile '
    + %Trim(pUsrPrf)
    + ' - '
    + %trim(userInfo.textDescription)
    + ' '
    + ' ('
    + %trim(userInfo.status)
    + ') '
    + ' was '
    + %Trim(Usage)
    + '"}';

  CmdString = 'SNDMSG MSG('''
    + %Trim(textMessage)
    + ' '') '
    + 'TOUSR(QSYSOPR)';
  Callp(e)  Execute(CmdString:200);

endif;

Return; 