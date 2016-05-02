require('coffee-script')

fs = require('fs')
async = require('async')
lodash = require('lodash')
colors = require('colors')
SpotifyWeb = require('spotify-web')
mkdirp = require('mkdirp')
Path = require('path')
id3 = require("node-id3")
domain = require('domain')
Playlist = require('./playlist')
Track = require('./track')
EventEmitter = require('events').EventEmitter


Error = (err)=>
  console.log "#{err}".red
  process.exit(1)

Success = (success)=>
  console.log "#{success}".green
  process.exit(0)

Log = (msg)=>
  if typeof msg == 'undefined'
    return
  console.log " - #{msg}".green

ListProperties = (object)=>
  properties = Object.keys(object);
  Log properties

replaceAll = (search, replacement, target) =>
  return target.replace(new RegExp(search, 'g'), replacement);


class Downloader extends EventEmitter
  constructor: (@username, @password)->
    @Spotify = null
    @trackUrls = []
    @basePath = null
    @playlistPath = null
    @makeFolder = false
    @generatePlaylist = false
    @Playlist = new Playlist()
    @Track = new Track()
    @Track.setPlaylist(@Playlist)

  setPlaylist: (@playlist)=>
  setBasePath: (@basePath)=>
    @setPlaylistPath(@basePath)
  setPlaylistPath: (@playlistPath)=>
  setMakeFolder: (@makeFolder)=>
  setGeneratePlaylist: (@generatePlaylist)=>
    @Playlist.setEnabled(true);

  run: () =>
    Log 'Downloader App Started..'.green
    async.series [@login, @loadSpotifyItem, @processTrackUrls], (err, res)=>
      if err
        Log "#{res.toString()}"
        return Error "#{err.toString()}"

      return Success ' ------- DONE ALL ------- '

  login: (callback)=>
    Log 'Downloader.login '.green
    SpotifyWeb.login @username, @password, (err, SpotifyInstance)=>
      if err
        return Error("Error logging in... (#{err})")
      Log 'Downloader.login ok'.green

      @Spotify = SpotifyInstance
      @Track.setSpotify(@Spotify)

      callback?()

  loadSpotifyItem: (callback)=>
    if @playlist.indexOf('https://play.spotify.com') != -1
      @playlist = @playlist.replace('https://play.spotify.com', 'spotify')
      @playlist = replaceAll('/', ':', @playlist)

    Log @playlist

    if @playlist.indexOf('album') != -1
      @loadAlbum(callback)
    else if @playlist.indexOf('track') != -1
      @loadTrack(callback)
    else
      @loadPlaylist(callback)

  loadTrack: (callback)=>
    Log 'Getting Track Data'

    #    do not create playlist for 1 track
    @Playlist.setEnabled(false)

    @trackUrls = [@playlist]

    callback?()

  loadPlaylist: (callback)=>
    Log 'Getting Playlist Data'

    @Spotify.playlist @playlist, 0, 9001, (err, playlistData)=>
      if err
        return Error("Playlist data error... #{err}")

      Log "Got Playlist: #{playlistData.attributes.name}"

      @Playlist.setName(playlistData.attributes.name)

      if @makeFolder
        @playlistPath = @basePath + '/' + playlistData.attributes.name.replace(/\//g, ' - ') + '/'
        @Track.setDirectory(@playlistPath)

      @Playlist.directory = @basePath
      @Playlist.name = playlistData.attributes.name

      @trackUrls = lodash.map playlistData.contents.items, (item)=>
        return item.uri

      callback?()

  loadAlbum: (callback)=>
    Log 'Getting Album Data'

    @Spotify.get @playlist, (err, album)=>
      if err
        return Error("Album data error... #{err}")

      Log "Got Album: #{album.name}"
      Log "#{album}"

      tracks = []
      album.disc.forEach (disc)=>
        if (Array.isArray(disc.track))
          tracks.push.apply(tracks, disc.track);

      @trackUrls = lodash.map tracks, (track)=>
        return track.uri

      @Playlist.setName(album.name)

      if @makeFolder
        @playlistPath = @basePath + '/' + album.name.replace(/\//g, ' - ') + '/'
        @Track.setDirectory(@playlistPath)

      @Playlist.directory = @basePath
      @Playlist.name = album.name

      callback?()

  processTrackUrls: (callback) =>
    Log "Processing #{@trackUrls.length} Tracks"
    async.mapSeries(@trackUrls, @processTrack, callback)

  processTrack: (trackUrl, callback)=>
    Log 'Downloader.processTrack '.green
    @Track.process(trackUrl, callback)
#    track = new Track(trackUrl, @Spotify, @dir, @Playlist, cb)

module.exports = Downloader