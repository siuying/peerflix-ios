var ApiServer = require('./ApiServer')

class TVStreamApp {
  constructor () {
    this.server = new ApiServer()
  }

  start () {
    this.server.start()
  }

  stop () {
    this.server.stop()
  }
}

let tvStreamApp = new TVStreamApp()
tvStreamApp.start()
