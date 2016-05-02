#!/usr/bin/env node

require('coffee-script')

require('colors')
Program 	= require('commander')
Downloader	= require('./lib/downloader')

getUserHome = =>
	if process.platform is 'win32' then return process.env['USERPROFILE']
	return process.env['HOME']

Program
	.version('0.1.0')
	.option('-u, --username [username]', 'Spotify Username (required)', null)
	.option('-p, --password [password]', 'Spotify Password (required)', null)
	.option('-l, --link 		[link/uri]', 'Spotify URI for playlist, album or track', null)
	.option('-d, --directory [directory]', "Directory you want to save the mp3s to, default: #{getUserHome()}/spotify-mp3s", "#{getUserHome()}/spotify-mp3s")
	.option('-f, --folder', "create folder for playlist", null)
	.option('-g, --generate', "generate file for playlist", null)
	.parse( process.argv )

USERNAME = Program.username
PASSWORD = Program.password
PLAYLIST = Program.link
DIRECTORY = Program.directory
FOLDER = Program.folder
GENERATE = Program.generate

if !PASSWORD? or !USERNAME?
	console.log '!!! MUST SPECIFY USERNAME & PASSWORD !!!'.red
	return Program.outputHelp()

if !PLAYLIST?
	console.log '!!! MUST SPECIFY A SPOTIFY PLAYLIST !!!'.red
	return Program.outputHelp()

console.log('init')
Downloader = new Downloader( USERNAME, PASSWORD, PLAYLIST, DIRECTORY )
Downloader.setPlaylist(PLAYLIST)
Downloader.setBasePath(DIRECTORY)
Downloader.setMakeFolder(FOLDER ? true : false)
Downloader.setGeneratePlaylist(GENERATE ? true : false)

console.log('run')
Downloader.run()