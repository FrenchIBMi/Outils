const express = require("express");
const helmet = require("helmet");
const env = process.env.NODE_ENV || "developement";

module.exports = async () => {
  const logger = require("./src/logger")(env);
  const exceptions = require("./src/services/exceptions");
  const services = require("./src/services")(
    logger,
    exceptions
  );
  const { route } = require("./src/routers")(services, exceptions);

  const app = express();

  app.use(helmet());
  app.disable("x-powered-by");

  route(app);

  return app;
};
