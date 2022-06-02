# IBM® i database serving Exit Program
The database server has five different exit points defined:
- **QIBM_QZDA_INIT**: Called at server initiation
- **QIBM_QZDA_NDB1** : Called for native database requests
- **QIBM_QZDA_SQL1** : Called for SQL requests
- **QIBM_QZDA_SQL2** : Called for SQL requests
- **QIBM_QZDA_ROI1** : Called for retrieving object information requests and SQL catalog functions

https://www.ibm.com/docs/en/i/7.4?topic=parameters-database-server

## QIBM_QZDA_INIT
The QIBM_QZDA_INIT exit point is defined to run an exit program at server initiation. If a program is defined for this exit point, it is called each time the database server is initiated.

## QIBM_QZDA_NDB1 
The QIBM_QZDA_NDB1 exit point is defined to run an exit program for native database requests for the database server. Two formats are defined for this exit point. Format ZDAD0100 is used for the following functions:

- Create source physical file
- Create database file, based on existing file
- Add, clear, delete database file member
- Override database file
- Delete database file override
- Delete file

## QIBM_QZDA_SQL1 
The QIBM_QZDA_SQL1 exit point is defined to run an exit point for certain SQL requests that are received for the database server. Only one format is defined for this exit point. The following are the functions that cause the exit program to be called:

- Prepare
- Open
- Execute
- Connect
- Create package
- Clear package
- Delete package
- Stream fetch
- Execute immediate
- Prepare and describe
- Prepare and execute or prepare and open
- Open and fetch
- Execute or open
- Return package information

## QIBM_QZDA_SQL2 
The QIBM_QZDA_SQL2 exit point is defined to run an exit point for certain SQL requests that are received for the database server. The QIBM_QZDA_SQL2 exit point takes precedence over the QIBM_QZDA_SQL1 exit point. If a program is registered for the QIBM_QZDA_SQL2 exit point, it will be called and a program for the QIBM_QZDA_SQL1 exit point will not be called. The following are the functions that cause the exit program to be called:

- Prepare
- Open
- Execute
- Connect
- Create package
- Clear package
- Delete package
- Stream fetch
- Execute immediate
- Prepare and describe
- Prepare and execute or prepare and open
- Open and fetch
- Execute or open
- Return package information

## QIBM_QZDA_ROI1 
The QIBM_QZDA_ROI1 exit point is defined to run an exit program for the requests that retrieve information about certain objects for the database server. It is also used for SQL catalog functions.

This exit point has two formats defined. These formats are described below.

Format ZDAR0100 is used for requests to retrieve information for the following objects:

- Library (or collection)
- File (or table)
- Field (or column)
- Index
- Relational database (or RDB)
- SQL package
- SQL package statement
- File member
- Record format
- Special columns
