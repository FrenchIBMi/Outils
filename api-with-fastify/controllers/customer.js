'use strict'

const odbc = require('odbc');
const debug = require('debug')('server:customer');

const config = require('config');

const SERVER_DSN = config.get('server.dsn');
const SERVER_ADDRESS = config.get('server.host');
const SERVER_PORT = config.get('server.port');
const BIBLIOTHEQUE = config.get('server.bib');

const getAllCustomers = async (request, reply) => {

  debug(`Get all customers`);

  let result;
  let error;

  // Connect to the local database
  const connection = await odbc.connect(`${SERVER_DSN}`);

  try {
    result = await connection.query('SELECT * FROM ' + BIBLIOTHEQUE + '.QCUSTCDT');
  } catch (e) {
    debug(`error execute : ${e.odbcErrors[0].code}`);
    error = new Error();
    error.message = e.odbcErrors[0].message;
    reply.code(400).send(error);
  }
  debug(`result : ${JSON.stringify(result)}`);

  await connection.close();

  if (result.count > 0) {
    reply.status('200').send(result)
  } else {
    reply.status('204').send(result)
  }

}

// Get a customer
const getCustomer = async (request, reply) => {

  debug(`Get a customer : ${JSON.stringify(request.params)}`);

  let result;
  let error;

  // Connect to the local database
  const connection = await odbc.connect(`${SERVER_DSN}`);

  try {
    result = await connection.query('SELECT * FROM ' + BIBLIOTHEQUE + '.QCUSTCDT where cusnum = ?', [Number(request.params.cusnum)]);
  } catch (e) {
    debug(`error execute : ${e.odbcErrors[0].code}`);
    error = new Error();
    error.message = e.odbcErrors[0].message;
    reply.code(400).send(error);
  }

  debug(`result : ${JSON.stringify(result)}`);

  await connection.close();

  if (result.count > 0) {
    reply.status('200').send(result[0])
  } else {
    reply.status('204').send(result[0])
  }

}

// Add a customer
const addCustomer = async (request, reply) => {

  debug(`Add a customer ${JSON.stringify(request.params)}`);
  let result;
  let error;

  // Connect to the local database
  const connection = await odbc.connect(`${SERVER_DSN}`);
  const statement = await connection.createStatement();

  try {
    await statement.prepare('INSERT INTO '
      + BIBLIOTHEQUE
      + '.QCUSTCDT ('
      + 'CUSNUM, LSTNAM, INIT, STREET, CITY, STATE, ZIPCOD, CDTLMT, CHGCOD, BALDUE, CDTDUE'
      + ') values ('
      + '?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )');
  } catch (e) {
    debug(`error prepare : ${e.odbcErrors[0].message}`);
    error = new Error();
    error.message = e.odbcErrors[0].message;
    reply.code(400).send(error)
  }

  try {
    await statement.bind([request.body.CUSNUM,
    request.body.LSTNAM,
    request.body.INIT,
    request.body.STREET,
    request.body.CITY,
    request.body.STATE,
    request.body.ZIPCOD,
    request.body.CDTLMT,
    request.body.CHGCOD,
    request.body.BALDUE,
    request.body.CDTDUE,
    ]);
  } catch (e) {
    debug(`error bind : ${JSON.stringify(e)}`);
    error = new Error();
    error.message = e.odbcErrors[0].message;
    reply.code(400).send(error);
  }

  try {
    result = await statement.execute();
  } catch (e) {
    debug(`error execute : ${e.odbcErrors[0].code}`);
    error = new Error();
    error.message = e.odbcErrors[0].message;
    reply.code(400).send(error);
  }
  debug(`result : ${result}`);

  await statement.close();
  await connection.close();

  reply.status('201').send('Created')

}

// Delete a customer
const deleteCustomer = async (request, reply) => {

  debug(`Delete a customer : ${JSON.stringify(request.params)}`);

  let result;
  let error;

  // Connect to the local database
  const connection = await odbc.connect(`${SERVER_DSN}`);

  try {
    result = await connection.query('DELETE FROM ' + BIBLIOTHEQUE + '.QCUSTCDT where cusnum = ?', [Number(request.params.cusnum)]);
  } catch (e) {
    debug(`error execute : ${e.odbcErrors[0].code}`);
    error = new Error();
    error.message = e.odbcErrors[0].message;
    reply.code(400).send(error);
  }

  debug(`result : ${JSON.stringify(result)}`);

  await connection.close();

  if (result.count > 0) {
    reply.status('200').send()
  } else {
    reply.status('204').send(result[0])
  }

}

// Update a customer
const updateCustomer = async (request, reply) => {

  debug(`Update a customer : ${JSON.stringify(request.params)}`);
  debug(`Body : ${JSON.stringify(request.body)}`);

  let result;
  let error;

  // Connect to the local database
  const connection = await odbc.connect(`${SERVER_DSN}`);
  const statement = await connection.createStatement();

  try {
    await statement.prepare('UPDATE '
      + BIBLIOTHEQUE
      + '.QCUSTCDT set'
      + ' CUSNUM = ?, LSTNAM = ?, INIT = ?, STREET = ?, CITY = ?, STATE = ?, ZIPCOD = ?, CDTLMT = ?, CHGCOD = ?, BALDUE = ?, CDTDUE = ?'
      + ' where cusnum = ?');
      debug('prepare')      
  } catch (e) {
    debug(`error prepare : ${e.odbcErrors[0].message}`);
    error = new Error();
    error.message = e.odbcErrors[0].message;
    reply.code(400).send(error)
  }
  
  try {
    await statement.bind([request.body.CUSNUM,
    request.body.LSTNAM,
    request.body.INIT,
    request.body.STREET,
    request.body.CITY,
    request.body.STATE,
    request.body.ZIPCOD,
    request.body.CDTLMT,
    request.body.CHGCOD,
    request.body.BALDUE,
    request.body.CDTDUE,
    request.params.cusnum
    ]);
  } catch (e) {
    debug(`error bind : ${JSON.stringify(e)}`);
    error = new Error();
    error.message = e;
    reply.code(400).send(error);
  }

  try {
    result = await statement.execute();
  } catch (e) {
    debug(`error execute : ${e.odbcErrors[0].code}`);
    error = new Error();
    error.message = e.odbcErrors[0].message;
    reply.code(400).send(error);
  }
  debug(`result : ${JSON.stringify(result)}`);

  await connection.close();

  if (result.count > 0) {
    reply.status('200').send()
  } else {
    reply.status('204').send(result[0])
  }

}

module.exports = {
  getAllCustomers,
  getCustomer,
  addCustomer,
  deleteCustomer,
  updateCustomer
}