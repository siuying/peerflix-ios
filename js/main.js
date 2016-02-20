var path = require('path')

var loadMainFile = function (filePath) {
  var mainFile = path.join(process.cwd(), filePath)
  try {
    require(mainFile);
  } catch (e) {
    console.error("loadMainFile Error", mainFile, e);
  }
};

if (process.natives) {
  var Mobile = require('./js/helpers/Mobile')

  // see jxcore.java - jxcore.m
  if (process.setPath) {
    process.setPaths();
    jxcore.tasks.register(process.setPaths);
  }

  process.on('uncaughtException', function (e) {
    Error.captureStackTrace(e);
    Mobile('OnError').call(e.message, JSON.stringify(e.stack));
    console.error("ERROR: ", e);
  });

  process.natives.defineEventCB("eventPing", Mobile.ping);
  Mobile('StartApplication').register(loadMainFile);

} else {
  loadMainFile('./app.js');
}
