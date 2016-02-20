import Constants from './constants/Constants'

import http from 'http'
import ApiServer from 'apiserver'
import _ from 'lodash'

var Mobile = require('./helpers/Mobile')

import Commands from './constants/Commands'
import MetadataService from './services/MetadataService'
import TorrentService from './services/TorrentService'
import StreamingService from './services/StreamingService'

class TvApiServer {
  constructor () {
    this.connected = false
    this.httpServer = null
    this.apiServer = null
    this.torrentService = null
    this.advertisement = null
  }

  // Start up API & WebSocket server
  start () {
    console.log(`start server at ${Constants.TV_STREAM_SERVER_PORT}`)

    this.httpServer = http.createServer()
    this.httpServer.listen(Constants.TV_STREAM_SERVER_PORT)

    // Config API server
    this.apiServer = new ApiServer({ server: this.httpServer })
    this.apiServer.use(ApiServer.payloadParser())
    this.apiServer.addModule('1', 'metadata', MetadataService)
    this.apiServer.router.addRoutes([
      ['/search', '1/metadata#search'],
      ['/metadata', '1/metadata#metadata']
    ])

    this.apiServer.addModule('1', 'torrent', {
      play: {
        get: (request, response) => {
          let url = request.querystring.url
          try {
            this.torrentService.openTorrentUrl(url)
            response.serveJSON({success: true})
          } catch (error) {
            response.serveJSON({success: false, error: error})
          }
        }
      },

      stop: {
        get: (request, response) => {
          try {
            this.torrentService.closeTorrent()
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
            this.torrentService.selectFile(filename)
            response.serveJSON({success: true})
          } catch (error) {
            response.serveJSON({success: false, error: error})
          }
        }
      }
    })
    this.apiServer.router.addRoutes([
      ['/torrent/play', '1/torrent#play'],
      ['/torrent/stop', '1/torrent#stop'],
      ['/torrent/select', '1/torrent#select']
    ])

    this.httpServer.listen(Constants.TV_STREAM_SERVER_PORT)

    // Setup Torrent Service
    // boardcast change of torrent state, throttled to at max 1s per update
    let torrentOnEmit = _.throttle((data) => {
      this.boardcast(data)
    }, 1000)
    this.torrentService = new TorrentService(torrentOnEmit)
    this.streamingService = new StreamingService()
    this.boardcast(this.torrentService.state)
  }

  // Stop servers
  stop () {
    if (this.torrentService) {
      this.torrentService.onDisconnect()
      this.torrentService = null
    }

    if (this.streamingService) {
      this.streamingService.onDisconnect()
      this.streamingService = null
    }

    if (this.httpServer) {
      this.httpServer.close()
      this.httpServer = null
    }
  }

  onConnected () {
    this.connected = true
  }

  onDisconnect () {
    this.connected = false
    if (this.torrentService) {
      this.torrentService.onDisconnect()
    }
  }

  boardcast (message) {
    if (typeof message === 'undefined') {
      console.warn('message cannot be null!')
      return
    }

    var update = Mobile('UpdateTorrentState')
    update.call.apply(update, [JSON.stringify(message)])
  }
}

module.exports = TvApiServer
