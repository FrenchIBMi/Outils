function QSYSGETPH(user, pw, cb){
  var xt = require('itoolkit')
  var conn = new xt.iConn("*LOCAL");
  var pgm = new xt.iPgm("QSYGETPH",{"lib":"QSYS","error":"off"})
  pgm.addParam(user.toUpperCase(), "10A")
  pgm.addParam(pw.toUpperCase(), "10A")   
  pgm.addParam("", "12A", {"io":"out", "hex":"on"}) 
  var errno = [
    [0, "10i0"],
    [0, "10i0", {"setlen":"rec2"}],
    ["", "7A"],
    ["", "1A"]
  ];
  pgm.addParam(errno, {"io":"both", "len" : "rec2"});
  pgm.addParam(10, "10i0")
  pgm.addParam(0, "10i0")
  conn.add(pgm.toXML())
  conn.run(function(str) {
    var results = xt.xmlToJson(str)
    cb(null, results[0].success)
  }, true) // <---- set to sync for now because bug in iToolkit.  Hapijs hangs if this isn't done.
}
  
exports.QSYSGETPH = QSYSGETPH