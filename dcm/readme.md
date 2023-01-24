```
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
```
