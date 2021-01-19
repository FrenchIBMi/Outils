# Génération d'UUID (Universal Unique Identifier)

Cette procédure vous permet de générer des UUID via l'appel à l'API https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_74/rzatk/GENUUID.htm

Dans cet exemple, les UUID sont générés en version 4, ce qui nécessite des PTF (cf https://www.ibm.com/support/pages/genuuid-can-generate-more-random-uuid).

Pour générer en version 1, modifier le code pour indiquer :
> version             int(3)     inz( 0 ) ;

Au lieu de

> version             int(3)     inz( 1 ) ;
