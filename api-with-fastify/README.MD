# api-with-fastify
Squelette d'API avec Fastify et documentation OpenAPI

Cette api est basée sur [Fastify](https://www.fastify.io/), [fastify-swagger](https://www.npmjs.com/package/fastify-swagger), [ODBC](https://ibmi-oss-docs.readthedocs.io/).

If you set exposeRoute to true the plugin will expose the documentation with the following APIs:

URL Description :
- '/documentation/json' : The JSON object representing the API
- '/documentation/yaml' :  The YAML object representing the API
- '/documentation/'  : The swagger UI
- '/documentation/*'  : External files that you may use in $ref


Commencer
---

Installation des dépendences
```
$ npm install
```
Generation des certificats auto-signé, se placer dans le répertoire "HTTPS"
```
$ openssl genrsa -out api-key.pem 2048
```
```
$ openssl req -new -sha256 -key api-key.pem -out api-csr.pem
```
```
$ openssl x509 -req -in api-csr.pem -signkey api-key.pem -out api-cert.pem
```

Copier la table **QIWS/QCUSTCDT** dans votre bibliothèque.

Modifier la configuration dans le répertoire *config* :
- port: Port découte en HTTP
- port_secure: Port découte en HTTPS
- dsn : connexion ODBC
- schema: bibliothèque pour QCUSTCDT

Exécuter le projet
```
$ npm start 
```