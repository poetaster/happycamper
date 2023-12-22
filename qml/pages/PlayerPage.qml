import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          
import QtMultimedia 5.5
import Sailfish.Pickers 1.0

Page {
  id: lyrics_page

  anchors.fill: parent

  property string default_playlist_file: StandardPaths.music + '/happycamper/playlist.pls'

  SilicaListView {
    id: list_view

    width: parent.width

    anchors {
      top: parent.top
      bottom: player_controls_item.top
    }

    PullDownMenu {
      MenuItem {
        text: "Playback settings"
        enabled: true
        onClicked: {
          pageStack.push("VolumePage.qml", {})
        }
      }

      MenuItem {
        visible: true
        text: "Load folder"
        onClicked: {
          pageStack.push(folder_picker_page)
        }
      }

      MenuItem {
        text: "Clear playlist"
        enabled: main_handler.playlist.itemCount > 0
        onClicked: {
          //var remorse = Remorse.popupAction(list_view, "Clear playlist", function() { })
          main_handler.audio_player.stop()
          main_handler.playlist.clear()
        }
      }

      /*MenuItem {
        visible: false
        text: "Load all audio"
        onClicked: {
          main_handler.audio_player.stop()
          main_handler.playlist.clear()
          const local_media = py.get_local_media()
          for (var i = 0; i < local_media.length; i++) {
            main_handler.add_playlist_item(local_media[i])
          }
        }
      }*/

      MenuItem {
        visible: true
        text: "Load playlist"
        onClicked: {
          pageStack.push(file_picker_page)
        }
      }

      MenuItem {
        visible: true
        enabled: main_handler.playlist.itemCount > 0
        text: "Save playlist"
        onClicked: {
          var playlist_items = []
          for (var i = 0; i < main_handler.playlist.itemCount; i++) {
            const media_url = String(main_handler.playlist.itemSource(i))
            const track_id = main_handler.media_file_to_track(media_url)
            var track_info = main_handler.tracks_info[track_id]
            if (!track_info) continue
            track_info.media_url = media_url
            playlist_items.push(track_info)
          }
          console.log(py.save_playlist(default_playlist_file, playlist_items))
        }
      }
    }

    header: Item {
      id: list_header
     
      width: lyrics_page.width
      height: Theme.paddingLarge + album_thumb.height
      
      CachedImage {
        id: album_thumb
        width: lyrics_page.width
        visible: main_handler.player_artwork && main_handler.player_artwork.length && (album_thumb.status == Image.Ready || album_thumb.status == Image.Loading)
        height: visible ? lyrics_page.width : 0
        fillMode: Image.PreserveAspectCrop
        remote_source: main_handler.player_artwork
      }
    }

    model: main_handler.playlist

    delegate: PlayerTrackItem {
      
    }

    ViewPlaceholder {
      enabled: !main_handler.player_available
      text: "No media"
      hintText: "Add media to enable playback."
    }
  }
  
  Item {
    id: player_controls_item

    Rectangle {
      id: background_rectangle
      anchors.fill: parent
      color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
      gradient: Gradient {
        GradientStop { 
          position: 0.0
          color: 'transparent'
        }
        GradientStop { 
          position: 0.8
          color: background_rectangle.color 
        }
      }
    }

    width: lyrics_page.width
    height: childrenRect.height + (Theme.paddingLarge * 3)

    anchors {
      bottom: parent.bottom
    }

    IconButton {                       
      id: play_button                                  
      icon.source: "image://theme/icon-m-play" 
      onClicked: {
        main_handler.audio_player.play()
      }
      enabled: main_handler.player_available
      visible: main_handler.audio_player.playbackState != Audio.PlayingState
      anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: Theme.paddingLarge
      }           
    }

    IconButton {               
      id: pause_button                                    
      icon.source: "image://theme/icon-m-pause"
      onClicked: {
        main_handler.audio_player.pause()
      }
      enabled: main_handler.player_available
      visible: !play_button.visible
      anchors {
        centerIn: play_button
      }         
    }

    IconButton {                       
      id: previous_button                                  
      icon.source: "image://theme/icon-m-previous" 
      onClicked: {
        if (main_handler.audio_player.position > 5000) main_handler.audio_player.seek(0)
        else main_handler.playlist.previous()
      }
      enabled: main_handler.player_available && (main_handler.playlist.currentIndex > 0 || main_handler.audio_player.position > 1)
      anchors {
        verticalCenter: play_button.verticalCenter
        right: play_button.left
        rightMargin: parent.width / 5
      }           
    }

    IconButton {                       
      id: next_button                                  
      icon.source: "image://theme/icon-m-next" 
      onClicked: {
        //main_handler.audio_player.seek(main_handler.audio_player.duration)
        main_handler.playlist.next()
      }
      enabled: main_handler.player_available
      anchors {
        verticalCenter: play_button.verticalCenter
        left: play_button.right
        leftMargin: parent.width / 5
      }           
    }

    Label {
      id: artist_label

      text: main_handler.player_artist_name
      
      font.pixelSize: Theme.fontSizeExtraSmall
      horizontalAlignment: Text.AlignCenter
      anchors {
        bottom: play_button.top
        horizontalCenter: parent.horizontalCenter
        topMargin: Theme.paddingSmall
        bottomMargin: Theme.paddingLarge
      }
    }

    Label {
      id: title_label

      text: main_handler.player_track_name
      font.pixelSize: Theme.fontSizeMedium
      horizontalAlignment: Text.AlignCenter
      anchors {
        bottom: artist_label.top
        horizontalCenter: parent.horizontalCenter
        topMargin: Theme.paddingLarge
        bottomMargin: Theme.paddingSmall
      }
    }

    Slider {
      id: position_slider
      width: parent.width
      enabled: main_handler.player_available
      anchors {
        margins: 0 //Theme.horizontalPageMargin
        bottom: title_label.top
      }

      stepSize: 1000
      minimumValue: 0
      maximumValue: main_handler.audio_player.duration > 0 ? main_handler.audio_player.duration : 500000
      handleVisible: false
      valueText: main_handler.seconds_to_minutes_seconds(Math.round(sliderValue/1000))

      onPositionChanged: {
        
      }

      onReleased: {
        main_handler.audio_player.seek(sliderValue)
      }

      Connections {
        target: main_handler.audio_player
        onPositionChanged: {
          if (position_slider.down) return
          if (Qt.application.active) position_slider.value = main_handler.audio_player.position
        }
      }
    }
  }

  BusyIndicator {
    size: BusyIndicatorSize.Large
    anchors.centerIn: list_view
    running: false
  }

  Component {
    id: file_picker_page
    FilePickerPage {
      title: 'Select playlist file'
      nameFilters: [ '*.m3u', '*.m3u8', '*.pls' ]
      onSelectedContentPropertiesChanged: {
        main_handler.playlist.load(Qt.resolvedUrl(selectedContentProperties.filePath))
      }
    }
  }

  Component {
    id: folder_picker_page
    FolderPickerPage {
      dialogTitle: "Folder"

      onSelectedPathChanged: {
        console.log('folder_picker_page - selected:', selectedPath)
        const local_media = py.get_media_folder_items(selectedPath)
        for (var i = 0; i < local_media.length; i++) {
          main_handler.add_playlist_item(local_media[i])
        }
        main_handler.player_artwork = selectedPath + '/cover.jpg'
      }
    }
  }

  Component.onCompleted: {
    main_handler.player_volume = app.track_volumes["player"] || 1
    main_handler.track_volume = app.track_volumes[main_handler.player_track_id] || 1

    if (main_handler.playlist.itemCount < 1) main_handler.playlist.load(Qt.resolvedUrl(default_playlist_file))
  } 
}
