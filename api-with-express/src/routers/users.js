const debug = require('debug')('route');

module.exports = ({ users }, { MissingResourceError, AuthError }) => {
  return {
    async login(req, res) {
      const { body } = req;
      debug('User login %O', body)
      try {
        const user = await users.login(body);
        res.status(200).send(user);
      } catch (e) {
        res.status(getStatusCode(e)).send({ data: e.data || e.message });
      }
    }
  };

  function getStatusCode(error) {
    debug('Erreur %O ', error)
    if (error instanceof MissingResourceError) {
      return 404;
    } else if (error instanceof AuthError) {
      return 401;
    } else {
      return 400;
    }
  }
};
