module.exports = (services, exceptions) => {
  const customersRouter = require("./customers")(services, exceptions);
  const usersRouter = require("./users")(services, exceptions);

  return {
    route(app) {
      app.use(services.utils.parseJSON);
      app.use(services.utils.logRequests);
      app.use(services.utils.enableCors);
      app.use(services.utils.returnApplicationJson);
      
      app.post("/login", usersRouter.login);

      app.use(services.utils.verifyToken);

      app.post("/customers", customersRouter.create);
      app.get("/customers", customersRouter.list);
      app.get("/customers/:id", customersRouter.find);
      app.patch("/customers/:id", customersRouter.update);
      app.put("/customers/:id", customersRouter.update);
      app.delete("/customers/:id", customersRouter.remove);

    }
  };
};
