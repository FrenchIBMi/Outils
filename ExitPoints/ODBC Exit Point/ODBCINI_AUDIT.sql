CREATE OR REPLACE TABLE LOG.ODBCINI_AUDIT FOR SYSTEM NAME LOGQZDAINI ( 
	UTILISATEUR FOR COLUMN PROFIL     CHAR(10) CCSID 1147 NOT NULL DEFAULT '' , 
	DATE_CONNEXION FOR COLUMN DTCONNEX   TIMESTAMP GENERATED ALWAYS FOR EACH ROW ON UPDATE AS ROW CHANGE TIMESTAMP NOT NULL , 
	INTERFACE_TYPE FOR COLUMN INTF_TYPE  VARCHAR(63) CCSID 1147 NOT NULL DEFAULT '' , 
	INTERFACE_NAME FOR COLUMN INTF_NAME  VARCHAR(127) CCSID 1147 NOT NULL DEFAULT '' , 
	INTERFACE_LEVEL FOR COLUMN INTF_LEVEL VARCHAR(63) CCSID 1147 NOT NULL DEFAULT '' )   
	  
	RCDFMT LOGQZDAINI ; 
  
LABEL ON TABLE LOG.ODBCINI_AUDIT 
	IS 'Fichier de log accès ODBC/JDBC' ; 
  
LABEL ON COLUMN LOG.ODBCINI_AUDIT 
( UTILISATEUR IS 'Profil utilisateur   ' , 
	DATE_CONNEXION IS 'Date connexion       ' , 
	INTERFACE_TYPE IS 'Interface type       ' , 
	INTERFACE_NAME IS 'Interface name       ' , 
	INTERFACE_LEVEL IS 'Interface level      ' ) ; 
  
LABEL ON COLUMN LOG.ODBCINI_AUDIT 
( UTILISATEUR TEXT IS 'Profil utilisateur' , 
	DATE_CONNEXION TEXT IS 'Date de connexion' ) ; 
   
GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE   
ON LOG.ODBCINI_AUDIT TO QPGMR WITH GRANT OPTION ; 