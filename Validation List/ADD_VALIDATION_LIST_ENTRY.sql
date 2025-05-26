set current schema = NB ;
set path = 'NB' ;

Create or replace Function VALIDATION_LIST_ENTRIES ( 
                  VALIDATION_LIST_LIBRARY  varchar(10),
                  VALIDATION_LIST_NAME     varchar(10) )
               Returns Table                    
               (                   
                 VALIDATION_USER   varchar(100),                   
                 ENTRY_DATA        varchar(1000)
               )                
               external name 'VLDLUDTF(VLDL_LIST)'                
               language rpgle                
               parameter style db2sql                
               no sql                
               not deterministic                
               disallow parallel;


cl: DLTVLDL VLDL(NB/DEMO) ;
cl: CRTVLDL VLDL(NB/DEMO) TEXT('Démo VALIDATION_LIST_ENTRIES')   ;

VALUES SYSTOOLS.ERRNO_INFO(SYSTOOLS.ADD_VALIDATION_LIST_ENTRY(
                             VALIDATION_LIST_LIBRARY => 'NB', 
                             VALIDATION_LIST_NAME    => 'DEMO',
                             VALIDATION_USER         => 'user 1',
                             PASSWORD                => 'MDP user 1',
                             ENTRY_DATA              => 'Client 1'));
VALUES SYSTOOLS.ERRNO_INFO(SYSTOOLS.ADD_VALIDATION_LIST_ENTRY(
                             VALIDATION_LIST_LIBRARY => 'NB', 
                             VALIDATION_LIST_NAME    => 'DEMO',
                             VALIDATION_USER         => 'user 2',
                             PASSWORD                => 'MDP user 2',
                             ENTRY_DATA              => 'Client 1'));
VALUES SYSTOOLS.ERRNO_INFO(SYSTOOLS.ADD_VALIDATION_LIST_ENTRY(
                             VALIDATION_LIST_LIBRARY => 'NB', 
                             VALIDATION_LIST_NAME    => 'DEMO',
                             VALIDATION_USER         => 'user 3',
                             PASSWORD                => 'MDP user 3',
                             ENTRY_DATA              => 'Client 2'));

select * from table(VALIDATION_LIST_ENTRIES( VALIDATION_LIST_LIBRARY => 'NB',
                                             VALIDATION_LIST_NAME    => 'DEMO' )) ;
