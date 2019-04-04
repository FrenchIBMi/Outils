const bunyan = require("bunyan");
const config = require('config');
const appname = config.get('appname');

module.exports = conf => {
  const logLevel = process.env.LOG_LEVEL || "info";
  return bunyan.createLogger({ name: appname, level: logLevel });
};
