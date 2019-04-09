const cors = require("cors");
const bodyParser = require("body-parser");
const debug = require('debug')('utils');
const config = require('config');
const secret = config.get('secret');
const jwt = require('jsonwebtoken');
const options = config.get('jwt_option');

module.exports = logger => {
  return {
    parseJSON: bodyParser.json(),
    logRequests: (req, res, next) => {
      logger.debug({
        method: req.method,
        host: req.headers.host,
        url: req.url,
        useragent: req.headers["user-agent"]
      });
      next();
    },
    enableCors: cors(),
    returnApplicationJson: (req, res, next) => {
      res.set("Content-Type", "application/json");
      next();
    },
    verifyToken: (req, res, next) => {
      debug('Verify Token');
      let token = req.headers['x-access-token'] || req.headers['authorization']; // Express headers are auto converted to lowercase
      if (token && token.startsWith('Bearer ')) {
        // Remove Bearer from string
        token = token.split(" ")[1];
        debug('Token : %O', token);
        jwt.verify(token, secret, options, function(err, decoded) {
          if (err) {
            result = { 
              error: `Authentication error. Invalid Token.`,
              status: 401
            };
            res.status(401).send(result);
            throw new Error();
          }
        });
      } else {
        result = { 
          error: `Authentication error. Token required.`,
          status: 401
        };
        res.status(401).send(result);
        throw new Error();
      }
      next();
    }
  };
};
