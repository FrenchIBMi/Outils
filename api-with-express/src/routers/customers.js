const debug = require('debug')('route');

module.exports = ({ customers }, { MissingResourceError, NoDataError }) => {
  return {
    async find(req, res) {
      const { id } = req.params;
      debug('Find customer ', id)
      try {
        const customer = await customers.find(id);
        res.status(200).send(customer);
      } catch (e) {
        res.status(getStatusCode(e)).send({ data: e.data || e.message });
      }
    },

    async list(req, res) {
      const { sort } = req.query;
      debug('List customers ', sort)
      try {
        const customerList = await customers.list(sort);
        res.status(200).send(customerList);
      } catch (e) {
        res.status(getStatusCode(e)).send({ data: e.data || e.message });
      }
    },

    async create(req, res) {
      const { body } = req;
      debug('Create customer %O', body)
      try {
        const id = await customers.create(body);
        res
          .set("Location", `/customers/${id}`)
          .status(201)
          .send();
      } catch (e) {
        res.status(getStatusCode(e)).send({ data: e.data || e.message });
      }
    },

    async remove(req, res) {
      const { id } = req.params;
      debug('Remove customer ', id)
      try {
        await customers.remove(id);
        res.status(204).send();
      } catch (e) {
        res.status(getStatusCode(e)).send({ data: e.data || e.message });
      }
    },

    async update(req, res) {
      const { id } = req.params;
      const { body } = req;
      debug('Update customer %O ',id)
      debug('Update customer %O ',body)
      try {
        await customers.update(id, body);
        res.status(204).send();
      } catch (e) {
        res.status(getStatusCode(e)).send({ data: e.data || e.message });
      }
    }
  };

  function getStatusCode(error) {
    debug('Erreur %O ', error)
    if (error instanceof MissingResourceError) {
      return 404;
    } else if (error instanceof NoDataError) {
      return 204;
    } else {
      return 400;
    }
  }
};
