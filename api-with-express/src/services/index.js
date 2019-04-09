module.exports = (logger, exceptions) => {
  return {
    customers: require("./customers")(exceptions),
    users: require("./users")(exceptions),
    utils: require("./utils")(logger)
  };
};
