var Constants = require('./constants/Constants')

var http = require('http')
var ApiServer = require('apiserver')
var _ = require('lodash')

var Mobile = require('./helpers/Mobile')

var MetadataService = require('./services/MetadataService')
var TorrentService = require('./services/TorrentService')
var StreamingService = require('./services/StreamingService')

function TvApiServer () {
  var _httpServer = null
  var _apiServer = null
  var _torrentService = null
  var _streamingService = null

  var TvApiServer = {
    // Start up API & WebSocket server
    start: function () {
      console.log(`start server at ${Constants.TV_STREAM_SERVER_PORT}`)

      _httpServer = http.createServer()
      _httpServer.listen(Constants.TV_STREAM_SERVER_PORT)

      // Config API server
      _apiServer = new ApiServer({ server: _httpServer })
      _apiServer.use(ApiServer.payloadParser())
      _apiServer.addModule('1', 'metadata', MetadataService)
      _apiServer.router.addRoutes([
        ['/search', '1/metadata#search'],
        ['/metadata', '1/metadata#metadata']
      ])

      _apiServer.addModule('1', 'torrent', {
        play: {
          get: (request, response) => {
            var url = request.querystring.url
            try {
              _torrentService.openTorrentUrl(url)
              response.serveJSON({success: true})
            } catch (error) {
              response.serveJSON({success: false, error: error})
            }
          }
        },

        stop: {
          get: (request, response) => {
            try {
              _torrentService.closeTorrent()
              response.serveJSON({success: true})
            } catch (error) {
              response.serveJSON({success: false, error: error})
            }
          }
        },

        select: {
          get: (request, response) => {
            try {
              let filename = request.querystring.filename
              _torrentService.selectFile(filename)
              response.serveJSON({success: true})
            } catch (error) {
              response.serveJSON({success: false, error: error})
            }
          }
        }
      })
      _apiServer.router.addRoutes([
        ['/torrent/play', '1/torrent#play'],
        ['/torrent/stop', '1/torrent#stop'],
        ['/torrent/select', '1/torrent#select']
      ])

      _httpServer.listen(Constants.TV_STREAM_SERVER_PORT)

      // Setup Torrent Service
      // boardcast change of torrent state, throttled to at max 1s per update
      var service = this
      let torrentOnEmit = _.throttle(function (data) {
        service.boardcast(data)
      }, 1000)
      _torrentService = TorrentService(torrentOnEmit)
      _streamingService = StreamingService()
      this.boardcast(_torrentService.state)
    },

    // Stop servers
    stop: function () {
      if (_torrentService) {
        _torrentService.onDisconnect()
        _torrentService = null
      }

      if (_streamingService) {
        _streamingService.onDisconnect()
        _streamingService = null
      }

      if (_httpServer) {
        _httpServer.close()
        _httpServer = null
      }
    },

    boardcast: function (message) {
      if (typeof message === 'undefined') {
        console.warn('message cannot be null!')
        return
      }

      var update = Mobile('UpdateTorrentState')
      if (update) {
        update.call.apply(update, [JSON.stringify(message)])
      } else {
        console.log("UpdateTorrentState", message)
      }
    }
  }

  return TvApiServer
}

module.exports = TvApiServer
