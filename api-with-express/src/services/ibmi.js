const debug = require("debug")("login");
const { Connection, ProgramCall } = require("itoolkit");
const { parseString } = require("xml2js");
const { resolve } = require("path");
const { rejects } = require("assert");

/**
 * 
 * Error Messages
 * --------------
 * Message ID	Error Message Text
 * CPF2203 E	User profile &1 not correct.
 * CPF2204 E	User profile &1 not found.
 * CPF2213 E	Not able to allocate user profile &1.
 * CPF2225 E	Not able to allocate internal system object.
 * CPF22E2 E	Password not correct for user profile &1.
 * CPF22E3 E	User profile &1 is disabled.
 * CPF22E4 E	Password for user profile &1 has expired.
 * CPF22E5 E	No password associated with user profile &1.
 * CPF22E6 E	Maximum number of profile handles have been generated.
 * CPF22E9 E	*USE authority to user profile &1 required.
 * CPF24B4 E	Severe error while addressing parameter list.
 * CPF3BC7 E	CCSID &1 outside of valid range.
 * CPF3BDE E	CCSID &1 not supported by API.
 * CPF3C1D E	Length specified in parameter &1 not valid.
 * CPF3C3C E	Value for parameter &1 not valid.
 * CPF3C36 E	Number of parameters, &1, entered for this API was not valid.
 * CPF3C90 E	Literal value cannot be changed.
 * CPF3CF1 E	Error code parameter not valid.
 * CPF4AB8 E	Insufficient authority for user profile &1.
 * CPF9872 E	Program or service program &1 in library &2 ended. Reason code &3.
 */

let errorMessages = {
  "CPF2203":	"User profile &1 not correct.",
  "CPF2204":	"User profile &1 not found.",
  "CPF2213":	"Not able to allocate user profile &1.",
  "CPF2225":	"Not able to allocate internal system object.",
  "CPF22E2":	"Password not correct for user profile &1.",
  "CPF22E3":	"User profile &1 is disabled.",
  "CPF22E4":	"Password for user profile &1 has expired.",
  "CPF22E5":	"No password associated with user profile &1.",
  "CPF22E6":	"Maximum number of profile handles have been generated.",
  "CPF22E9":	"*USE authority to user profile &1 required.",
  "CPF24B4":	"Severe error while addressing parameter list.",
  "CPF3BC7":	"CCSID &1 outside of valid range.",
  "CPF3BDE":	"CCSID &1 not supported by API.",
  "CPF3C1D":	"Length specified in parameter &1 not valid.",
  "CPF3C3C":	"Value for parameter &1 not valid.",
  "CPF3C36":	"Number of parameters, &1, entered for this API was not valid.",
  "CPF3C90":	"Literal value cannot be changed.",
  "CPF3CF1":	"Error code parameter not valid.",
  "CPF4AB8":	"Insufficient authority for user profile &1.",
  "CPF9872":	"Program or service program &1 in library &2 ended. Reason code &3.",
};

/**
 * 
 * @param {*} user 
 * @param {*} pw 
 */

function QSYSGETPH(user, pw) {
  return new Promise((resolve, reject) => {
    debug("Authentification");
    const conn = new Connection({
      transport: "idb",
      transportOptions: {
        database: "*LOCAL",
        // username: user.toUpperCase(),
        // password: pw.toUpperCase(),
      },
    });

    const program = new ProgramCall("QSYGETPH", { lib: "QSYS" });

    // User ID	Input	Char(10)
    program.addParam({ value: user.toUpperCase(), type: "10A" });
    // Password	Input	Char(*)
    program.addParam({ value: pw.toUpperCase(), type: "10A" });
    // Profile handle	Output	Char(12)
    program.addParam({ value: "", type: "12A", io: "out", hex: "on" });
    const errno = {
      name: "error_code",
      type: "ds",
      io: "both",
      len: "rec2",
      fields: [
        {
          name: "bytes_provided",
          type: "10i0",
          value: 0,
          setlen: "rec2",
        },
        { name: "bytes_available", type: "10i0", value: 0 },
        { name: "msgid", type: "7A", value: "" },
        { type: "1A", value: "" },
      ],
    };
    // Error code	I/O	Char(*)
    program.addParam(errno);
    // Length of password	Input	Bin(4)
    program.addParam({ value: 10, type: "10i0" });
    // CCSID of password	Input	Bin(4)
    program.addParam({ value: 0, type: "10i0" });

    conn.add(program);

    try {
      conn.run((error, xmlOutput) => {
        if (error) {
          debug("Error login %O", error);
          reject({ error: "Authentification failed" });
        } else {
          parseString(xmlOutput, (parseError, result) => {
            debug("Parse result %j", result);
            if (parseError) {
              debug("Parse error login %O", parseError);
              throw parseError;
            }
            // Return error code if exist
            if (result.myscript.pgm[0].parm[3].ds[0].data[2]._) {
              reject({
                // result: result.myscript.pgm[0].parm[3].ds[0].data[2]._,
                result: "error",
                errorCode: result.myscript.pgm[0].parm[3].ds[0].data[2]._,
                errorMessage:
                  errorMessages[result.myscript.pgm[0].parm[3].ds[0].data[2]._],
              });
            } else {
              resolve({ result: "success" });
            }
          });
        }
      });
    } catch {
      debug("Error login %O", error);
      reject({ error: "Authentification failed" });
    }
  });
}

exports.QSYSGETPH = QSYSGETPH;
