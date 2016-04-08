require('coffee-script')

fs = require('fs')
async = require('async')
lodash = require('lodash')
util = require('util')
colors = require('colors')
SpotifyWeb = require('spotify-web')
mkdirp = require('mkdirp')
Path = require('path')
program = require('commander')
ffmetadata = require("ffmetadata")
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
    @file = {}
    @getTrack()

  getTrack: =>
    @Spotify.get @trackId, (err, track)=>
      if err then return @cb(err)
      @track = track
      @createDirs()

  createDirs: =>
    dir = Path.resolve("#{@directory}")
    artistpath = dir + '/' + @track.artist[0].name.replace(/\//g, ' - ') + '/'
    albumpath = artistpath + @track.album.name.replace(/\//g, ' - ') + ' [' + @track.album.date.year + ']/'
    filepath = albumpath + @track.artist[0].name.replace(/\//g, ' - ') + ' - ' + @track.name.replace(/\//g, ' - ') + '.mp3';

    @file.name = @track.name.replace(/\//g, ' - ')
    @file.path = filepath

    console.log @file
    @Playlist.addTrackToPlaylist(@file)

    if fs.existsSync(filepath)
      stats = fs.statSync(filepath)
      if stats.size != 0
        console.log "Already Downloaded: #{@track.artist[0].name} #{@track.name}".yellow
        return @cb()

    if !fs.existsSync(albumpath)
      mkdirp.sync(albumpath)

    @downloadFile(filepath)

  downloadFile: (filepath)=>
    Log "Downloading: #{@track.artist[0].name} - #{@track.name}"
    out = fs.createWriteStream(filepath)
    d = domain.create()
    d.on 'error', (err)=>
      console.log " - - #{err.toString()} ...  { Skipping Track }".red
      return @cb()
    d.run =>
      @track.play().pipe(out).on 'finish', =>
        Log " - DONE: #{@track.artist[0].name} - #{@track.name}"
        @writeMetaData(filepath)

  writeMetaData: (filepath)=>
    id3 =
      artist: @track.artist[0].name
      album: @track.album.name
      title: @track.name
      date: @track.album.date.year
      track: @track.number
    ffmetadata.write filepath, id3, @cb

  getFileProperties: ()=>
    return @file

class Downloader extends EventEmitter

  constructor: (@username, @password, @playlist, @directory)->
    @Spotify = null
    @Tracks = []
    @dir = @directory
    @makeFolder = false
    @generatePlaylist = false
    @Playlist = new Playlist()

  run: ()=>
    console.log 'Downloader App Started..'.green

    if @generatePlaylist then @Playlist.enabled = true

    async.series [@attemptLogin, @getPlaylist, @processTracks], (err, res)=>
      if err then return Error "#{err.toString()}"
      return Success ' ------- DONE ALL ------- '

  attemptLogin: (cb)=>
    SpotifyWeb.login @username, @password, (err, SpotifyInstance)=>
      if err then return Error("Error logging in... (#{err})")
      @Spotify = SpotifyInstance
      cb?()

  getPlaylist: (cb)=>
    Log 'Getting Playlist Data'
    @Spotify.playlist @playlist, (err, playlistData)=>
      if err then return Error("Playlist data error... #{err}")
      Log "Got Playlist: #{playlistData.attributes.name}"

      if @folder then @dir = @directory + playlistData.attributes.name.replace(/\//g, ' - ') + '/'

      @Playlist.directory = @directory
      @Playlist.name = playlistData.attributes.name

      @Tracks = lodash.map playlistData.contents.items, (item)=>
        return item.uri
      cb?()

  processTracks: (cb)=>
    Log "Processing #{@Tracks.length} Tracks"
    async.mapSeries @Tracks, @processTrack, cb

  processTrack: (track, cb)=>
    TempInstance = new Track(track, @Spotify, @dir, @Playlist, cb)

class Playlist extends EventEmitter

  constructor: ()->
    @enabled = false
    @directory = null
    @name = null
    @playlistFile = null
    @traks = []

  addTrackToPlaylist: (file, cb)=>
    if !@enabled then return
    track = file.path

    playlistFile = @name.replace(/\//g, ' - ') + '.m3u'
    if track.indexOf(@directory) != -1 then relativePath = track.slice(track.indexOf(@directory), track.length)

    fs.appendFile(playlistFile, relativePath + "\n", (err)=>
      if err then throw err
      console.log('The "data to append" was appended to file!')
    )
    cb?()


module.exports = Downloader