--  Générer SQL 
--  Version :                   	V7R3M0 160422 
--  Générée le :              	01/04/19 16:27:25 
--  Base données relation :    	DEVCIL 
--  Option normes :          	Db2 for i 
CREATE TABLE QIWS/QCUSTCDT ( 
--  SQL150B   10   REUSEDLT(*NO) de la table QCUSTCDT de QIWS ignoré. 
	CUSNUM NUMERIC(6, 0) NOT NULL DEFAULT 0 , 
	LSTNAM CHAR(8) CCSID 297 NOT NULL DEFAULT '' , 
	INIT CHAR(3) CCSID 297 NOT NULL DEFAULT '' , 
	STREET CHAR(13) CCSID 297 NOT NULL DEFAULT '' , 
	CITY CHAR(6) CCSID 297 NOT NULL DEFAULT '' , 
	STATE CHAR(2) CCSID 297 NOT NULL DEFAULT '' , 
	ZIPCOD NUMERIC(5, 0) NOT NULL DEFAULT 0 , 
	CDTLMT NUMERIC(4, 0) NOT NULL DEFAULT 0 , 
	CHGCOD NUMERIC(1, 0) NOT NULL DEFAULT 0 , 
	BALDUE NUMERIC(6, 2) NOT NULL DEFAULT 0 , 
	CDTDUE NUMERIC(6, 2) NOT NULL DEFAULT 0 )   
	  
	RCDFMT CUSREC     ; 
  
LABEL ON TABLE QIWS/QCUSTCDT 
	IS 'PC Support Customer File' ; 
  
LABEL ON COLUMN QIWS/QCUSTCDT 
( CUSNUM TEXT IS 'Customer number field' , 
	LSTNAM TEXT IS 'Last name field' , 
	INIT TEXT IS 'First and middle initial field' , 
	STREET TEXT IS 'Street address field' , 
	CITY TEXT IS 'City field' , 
	STATE TEXT IS 'State abbreviation field' , 
	ZIPCOD TEXT IS 'Zip code field' , 
	CDTLMT TEXT IS 'Credit limit field' , 
	CHGCOD TEXT IS 'Charge code field' , 
	BALDUE TEXT IS 'Balance due field' , 
	CDTDUE TEXT IS 'Credit due field' ) ; 
  
GRANT SELECT   
ON QIWS/QCUSTCDT TO PUBLIC ; 
  
GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE   
ON QIWS/QCUSTCDT TO QSECOFR WITH GRANT OPTION ; 
  
