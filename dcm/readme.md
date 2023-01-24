# Liste des applications DCM et des certificats associés

Cet exemple vous permet de lister par SQL les applications DCM, et les certificats associés aux applications.
Vous pouvez filtrer par type d'application (serveur ou client - objectsigning n'est pas pris en compte actuellement), ainsi que par usage de certificat (certificat présent ou absent).

## Installation

1. Compiler les programme LSTDCMAPP.RPGLE
2. Cataloguer la procédure listedcmapplication

## Utilisation : synytaxes supportées

### Paramètres
- APPLICATION_CERTIFICATE 
    - *ALL : toutes
    - *WITH : seulement les applications avec au moins un certificat associé
    - *WITHOUT : seulement les applications sans certificat associé
- APPLICATION_TYPE
    - *ALL : toutes
    - *SERVER : seulement les applications serveur
    - *CLIENT : seulement les applications client

Les critères sont cumulables.


### Exemples
`
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
`
