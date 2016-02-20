var Mobile = require('./helpers/Mobile')
var path = require('path')

// see jxcore.java - jxcore.m
process.setPaths();
jxcore.tasks.register(process.setPaths);
process.natives.defineEventCB("eventPing", Mobile.ping);

var loadMainFile = function (filePath) {
  try {
    console.error("loading main file", path.join(process.cwd(), filePath));
    require(path.join(process.cwd(), filePath));
    console.error("finished");
  } catch (e) {
    Error.captureStackTrace(e);
    Mobile('OnError').call(e.message, JSON.stringify(e.stack));
    console.error("loadMainFile Error", e);
  }
};

process.on('uncaughtException', function (e) {
  Error.captureStackTrace(e);
  Mobile('OnError').call(e.message, JSON.stringify(e.stack));
});

Mobile('StartApplication').register(loadMainFile);
