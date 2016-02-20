function JXmobile(x) {
  if (!(this instanceof JXmobile)) return new JXmobile(x);

  this.name = x;
}

function callJXcoreNative(name, args) {
  var params = Array.prototype.slice.call(args, 0);

  var cb = "";

  if (params.length && typeof params[params.length - 1] == "function") {
    cb = "$$jxcore_callback_" + JXmobile.eventId;
    JXmobile.eventId++;
    JXmobile.eventId %= 1e5;
    JXmobile.on(cb, new WrapFunction(cb, params[params.length - 1]));
    params.pop();
  }

  var fnc = [name];
  var arr = fnc.concat(params);
  arr.push(cb);

  process.natives.callJXcoreNative.apply(null, arr);
}

function WrapFunction(cb, fnc) {
  this.fnc = fnc;
  this.cb = cb;

  var _this = this;
  this.callback = function () {
    var ret_val = _this.fnc.apply(null, arguments);
    delete JXmobile.events[_this.cb];
    return ret_val;
  }
}

JXmobile.events = {};
JXmobile.eventId = 0;
JXmobile.on = function (name, target) {
  JXmobile.events[name] = target;
};

JXmobile.prototype.call = function () {
  callJXcoreNative(this.name, arguments);
  return this;
};

JXmobile.ping = function (name, param) {
  var x;
  if (Array.isArray(param)) {
    x = param;
  } else if (param.str) {
    x = [param.str];
  } else if (param.json) {
    try {
      x = [JSON.parse(param.json)];
    } catch (e) {
      return e;
    }
  } else {
    x = null;
  }

  if (JXmobile.events.hasOwnProperty(name)) {
    var target = JXmobile.events[name];

    if (target instanceof WrapFunction) {
      return target.callback.apply(target, x);
    } else {
      return target.apply(null, x);
    }
  } else {
    console.warn(name, "wasn't registered");
  }
};

JXmobile.prototype.register = function (target) {
  JXmobile.events[this.name] = target;
  return this;
};

module.exports = JXmobile
