# CHKCERTVLD

### La commande CHKCERTVLD (Contrôler validité certificats) vous permet de contrôler les dates de validités de vos certificats gérés par DCM.

Vous devez indiquer : nom du magasin ou emplacement, mot de passe. 2 possibilités de sélection des certificats :
- par libellé
- par type : client/serveur ou CA
Vous indiquer ensuite me délai d'expiration pour lequel vous souhaitez tester
Et la façon de notifier les certificats arrivant à expiration :
- *JOBLOG : message dans la log du travail
- *SYSOPR : message pour l'opérateur système
- *BOTH : les deux !

Exemple de syntaxe : certificats server/client du magasin *SYSTEM qui arrivent à expiration dans les 30 jours.
>CHKCERTVLD KEYSTR(*SYSTEM) KEYTRPWD(XXXXX) CRTTYP(*SERVER) EXP(30) NOTIFY(*JOBLOG)                                                             
>Certificate label = QIBM_HTTP_SERVER_WS_UNIV_18, Common name =           
>  neptune.wirtanen.net, expire le 06.05.2019 à 23.19.02                  
>Certificate label = QIBM_HTTP_SERVER_ADMIN, Common name =                
>  neptune.wirtanen.net, expire le 10.09.2019 à 18.09.23              
>Certificate label = QIBM_HTTP_SERVER_WS_MOBILE, Common name =        
>  neptune.wirtanen.net, expire le 19.03.2020 à 14.53.09              
>Certificate label = formation, Common name = neptune, expire le      
>  19.03.2020 à 15.30.59                                              
>Des certificats (4) arrivent à expiration. Regardez la joblog pour la

Lorsqu'au moins un certificat est trouvé, un message en *ESCAPE est émis, et autant de message en *DIAG que de certificats.

**Attention :**
- si vous avez des plantages (recherche par libellé) : APAR SE73394 (cf https://www.ibm.com/support/pages/node/6177585), PTF bientôt disponible
- si vous effectuez une recherche par libellé et que ce dernier n'existe pas dans le magasin, cela créé un problème (WRKPRB) : ce fonctionnement est normal et documenté par IBM pour tracer les erreurs liées à la sécurité.
