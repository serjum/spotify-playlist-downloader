# This tool does not working anymore


# Spotify Playlist Downloader

Download an entire spotify playlists, albums or tracks ( FROM SPOTIFY @ 160kbps ) to your local machine.

Also upon download it writes the ID3 data to the file.

###To install:
Install nodejs if you haven't already. ( [NodeJS Downloads](http://nodejs.org/download/) )

	npm install -g spotify-playlist-downloader

###Available Options

	Usage: spotify-playlist-downloader [options]
	
	Options:

	    -h, --help                   output usage information
	    -V, --version                output the version number
	    -u, --username [username]    Spotify Username (required)
	    -p, --password [password]    Spotify Password (required)
	    -l, --link 	   [link/uri]    Spotify URI for playlist, album or track
	    -d, --directory [directory]  Directory you want to save the mp3s to, default: HOME/spotify-mp3s
	    -g, --generate               Generate m3u playlist file
	


####So :
    if you wanted to download playlist "Top 100 Hip-Hop Tracks on Spotify". You would use the following command:

	spd -u yourusername -p yourpassword -l spotify:user:spotify:playlist:06KmJWiQhL0XiV6QQAHsmw
	OR
	spd -u yourusername -p yourpassword -l https://play.spotify.com/user/spotify/playlist/06KmJWiQhL0XiV6QQAHsmw


    if you wanted to download album "Epiphany". You would use the following command:

	spd -u yourusername -p yourpassword -l spotify:album:44Z1ZEmOyois0QoAgfUxrD
	OR
	spd -u yourusername -p yourpassword -l https://play.spotify.com/album/44Z1ZEmOyois0QoAgfUxrD

    if you wanted to download track "2Pac I Get Around". You would use the following command:

	spd -u yourusername -p yourpassword -l spotify:track:74kHlIr01X459gqsSdNilW
	OR
	spd -u yourusername -p yourpassword -l https://play.spotify.com/track/74kHlIr01X459gqsSdNilW

`spd` is the shorthand for `spotify-playlist-downloader`. You can use either one.

####The output should look something like:

![image](spotify-downloader.png)



###Must haves:

- ~~Spotify Premium Account ( haven't tried it on a free account )~~
- Tested on Ubuntu 14.04 and Windows XP ( Should work on Mac OSX)

### Disclaimer:

- This was done purely as an academic exercise.
- I do not recommend you doing this illegally or against Spotify's terms of service.
