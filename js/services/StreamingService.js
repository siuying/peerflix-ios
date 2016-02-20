var url = require('url')
var address = require('network-address')
var FileStream = require('file-stream')
var http = require('http')

var StreamingState = require('../constants/StreamingState')
var Constants = require('../constants/Constants')

function StreamingService (callback) {
  var _httpServer = null
  var _callback = callback
  var _state = {
    status: StreamingState.Idle,
    path: null,
    videoUrl: null,
    files: null
  }

  var service = {
    // Stream a local video via http
    streamFile: function (filePath) {
      if (_httpServer) {
        console.log('close previous streaming file')
        _httpServer.close()
      }

      _httpServer = http.createServer((request, response) => {
        var u = url.parse(request.url)
        if (u.pathname === '/0') {
          if (!FileStream(filePath, request, response)) {
            console.log('Unable to stream', filePath)
            request.statusCode = 500
            request.setHeader('Content-Type', 'text/plain')
            request.end('unable to stream ' + filePath + '\n')
            return
          }
        } else {
          console.log('unexpected filePath: ', u.pathname)
        }
      })
      _httpServer.listen(Constants.TV_STREAM_FILE_STREAM_SERVER_PORT)

      var host = address()
      var videoUrl = `http://${host}:${this.httpServer.address().port}/0`
      _state.path = filePath
      _state.videoUrl = videoUrl
      _state.status = StreamingState.Listening
      this.emitChange()
      console.log('start http streaming', videoUrl)
    },

    // stop streaming
    stopStreamFile: function () {
      if (_httpServer) {
        console.log('stop http streaming')
        _httpServer.close()
        _httpServer = null
      }
      this.reset()
    },

    // Reset torrent when user disconnect
    onDisconnect: function () {
      this.stopStreamFile()
      this.reset()
      this.emitChange()
    },

    reset: function () {
      var state = {}
      state.status = StreamingState.Idle
      state.path = null
      state.videoUrl = null
      state.files = null
      _state = state
    },

    // boardcast changes
    emitChange: function () {
      if (_callback) {
        _callback(this.state)
      }
    }
  }
  return service
}

module.exports = StreamingService
