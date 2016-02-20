import alt from '../alt'
import subtitler from 'subtitler'

import SubtitleActions from '../actions/SubtitleActions'

class SubtitleStore {
  constructor () {
    this.bindActions(SubtitleActions)

    this.languages = 'eng'
    this.subtitles = null
    this.loading = false
    this.downloadedSubtitlePath = null

    // login with opensubtitler
    this.subtitler = subtitler.api.login().then((token) => {
      this.token = token
    })
  }

  onCloseTorrent () {
    this.subtitles = null
    this.loading = false
    this.selectedSubtitle = null
  }

  onSelectSubtitleById (id) {
    this.selectedSubtitle = this.subtitles.find((sub) => sub.id === id)
  }

  onSearch (query) {
    if (query.imdb_id) {
      this.loading = true

      if (query.season && query.episode) {
        this.performSearch({imdbid: String(query.imdb_id), query: query.name, seasion: query.season, episode: query.episode, sublanguageid: this.languages})
      } else {
        this.performSearch({imdbid: String(query.imdb_id), query: query.name, sublanguageid: this.languages})
      }
      return
    }

    if (query.name) {
      console.log('search with name: ', query.name)
      this.loading = true
      this.performSearch({query: query.name, sublanguageid: this.languages})
      return
    }
    console.log('unknown query', query)
  }

  // perform the search using subtitler
  performSearch (query) {
    console.log('perform search ...', query)

    var handleSearchResult = function (results) {
      this.loading = false
      this.subtitles = results.map((sub) => {
        // SubDownloadLink is a .gz file URL,
        // rename it to .srt so that it will download the .srt format
        // (opensubtitle support conversion automatically)
        return {
          id: sub.IDSubtitleFile,
          name: sub.SubFileName,
          format: sub.SubFormat,
          language: sub.LanguageName,
          downloads: Number(sub.SubDownloadsCnt),
          url: sub.SubDownloadLink.replace(/\.gz$/, '.srt')
        }
      }).sort((a, b) => b.downloads - a.downloads) // sort by downloads

      // find a default
      if (results.length > 0) {
        this.selectedSubtitle = this.subtitles[0]
        SubtitleActions.selectSubtitleById(this.selectedSubtitle.id)
        console.log('found subtitles', this.subtitles)
      }

      this.emitChange()
    }

    return this.subtitler
      .then(() => subtitler.api.search(this.token, 'eng', query))
      .then(handleSearchResult.bind(this))
  }
}

module.exports = alt.createStore(SubtitleStore, 'SubtitleStore')
