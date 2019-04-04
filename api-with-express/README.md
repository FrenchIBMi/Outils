API sécurisée avec Express
===

Exemple d'API sécurisé avec le framework Express.

Autenthification sur l'IBMi avec [QSYSGETPH](https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_73/apis/QSYGETPH.htm) API.

Echange de token avec [JWT](https://jwt.io/).



Commencer
---

Installation des dépendences
```
$ npm install
```
Generation des certificats auto-signé
```
$ openssl genrsa -out api-with-express-key.pem 2048
```
```
$ openssl req -new -sha256 -key api-with-express-key.pem -out api-with-express-csr.pem
```
```
$ openssl x509 -req -in api-with-express-csr.pem -signkey api-with-express-key.pem -out api-with-express-cert.pem
```

Copier la table **QIWS/QCUSTCDT** dans votre bibliothèque.

Modifier la configuration dans le répertoire *config* :
- port: Port découte en HTTP
- port_secure: Port découte en HTTPS
- schema: bibliothèque pour QCUSTCDT
- secret: passphrase pour encoder/decoder JWT
- jwt_option: Options pour signer le JWT

Exécuter le projet
```
$ npm start 
```

Utilisation
- Se connecter à /login avec un profile/password actif sur l'IBMi. 
  - Cela va retourner un jeton JWT si l'authentification a réussie.
  - Sinon, cela retourne une erreur.
- Ensuite, appeler les API en passant le jeton.

![Login Sucess](https://raw.githubusercontent.com/sebCIL/api-with-express/master/img/login.png)

![Invalide Token](https://raw.githubusercontent.com/sebCIL/api-with-express/master/img/InvalideToken.png )

![Consume](https://raw.githubusercontent.com/sebCIL/api-with-express/master/img/consume.png )

License
---

MIT

 

Secure API with Express
===

Example of a secure Node.js API written with the framework Express.

Autenthification from IBMi with [QSYSGETPH](https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_73/apis/QSYGETPH.htm) API.

Signature with [JWT](https://jwt.io/).



Getting started
---

Install the dependencies
```
$ npm install
```
Generate self-sign certificats
```
$ openssl genrsa -out api-with-express-key.pem 2048
```
```
$ openssl req -new -sha256 -key api-with-express-key.pem -out api-with-express-csr.pem
```
```
$ openssl x509 -req -in api-with-express-csr.pem -signkey api-with-express-key.pem -out api-with-express-cert.pem
```

Duplicate the table **QIWS/QCUSTCDT** in your library.

Change configuration in *config* folder :
- port: Port number for HTTP
- port_secure: Port number for HTTPS
- schema: library for QCUSTCDT
- secret: passphrase for encoding/decoding JWT
- jwt_option: Options for signin JWT

Start the project
```
$ npm start 
```

Use it
- First call the /login with profile/password valid on IBMi. 
  - It will return au jwt if login success.
  - If the login fails, it return an error.
- Then call the API with the token 
