require('coffee-script')

fs = require('fs')
EventEmitter = require('events').EventEmitter

class Playlist extends EventEmitter

  constructor: ()->
    @enabled = false
    @directory = null
    @name = null
    @playlistFile = null
    @traks = []

  setEnabled: (@enabled)=>
  setName: (@name)=>
    @playlistFile = @name.replace(/\//g, ' - ') + '.m3u'

  addTrackToPlaylist: (file, callback)=>
    if !@enabled
      return

    track = file.path

    relativePath = 'test'
    if track.indexOf(@directory) != -1
      relativePath = track.slice(track.indexOf(@directory), track.length)

    fs.appendFile(@playlistFile, relativePath + "\n", (err)=>
      if err then throw err
    )
    callback?()


module.exports = Playlist