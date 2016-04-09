require('coffee-script')

fs = require('fs')
async = require('async')
lodash = require('lodash')
colors = require('colors')
mkdirp = require('mkdirp')
Path = require('path')
id3 = require("node-id3")
domain = require('domain')
EventEmitter = require('events').EventEmitter


Error = (err)=>
  console.log "#{err}".red
  process.exit(1)

Success = (success)=>
  console.log "#{success}".green
  process.exit(0)

Log = (msg)=>
  console.log " - #{msg}".green


class Track extends EventEmitter

  constructor: (@trackId, @Spotify, @directory, @Playlist, @cb, @track = {})->
    @Spotify = null
    @Playlist = null
    @directory = null
    @track = null
    @file = {}
    @retryCounter = 0
#    @getTrack()

  setSpotify: (@Spotify)=>
  setPlaylist: (@Playlist)=>
  setDirectory: (@directory)=>

  reset: ()=>
    @track = null

  process: (@trackId, @callback)=>
    @Spotify.get @trackId, (err, track)=>
      if err
        return @callback(err)

      @track = track
      @createDirs()

  createDirs: =>
    dir = Path.resolve("#{@directory}")

    artistPath = dir + '/' + @track.artist[0].name.replace(/\//g, ' - ') + '/'
    albumPath = artistPath + @track.album.name.replace(/\//g, ' - ') + ' [' + @track.album.date.year + ']/'
    filePath = albumPath + @track.artist[0].name.replace(/\//g, ' - ') + ' - ' + @track.name.replace(/\//g, ' - ') + '.mp3';

    @file.name = @track.name.replace(/\//g, ' - ')
    @file.path = filePath

    @Playlist.addTrackToPlaylist(@file)

    if fs.existsSync(filePath)
      stats = fs.statSync(filePath)
      if stats.size != 0
        Log "Already Downloaded: #{@track.artist[0].name} #{@track.name}".yellow
        return @callback()

    if !fs.existsSync(albumPath)
      mkdirp.sync(albumPath)

    @downloadFile(filePath)

  downloadFile: (filePath)=>
    Log "Downloading: #{@track.artist[0].name} - #{@track.name}"
    d = domain.create()
    d.on 'error', (err)=>
      Log " Error received " + (err.toString()).red
      if err.toString().indexOf("Rate limited") > -1
        Log " - - " + (err.toString()) + " ...  { Retrying in 10 seconds }".yellow
        if @retryCounter < 2
          @retryCounter++
          setTimeout(@downloadFile(filePath), 1000)
        else
          return @callback()
      else
        return @callback()
    d.run =>
      out = fs.createWriteStream(filePath)
      try
        @track.play().pipe(out).on 'finish', =>
          Log " - DONE: #{@track.artist[0].name} - #{@track.name}"
          @writeMetaData(filePath)
#          meta =
#            artist: @track.artist[0].name
#            album: @track.album.name
#            title: @track.name
#            year: @track.album.date.year
#            trackNumber: @track.number
#
#          id3.write(meta, filePath)
#          return @callback?()
      catch error
        Log "Error #{error} on download track  #{@track.artist[0].name} ...".red

        return @callback?()

  writeMetaData: (filePath)=>
    meta =
      artist: @track.artist[0].name
      album: @track.album.name
      title: @track.name
      year: @track.album.date.year
      track: @track.number

    id3.write meta, filePath
    return @callback?()

  getFileProperties: ()=>
    return @file

module.exports = Track