# Commande DMPSQL
Cette commande permet de générer un script SQL dans l'IFS contenant les données d'une table ou d'un fichier physique, sous forme d'une séquence d'instructions INSERT INTO.

## Usage
<code>DMPSQL FILE(NB/FICHIER) SQLSCRIPT('/home/nb/fichier.sql')</code>\
<code>DMPSQL FILE(*LIBL/FICHIER) SQLSCRIPT('/home/nb/fichier.sql')</code>\
<code>DMPSQL FILE(*CURLIB*/FICHIER) SQLSCRIPT('/home/nb/fichier.sql')</code>
