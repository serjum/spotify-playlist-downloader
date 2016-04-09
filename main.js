#!/usr/bin/env node


// Generated by CoffeeScript 1.10.0
(function() {
  var DIRECTORY, Downloader, FOLDER, GENERATE, PASSWORD, PLAYLIST, Program, USERNAME, getUserHome;

  require('coffee-script');

  require('colors');

  Program = require('commander');

  Downloader = require('./lib/downloader');

  getUserHome = (function(_this) {
    return function() {
      if (process.platform === 'win32') {
        return process.env['USERPROFILE'];
      }
      return process.env['HOME'];
    };
  })(this);

  Program.version('0.0.2').option('-u, --username [username]', 'Spotify Username (required)', null).option('-p, --password [password]', 'Spotify Password (required)', null).option('-l, --playlist [playlist]', 'Spotify URI for playlist', null).option('-d, --directory [directory]', "Directory you want to save the mp3s to, default: " + (getUserHome()) + "/spotify-mp3s", (getUserHome()) + "/spotify-mp3s").option('-f, --folder', "create folder for playlist", null).option('-g, --generate', "generate file for playlist", null).parse(process.argv);

  USERNAME = Program.username;

  PASSWORD = Program.password;

  PLAYLIST = Program.playlist;

  DIRECTORY = Program.directory;

  FOLDER = Program.folder;

  GENERATE = Program.generate;

  if ((PASSWORD == null) || (USERNAME == null)) {
    console.log('!!! MUST SPECIFY USERNAME & PASSWORD !!!'.red);
    return Program.outputHelp();
  }

  if (PLAYLIST == null) {
    console.log('!!! MUST SPECIFY A SPOTIFY PLAYLIST !!!'.red);
    return Program.outputHelp();
  }

  console.log('init');

  Downloader = new Downloader(USERNAME, PASSWORD, PLAYLIST, DIRECTORY);

  Downloader.setPlaylist(PLAYLIST);

  Downloader.setBasePath(DIRECTORY);

  Downloader.setMakeFolder(FOLDER != null ? FOLDER : {
    "true": false
  });

  Downloader.setGeneratePlaylist(GENERATE != null ? GENERATE : {
    "true": false
  });

  console.log('run');

  Downloader.run();

}).call(this);

//# sourceMappingURL=main.js.map
