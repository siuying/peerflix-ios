var TorrentFinder = require('torrent-finder')
var MetadataHelper = require('../helpers/MetadataHelper')

var SearchEngines = [
  new TorrentFinder.Piratebay({baseUrl: 'https://thepiratebay.la/'}),
  new TorrentFinder.Kickass(),
  new TorrentFinder.Dmhy(),
  new TorrentFinder.Nyaa()
]

// RESTful API Modules
var MetadataService = {
  search: {
    get: function (request, response) {
      let engineCode = request.querystring.engine
      let query = request.querystring.query
      var searcher = SearchEngines.find((e) => e.name() === engineCode)
      if (searcher == null) {
        console.log(`Searcher for ${engineCode} not found`)
        searcher = SearchEngines[0]
      }

      searcher.search(query).then((torrents) => {
        response.serveJSON({success: true, query: query, engine: engineCode, torrents: torrents})
      }).catch((error) => {
        response.serveJSON({success: false, error: error})
      })
    }
  },

  metadata: {
    get: function (request, response) {
      let query = request.querystring.query
      MetadataHelper.search(query, (result, error) => {
        if (error) {
          response.serveJSON({success: false, error: error})
        } else {
          response.serveJSON({success: true, query: query, result: result})
        }
      })
    }
  }
}

module.exports = MetadataService
