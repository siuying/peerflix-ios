import url from 'url'
import address from 'network-address'
import FileStream from 'file-stream'
import http from 'http'

import StreamingState from '../constants/StreamingState'
import Constants from '../constants/Constants'

// Streaming video file to client
class StreamingService {
  constructor (callback) {
    this.httpServer = null
    this.callback = callback
    this.reset()
  }

  // Stream a local video via http
  streamFile (filePath) {
    if (this.httpServer) {
      console.log('close previous streaming file')
      this.httpServer.close()
    }

    this.httpServer = http.createServer((request, response) => {
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
    this.httpServer.listen(Constants.TV_STREAM_FILE_STREAM_SERVER_PORT)

    var host = address()
    var videoUrl = `http://${host}:${this.httpServer.address().port}/0`
    this.state.path = filePath
    this.state.videoUrl = videoUrl
    this.state.status = StreamingState.Listening
    this.emitChange()
    console.log('start http streaming', videoUrl)
  }

  // stop streaming
  stopStreamFile () {
    if (this.httpServer) {
      console.log('stop http streaming')
      this.httpServer.close()
      this.httpServer = null
    }
    this.reset()
  }

  // Reset torrent when user disconnect
  onDisconnect () {
    this.stopStreamFile()
    this.reset()
    this.emitChange()
  }

  reset () {
    var state = {}
    state.status = StreamingState.Idle
    state.path = null
    state.videoUrl = null
    state.files = null
    this.state = state
  }

  // boardcast changes
  emitChange () {
    if (this.callback) {
      this.callback(this.state)
    }
  }
}

export default StreamingService
