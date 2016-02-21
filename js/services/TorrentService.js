var peerflix = require('peerflix')
var address = require('network-address')
var process = require('process')
var readTorrent = require('read-torrent')
var _ = require('lodash')

var Mobile = require('../helpers/Mobile')
var TorrentStates = require('../constants/TorrentStates')
var Constants = require('../constants/Constants')

// Streaming torrent to client
function TorrentService (callback) {
  var _callback = callback
  var _engine = null
  var _engineRemoveListener = null
  var _refreshTorrent = null
  var _temp = "/tmp/torrent-stream"

  var setTemp = Mobile('SetTemp')
  if (setTemp.register) {
    setTemp.register(function(path) {
      console.log("temp folder:", path)
      _temp = path
    })
  }

  var service = {
    state: {
      status: TorrentStates.Idle,
      torrentUrl: null,
      videoUrl: null,
      files: null,
      selectedFile: null,
      hotswaps: 0,
      verified: 0,
      invalid: 0,
      filename: null,
      size: 0,
      downloadSpeed: 0,
      downloaded: 0,
      uploaded: 0
    },

    // open a torrent using URL
    openTorrentUrl: function (url) {
      console.log('open torrent url', url)

      if (this.torrentUrl === url) {
        console.log('already loading this url: ', url)
        return
      }

      if (_engine) {
        this.closeTorrent()
      }

      this.state.videoUrl = null
      this.state.torrentUrl = url
      this.state.status = TorrentStates.LoadingMetadata
      this.emitChange()

      if (/^magnet:/.test(url)) {
        this.onTorrent(url)
      } else if (/^http/.test(url) || /torrent$/.test(url)) {
        console.log('loading torrent ...', url)
        readTorrent(url, (error, torrent) => {
          if (error) {
            console.log('error opening torrent', error)
            return
          }

          console.log('loaded torrent')
          this.onTorrent(torrent)
        })
      } else {
        console.log('unsupported format', url)
        // todo: error handling
      }
    },

    // file, the file name to select
    selectFile: function (filename) {
      if (!_engine) {
        return
      }

      var theFile = _.first(_.filter(_engine.files, (f) => { return f.name === filename }))
      if (!theFile) {
        console.log(`File not found!  ${filename}, from: ${this.state.files}`)
        return
      }

      console.log('select file: ', theFile.name)
      theFile.select()
      _engine.server.index = theFile
      this.state.filename = theFile.name.split('/').pop().replace(/\{|\}/g, '')
      this.state.size = theFile.length
      this.emitChange()
    },

    // when user quit
    closeTorrent: function () {
      if (_engine) {
        console.log('stop torrent')
        try {
          // cleanup the abort listener
          if (_engineRemoveListener) {
            process.removeListener('SIGINT', _engineRemoveListener)
            process.removeListener('SIGTERM', _engineRemoveListener)
            _engineRemoveListener = null
          }

          // cleanup refresh torrent
          if (_refreshTorrent) {
            clearInterval(_refreshTorrent)
            _refreshTorrent = null
          }

          // cleanup and destroy the engine
          var engineToRemove = _engine
          engineToRemove.server.close(function () {
            console.log('shutdown stream server...')
            engineToRemove.remove(function () {
              console.log('removed torrent files ...')
              engineToRemove.destroy(function () {
                console.log('shutdown torrent')
              })
            })
          })
        } catch (e) {
          console.warn('catched error on cleanup', e)
        }
        _engine = null
      }
      this.reset()
    },

    // Reset torrent when user disconnect
    onDisconnect: function () {
      this.closeTorrent()
      this.reset()
      this.emitChange()
    },

    onTorrent: function (torrent) {
      var engine = peerflix(torrent, {
        tmp: _temp,
        port: Constants.TV_STREAM_TORRENT_SERVER_PORT
      })
      console.log('start peerflix')

      var store = this
      var swarm = engine.swarm
      engine.on('hotswap', () => {
        store.state.hotswaps++
      })
      engine.on('error', (error) => {
        console.log('error: ', error)
      })
      engine.on('verify', () => {
        store.state.verified++
      })
      engine.on('invalid-piece', () => {
        store.state.invalid++
      })
      engine.server.on('listening', () => {
        var host = address()
        var videoUrl = `http://${host}:${engine.server.address().port}/`
        store.state.status = TorrentStates.Listening
        store.state.videoUrl = videoUrl
        store.state.files = engine.files.map((file, index) => {
          return {name: file.name, length: file.length, url: `${videoUrl}${index}`}
        })
        store.emitChange()
        console.log(`Listening at: ${videoUrl}, status=${store.state.status}`)
      })
      function onready () {
        store.state.filename = engine.server.index.name.split('/').pop().replace(/\{|\}/g, '')
        store.state.size = engine.server.index.length
        store.state.files = engine.files.map((file, index) => {
          return {name: file.name, length: file.length}
        })
        store.selectFile(engine.server.index.name)
      }
      if (engine.torrent) {
        onready()
      } else {
        engine.on('ready', onready)
      }

      var refreshTorrent = setInterval(() => {
        store.state.downloadSpeed = swarm.downloadSpeed()
        store.state.downloaded = swarm.downloaded
        store.state.uploaded = swarm.uploaded
        store.emitChange()
      }, 1000)

      // setup a remove callback on exit
      var engineRemoveListener = function () {
        clearInterval(refreshTorrent)
        engine.remove(() => {
          engine.destroy(() => {
            console.log('cleanup completed.')
          })
        })
      }
      process.on('SIGINT', engineRemoveListener)
      process.on('SIGTERM', engineRemoveListener)
      _refreshTorrent = refreshTorrent
      _engineRemoveListener = engineRemoveListener
      _engine = engine
    },

    reset: function () {
      var state = {}
      state.status = TorrentStates.Idle
      state.torrentUrl = null
      state.videoUrl = null
      state.files = null
      state.selectedFile = null
      state.hotswaps = 0
      state.verified = 0
      state.invalid = 0
      state.filename = null
      state.size = 0
      state.downloadSpeed = 0
      state.downloaded = 0
      state.uploaded = 0
      this.state = state
    },

    // boardcast changes
    emitChange: function () {
      if (_callback) {
        _callback(this.state)
      } else {
        console.log('no callback registered in TorrentService')
      }
    }
  }

  return service
}

module.exports = TorrentService
