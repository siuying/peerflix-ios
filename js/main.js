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
  // for some reason the path here is relative to path of the app, not the actual file
  var Mobile = require('./js/helpers/Mobile')

  // see jxcore.java - jxcore.m
  process.setPaths();
  jxcore.tasks.register(process.setPaths);

  console.log("versions", process.versions)

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
