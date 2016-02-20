import alt from '../alt'

class SubtitleActions {
  constructor () {
    this.generateActions(
      'search',
      'selectSubtitleById',
      'download'
    )
  }
}

module.exports = alt.createActions(SubtitleActions)
