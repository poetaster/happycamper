import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import Amber.Mpris 1.0

Item {
  id: main_handler

  property string player_media_file
  property string player_track_id
  property string player_track_name
  property string player_album_id
  property string player_album_name
  property string player_artist_id
  property string player_artist_name
  property string player_artwork

  property alias audio_player: audio_player_item
  property alias playlist: playlist_item
  property var tracks_info: {'_null': null}

  property bool player_available: playlist_item.itemCount > 0
  
  property double player_volume: 1
  property double track_volume: 1

  Audio {
    id: audio_player_item
    //source: player_media_file

    playlist: Playlist {
      id: playlist_item
      playbackMode: Playlist.Sequential

      onCurrentItemSourceChanged: {
        console.log('CurrentItemSourceChanged:', currentItemSource)
        const track_id = media_file_to_track(currentItemSource)
        var track_info = tracks_info[track_id] || tracks_info[currentItemSource]

        // shortcut vis id3 method
        //if (!track_info) track_info = get_track_id3(currentItemSource);
        if (!track_info && track_id) track_info = get_track_info(track_id);
        if (!track_info) return;

        player_track_id = track_id || 0
        player_track_name = track_info.track || ''
        player_album_name = track_info.album || ''
        player_artist_name = track_info.artist || ''
        player_artwork = track_info.artwork || ''
        track_volume = app.track_volumes[track_id] || 1
        player_volume = app.track_volumes["player"] || 1
      }

      onItemInserted: function(start_index, end_index) {
        console.log('ItemInserted:', start_index, end_index, currentIndex)
        if (currentIndex > -1 && (start_index < currentIndex || end_index > currentIndex)) return;

        for (var i = start_index; i <= end_index; i++) {
          if (currentIndex == -1 || i == 0) {
            const track_id = media_file_to_track(itemSource(i))
            console.log('ItemInserted track_id:', track_id)
            if (!track_id) return;
            const track_info = get_track_info(track_id)
            console.log('ItemInserted track_info:', track_info)
            if (!track_info) return;
            //player_artwork = track_info.artwork
            break
          }
        }
      }

      onItemRemoved: function(start_index, end_index) {
        if (itemCount == 0) {
          player_track_id = 0
          player_track_name = ''
          player_album_name = ''
          player_artist_name = ''
          player_artwork = ''
          track_volume = 1
        }
      }

      onLoadFailed: function() {
        console.log('loadFailed ERROR:', error, '/', errorString);
      }

      onLoaded: function() {
        
      }
    }

    onPlaying: {
      mpris.playbackStatus = Mpris.Playing
    }

    onPaused: {
      mpris.playbackStatus = Mpris.Paused
    }

    onStopped: {
      mpris.playbackStatus = Mpris.Stopped
    }

    onDurationChanged: {
      const track_info = tracks_info[media_file_to_track(playlist_item.currentItemSource)] || tracks_info[playlist_item.currentItemSource]
      if (!track_info || track_info.duration) return;
      track_info.duration = duration
    }
  }

  MprisPlayer {
    id: mpris

    serviceName: "happycamper"
    identity: "Happy Camper"
    supportedUriSchemes: ["file"]
    supportedMimeTypes: ["audio/x-wav", "audio/mpeg", "audio/x-vorbis+ogg"]

    canControl: true
    canGoNext: playlist_item.itemCount > 0
    canGoPrevious: playlist_item.itemCount > 0 || audio_player_item.position > 1
    canPause: true
    canPlay: playlist_item.itemCount > 0
    canSeek: false
    canQuit: false
    canRaise: false
    hasTrackList: true
    playbackStatus: Mpris.Stopped
    loopStatus: Mpris.LoopNone
    shuffle: false
    volume: 1.0

    onPauseRequested: {
      audio_player_item.pause();
    }

    onPlayRequested: {
      audio_player_item.play()
    }

    onPlayPauseRequested: { 
      if (audio_player_item.playbackState === Audio.PlayingState) audio_player_item.pause();
      else audio_player_item.play();
    }

    onStopRequested: {
      audio_player_item.stop();
    }

    onNextRequested: {
      console.log('mpris next')
      playlist.next()
    }

    onPreviousRequested: {
      console.log('mpris previous')
      if (audio_player_item.position > 5000) audio_player_item.seek(0)
      else playlist.previous()
    }
  }

  onPlayer_media_fileChanged: {
    mpris.canSeek = audio_player_item.seekable
  }

  onPlayer_track_nameChanged: {
    mpris.metaData.title = player_track_name
    console.log('mpris track:', player_track_name)
  }

  onPlayer_album_nameChanged: {
    mpris.metaData.albumTitle = player_album_name
  }

  onPlayer_artist_nameChanged: {
    mpris.metaData.contributingArtist = player_artist_name
    console.log('mpris artist:', player_artist_name)
  }

  onPlayer_artworkChanged: {
    mpris.metaData.artUrl = player_artwork
    console.log('mpris artUrl:', player_artwork)
  }

  onPlayer_volumeChanged: {
    main_handler.audio_player.volume = player_volume * track_volume
  }

  onTrack_volumeChanged: {
    main_handler.audio_player.volume = player_volume * track_volume
  }

  function seconds_to_minutes_seconds(total_seconds) {
    if (isNaN(total_seconds)) return "00:00"
    var minutes = Math.floor(total_seconds / 60)
    var seconds = Math.floor(total_seconds % 60)

    return minutes + ":" + ("00" + seconds).slice(-2)
  }

  function seconds_to_hms(total_seconds) {
    if (isNaN(total_seconds)) return "00:00"
    var hours = Math.floor(total_seconds / 3600)
    total_seconds %= 3600;
    var minutes = Math.floor(total_seconds / 60)
    var seconds = Math.floor(total_seconds % 60)

    if (hours > 0) return  hours + ":" + ("00" + minutes).slice(-2) + ":" + ("00" + seconds).slice(-2)
    return minutes + ":" + ("00" + seconds).slice(-2)
  }

  function basename(file_path) {
    return String(file_path).slice(String(file_path).lastIndexOf('/')+1)
  }

  function media_file_to_track(file_path) {
    if (!file_path) return null
    const track_a = String(file_path).match(/track_(\d+)_.+$/)
    if (!track_a || !track_a.length) return null
    return track_a[1]
  }

  function get_track_info(track_id) {
    return null;
    const track_info = py.get_track_cache(track_id)
    if (!track_info) return null;
    return {
      'track': track_info.strTrack,
      'album': track_info.strAlbum,
      'artist': track_info.strArtist,
      'artwork': track_info.album ? String(track_info.album.strAlbumThumbHQ || track_info.album.strAlbumThumb) : null,
      'duration': null,
    }
  }

  function get_track_id3(media_url) {
    const track_info = py.get_track_id3(media_url)
    if (!track_info) return null;
    return {
      'track': track_info.title,
      'album': track_info.album,
      'artist': track_info.artist,
      'artwork': track_info.album ? String(track_info.album.strAlbumThumbHQ || track_info.album.strAlbumThumb) : null,
      'duration': null,
    }
  }
  function replace_playlist(media_file, track_info) {
    playlist.clear()
    return add_playlist_item(media_file, track_info)
  }

  function add_playlist_item(media_file, track_info_provided) {
    if (!track_info_provided) {
      const track_id = main_handler.media_file_to_track(media_file)
      if (track_id) {
        const track_info = py.get_track_cache(track_id)
        if (!track_info) return false;  
        tracks_info[track_id] = {
          'track': track_info.strTrack,
          'album': track_info.strAlbum,
          'artist': track_info.strArtist,
          'artwork': track_info.album ? String(track_info.album.strAlbumThumbHQ || track_info.album.strAlbumThumb) : null,
          'duration': null,
        }
      }
    } else {
      tracks_info[track_info_provided.track_id] = track_info_provided
    }

    playlist.addItem(Qt.resolvedUrl(media_file))
  }

  Component.onCompleted: {

  }
}
