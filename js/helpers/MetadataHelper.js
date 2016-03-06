var MovieDB = require('moviedb')
//import TVDB from 'node-tvdb'

var MovieNameWithYearRegexp = /^(.+)((19|20)[0-9]{2})/
var TvNameRegexp = /^(.+)(S|s)([0-9]{1,2})(E|e)([0-9]{1,2})/

try {
  // check if the api key file is defined
  var APIKeys = require('../constants/ApiKeys')
} catch (e) {
  // use default api key
  console.warn('Please copy ./app/browser/constant/APIKeys.detault.js to ./app/browser/constant/APIKeys.js and set all services API keys!')
}

function cleanupName (name) {
  return name.replace(/[\(\)]/g, '').replace(/\./g, ' ').trim()
}

function parseFilename (filename) {
  const tvMatch = filename.match(TvNameRegexp)
  if (tvMatch) {
    let type = 'tv'
    let name = cleanupName(tvMatch[1])
    let season = tvMatch[3] ? Number(tvMatch[3]) : null
    let episode = tvMatch[5] ? Number(tvMatch[5]) : null
    return {type: type, name: name, season: season, episode: episode}
  }

  const movieMatch = filename.match(MovieNameWithYearRegexp)
  if (movieMatch) {
    let name = cleanupName(movieMatch[1])
    let year = movieMatch[2]
    if (year) {
      year = Number(year)
    }
    let type = 'movie'
    return {type: type, name: name, year: year}
  }

  return {type: 'unknown', name: cleanupName(filename)}
}

function fetchMovieData (metadata, callback) {
  let APIKeys = require('../constants/ApiKeys')
  console.log('API Keys', APIKeys.MovieDB)
  var movieDB = MovieDB(APIKeys.MovieDB)
  movieDB.searchMovie({query: metadata.name, year: metadata.year}, (error, res) => {
    if (res && res.results && res.results.length > 0) {
      var movieResult = res.results[0]
      console.log('result', movieResult)
      movieDB.movieInfo({id: movieResult.id}, (error, movie) => {
        if (error) {
          console.log('error fetching movie', error)
          callback(metadata, error)
          return
        }

        console.log('movie', movie)
        metadata.imdb_id = movie.imdb_id.replace(/tt/, '')
        metadata.name = movie.title
        metadata.overview = movie.overview
        if (movie.poster_path) {
          metadata.poster_path = `https://image.tmdb.org/t/p/w396${movie.poster_path}`
        }
        if (movie.backdrop_path) {
          metadata.backdrop_path = `https://image.tmdb.org/t/p/w780${movie.backdrop_path}`
        }
        callback(metadata, null)
      })
    } else {
      console.log('no result!', error);
      callback(metadata, error)
    }
  })
}

// function fetchTvData (metadata, callback) {
//   var tvdb = new TVDB(APIKeys.TVDB)
//   tvdb.getSeriesByName(metadata.name, (error, results) => {
//     if (error) {
//       console.error('error fetching tv data', error)
//       callback(metadata, error)
//       return
//     }
//
//     if (results && results.length > 0) {
//       var show = results[0]
//       metadata.imdb_id = show.IMDB_ID.replace(/tt/, '')
//       metadata.name = show.SeriesName
//       metadata.overview = show.Overview
//       metadata.backdrop_path = `http://thetvdb.com/banners/${show.banner}`
//       callback(metadata, null)
//     } else {
//       callback(metadata, null)
//     }
//   })
// }

var MetadataHelper = {
  search: function (name, callback) {
    var metadata = parseFilename(name)

    if (metadata.type === 'movie') {
      fetchMovieData(metadata, callback)
    // } else if (metadata.type === 'tv') {
    //   fetchTvData(metadata, callback)
    } else {
      callback(metadata)
    }
  }
}

module.exports = MetadataHelper
