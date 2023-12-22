import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          
import QtMultimedia 5.5

ListItem {
  id: list_item
  property var track_info
  property string track_name
  property string album_name
  property string artist_name
  property int duration

  height: Theme.itemSizeMedium + context_menu.height 

  Label {
    id: duration_label
    width: parent.width / 6
    visible: true
    text: main_handler.seconds_to_minutes_seconds(duration / 1000)
    color: index == main_handler.playlist.currentIndex ? Theme.highlightColor : Theme.primaryColor
    font.pixelSize: Theme.fontSizeLarge
    horizontalAlignment: Text.AlignRight
    anchors {
      top: parent.top
      leftMargin: Theme.paddingMedium
    }
  }

  Label {
    id: title_label
    color: index == main_handler.playlist.currentIndex ? Theme.highlightColor : Theme.primaryColor
    text: track_name
    font.pixelSize: Theme.fontSizeMedium
    truncationMode: TruncationMode.Fade
    fontSizeMode: Text.Fit
    minimumPixelSize: Theme.fontSizeExtraSmall
    horizontalAlignment: Text.AlignCenter
    anchors {
      top: parent.top
      left: duration_label.right
      right: parent.right
      leftMargin: Theme.paddingMedium
      rightMargin: Theme.paddingMedium
    }
  }
  
  Label {
    id: artist_label
    visible: Boolean(artist_name)
    color: index == main_handler.playlist.currentIndex ? Theme.highlightColor : Theme.primaryColor
    text: artist_name
    font.pixelSize: Theme.fontSizeExtraSmall
    truncationMode: TruncationMode.Fade
    horizontalAlignment: Text.AlignCenter
    anchors {
      top: title_label.bottom
      left: duration_label.right
      right: parent.right
      leftMargin: Theme.paddingMedium
      rightMargin: Theme.paddingMedium
    }
  }

  menu: ContextMenu {
    id: context_menu

    MenuItem {
      visible: true
      text: "Remove from playlist"
      onClicked: {
        main_handler.playlist.removeItem(index)
      }
    }
  }

  onClicked: {
    main_handler.playlist.currentIndex = index
    main_handler.audio_player.play()
  }

  Audio {
    id: audio_preloader

    onDurationChanged: {
      list_item.duration = duration
      track_info.duration = duration
      console.log('audio_preloader duration:', duration)
      audio_preloader.destroy()
    }

    metaData.onTitleChanged: {
      if (!metaData.title) return;
      console.log('audio_preloader metadata track:', metaData.title, 'duration:', duration)
      track_name = metaData.title
      track_info.track = metaData.title
    }

    metaData.onAlbumTitleChanged: {
      if (!metaData.albumTitle) return;
      console.log('audio_preloader metadata album:', metaData.albumTitle)
      album_name = metaData.albumTitle
      track_info.album = metaData.albumTitle
    }

    metaData.onContributingArtistChanged: {
      if (!metaData.contributingArtist) return;
      console.log('audio_preloader metadata contributingArtist:', metaData.contributingArtist)
      artist_name = metaData.contributingArtist
      track_info.artist = metaData.contributingArtist
    }

    metaData.onAlbumArtistChanged: {
      if (!metaData.albumArtist) return;
      console.log('audio_preloader metadata albumArtist:', metaData.albumArtist)
      artist_name = metaData.albumArtist
      track_info.artist = metaData.albumArtist
    }

    metaData.onCoverArtUrlLargeChanged: {
      if (!metaData.coverArtUrlLarge) return;
      console.log('audio_preloader metadata coverArtUrlLarge:', metaData.coverArtUrlLarge)
      track_info.artwork = metaData.coverArtUrlLarge
    }

    metaData.onCoverArtUrlSmallChanged: {
      if (!metaData.coverArtUrlSmall || track_info.artwork) return;
      console.log('audio_preloader metadata coverArtUrlSmall:', metaData.coverArtUrlSmall)
      track_info.artwork = metaData.coverArtUrlSmall
    }
  }

  Component.onCompleted: {
    const track_id = main_handler.media_file_to_track(source)
    track_info = main_handler.tracks_info[track_id] || main_handler.tracks_info[source]
    

    if (track_id && !track_info) track_info = main_handler.get_track_info(track_id)    
    if (!track_info) {
      // try using our hack.
      const path = source.toString()
      const info = py.get_track_id3(path.slice(7))

      track_info = {
        'track': main_handler.basename(source),
        'album': '',
        'artist': '',
        'artwork': main_handler.player_artwork,
        'duration': null,
      }
      if (info['title']) track_info['track'] = info['title']
      if (info['album']) track_info['album'] = info['album']
      if (info['artist']) track_info['artist'] = info['artist']

      if (track_id) main_handler.tracks_info[track_id] = track_info
      else main_handler.tracks_info[source] = track_info
    }

    artist_name = track_info.artist
    track_name = track_info.track
    if (track_info.duration) duration = track_info.duration

    console.log('loading source data:', source, 'track:', track_id, 'name:', track_info.track)

    if (!duration) audio_preloader.source = source
  }
}
