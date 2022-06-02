'use strict'

const customerController = require('../controllers/customer');

const debug = require('debug')('server:customer');

// Customer Structure
const customer = {
    type: 'object',
    title: 'Customers',
    properties: {
        CUSNUM: { type: 'number', maximum: 9999, examples: ['1234'] },
        LSTNAM: { type: 'string', maxLength: 8, examples: ['Henning'] },
        INIT: { type: 'string', maxLength: 3, examples: ['G K'] },
        STREET: { type: 'string', maxLength: 13, examples: ['4859 Elm Ave'] },
        CITY: { type: 'string', maxLength: 6, examples: ['Dallas'] },
        STATE: { type: 'string', maxLength: 2, examples: ['TX'] },
        ZIPCOD: { type: 'number', maximum: 99999, examples: ['75217'] },
        CDTLMT: { type: 'number', maximum: 9999, examples: ['5000'] },
        CHGCOD: { type: 'number', maximum: 9, examples: ['3'] },
        BALDUE: { type: 'number', maximum: 9999.99, examples: ['37.00'] },
        CDTDUE: { type: 'number', maximum: 9999.99, examples: ['33.50'] }
    },
    required: ['CUSNUM', 'LSTNAM', 'INIT', 'STREET', 'CITY', 'STATE', 'ZIPCOD', 'CDTLMT', 'CHGCOD', 'BALDUE', 'CDTDUE']
}

const routes = [{
    method: 'GET',
    url: '/customer',
    schema: {
        description: 'Retrieve all customers',
        tags: ['Customer'],
        summary: 'Retrieve all customers fom QCUSTCDT',
        response: {
            200:
            {
                type: 'array',
                description: 'Customers',
                items: customer,
            },
            204: {
                type: 'null',
                description: 'No Content'
            },
        }
    },
    handler: customerController.getAllCustomers
},
{
    method: 'GET',
    url: '/customer/:cusnum',
    schema: {
        description: 'Retrieve a specific customer',
        tags: ['Customer'],
        summary: 'Retrieve a specific customer',
        params: {
            cusnum: {
                type: 'number',
                description: 'Customer number'
            }
        },
        response: {
            200: customer,
            204: {
                type: 'null',
                description: 'No Content'
            },
        }
    },
    handler: customerController.getCustomer
},
{
    method: 'POST',
    url: '/customer',
    schema: {
        description: 'Add a customer',
        tags: ['Customer'],
        summary: 'Add a customer',
        body: customer,
        response: {
            400: {
                description: 'JSON incorrect',
                type: 'object',
                properties: {
                    statusCode: { type: 'number' },
                    code: { type: 'string' },
                    error: { type: 'string' },
                    message: { type: 'string' }
                }
            }
        }
    },
    handler: customerController.addCustomer
},
{
    method: 'PUT',
    url: '/customer/:cusnum',
    schema: {
        description: 'Update a specific customer',
        tags: ['Customer'],
        summary: 'Update a specific customer',
        params: {
            cusnum: {
                type: 'number',
                description: 'Customer number'
            }
        },
        body: customer,
        response: {
            200: {
                type: 'null',
                description: 'No Content'
            },
        }
    },
    handler: customerController.updateCustomer
},
{
    method: 'DELETE',
    url: '/customer/:cusnum',
    schema: {
        description: 'Delete a specific customer',
        tags: ['Customer'],
        summary: 'Delete a specific customer',
        params: {
            cusnum: {
                type: 'number',
                description: 'Customer number'
            }
        },
        response: {
            200: {
                type: 'null',
                description: 'No Content'
            },
        }
    },
    handler: customerController.deleteCustomer
}
]
module.exports = routes