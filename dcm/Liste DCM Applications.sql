/*
Cataloguage de la fonction table
Permet de lister les applications DCM ET les certificats associés
*/

create or replace function nb.listedcmapplication( 
  Application_Certificate varchar(8) DEFAULT '*ALL',
  Application_Type varchar(10) DEFAULT '*ALL')
returns table(
  Application_ID                                        varchar(100),
  Exit_Program_Name                                     char(10),
  Exit_Program_Library_Name                             char(10),
  Threadsafe                                            char(1),
  QMLTTHDACN_System_Value_Usage                         char(1),
  Multithreaded_Job_Action                              char(1),
  Application_Description_Indicator                     char(1),
  Application_Description_Message_File_Name             char(10),
  Application_Description_Message_File_Library_Name     char(10),
  Application_Description_Message_ID                    char(7),
  Application_Text_Description                          varchar(50),
  Limit_CA_Certificates_Trusted_Indicator               char(1),
  Certificate_Assigned_Indicator                        char(1), 
  Application_Type                                      varchar(11),
  Application_User_Profile                              char(10),
  ClientAuthentication_Required                         char(1),
  Perform_CRL_Processing                                char(1),
  Application_Description_Message_Text                  varchar(330),
  Certificate_Label                                     varchar(100),
  Certificate_Store                                     varchar(100))
external name 'NB/LSTDCMAPP'
language rpgle
parameter style db2sql
no sql
not deterministic
disallow parallel ;


-- Syntaxes supportées
select * from table(nb.listedcmapplication()) ;
select * from table(nb.listedcmapplication('*ALL', '*ALL')) ;
select * from table(nb.listedcmapplication('*ALL')) ;
select * from table(nb.listedcmapplication('*WITH')) ;
select * from table(nb.listedcmapplication('*WITHOUT')) ;
select * from table(nb.listedcmapplication(APPLICATION_CERTIFICATE => '*ALL')) ;
select * from table(nb.listedcmapplication(APPLICATION_CERTIFICATE => '*WITH')) ;
select * from table(nb.listedcmapplication(APPLICATION_CERTIFICATE => '*WITHOUT')) ;
select * from table(nb.listedcmapplication(APPLICATION_TYPE => '*ALL')) ;
select * from table(nb.listedcmapplication(APPLICATION_TYPE => '*CLIENT')) ;
select * from table(nb.listedcmapplication(APPLICATION_TYPE => '*SERVER')) ;
select * from table(nb.listedcmapplication(APPLICATION_CERTIFICATE => '*ALL', APPLICATION_TYPE => '*ALL')) ;
select * from table(nb.listedcmapplication(APPLICATION_CERTIFICATE => '*ALL', APPLICATION_TYPE => '*CLIENT')) ;
select * from table(nb.listedcmapplication(APPLICATION_CERTIFICATE => '*ALL', APPLICATION_TYPE => '*SERVER')) ;
select * from table(nb.listedcmapplication(APPLICATION_CERTIFICATE => '*WITH', APPLICATION_TYPE => '*ALL')) ;
select * from table(nb.listedcmapplication(APPLICATION_CERTIFICATE => '*WITH', APPLICATION_TYPE => '*CLIENT')) ;
select * from table(nb.listedcmapplication(APPLICATION_CERTIFICATE => '*WITH', APPLICATION_TYPE => '*SERVER')) ;
select * from table(nb.listedcmapplication(APPLICATION_CERTIFICATE => '*WITHOUT', APPLICATION_TYPE => '*ALL')) ;
select * from table(nb.listedcmapplication(APPLICATION_CERTIFICATE => '*WITHOUT', APPLICATION_TYPE => '*CLIENT')) ;
select * from table(nb.listedcmapplication(APPLICATION_CERTIFICATE => '*WITHOUT', APPLICATION_TYPE => '*SERVER')) ;



-- Exemple d'utilisation : trouver les certificats qui vont expirer dans un mois et les applications concernées
select crt.certificate_label, crt.validity_start, crt.validity_end, app.application_id, app.application_text_description, application_description_message_text
  from table (
      qsys2.certificate_info(certificate_store_password => '*NOPWD')
    ) crt
    join table(
	  nb.listedcmapplication('*ALL', '*ALL')
	) app on crt.certificate_label = app.certificate_label
  where  crt.validity_end < current date + 1 month
  order by crt.validity_end;
