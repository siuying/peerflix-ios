var Mobile = require('./helpers/Mobile')
var path = require('path')

// see jxcore.java - jxcore.m
process.setPaths();
jxcore.tasks.register(process.setPaths);
process.natives.defineEventCB("eventPing", Mobile.ping);

var loadMainFile = function (filePath) {
  var mainFile = path.join(process.cwd(), filePath)
  try {
    require(mainFile);
  } catch (e) {
    Error.captureStackTrace(e);
    Mobile('OnError').call(e.message, JSON.stringify(e.stack));
    console.error("loadMainFile Error", mainFile, e);
  }
};

process.on('uncaughtException', function (e) {
  Error.captureStackTrace(e);
  Mobile('OnError').call(e.message, JSON.stringify(e.stack));
  console.error("ERROR: ", e);
});

Mobile('StartApplication').register(loadMainFile);
