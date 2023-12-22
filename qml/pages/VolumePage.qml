import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          
import QtMultimedia 5.6

Page {
  id: volume_page

  anchors.fill: parent

  SilicaFlickable {
    id: flickable

    anchors.fill: parent

    VerticalScrollDecorator { 
      flickable: flickable 
    }

    Column {
      width: parent.width
      height: parent.height

      SectionHeader {
        text: "Shuffle and repeat"
      }

      Row {
        id: row
        width: parent.width
        height: Theme.itemSizeLarge

        Switch {
          width: parent.width / 2
          anchors.bottom: parent.bottom
          icon.source: "image://theme/icon-m-shuffle"
          automaticCheck: false
          checked: main_handler.playlist.playbackMode == Playlist.Random
          onClicked: {
            if (checked) main_handler.playlist.playbackMode = Playlist.Sequential
            else main_handler.playlist.playbackMode = Playlist.Random
          }
        }

        Switch {
          width: parent.width / 2
          anchors.bottom: parent.bottom
          icon.source: main_handler.playlist.playbackMode == Playlist.CurrentItemInLoop ? "image://theme/icon-m-repeat-single" : "image://theme/icon-m-repeat"
          automaticCheck: false
          checked: main_handler.playlist.playbackMode == Playlist.CurrentItemInLoop || main_handler.playlist.playbackMode == Playlist.Loop
          
          onClicked: {
            console.log('checked:', checked, 'mode:',main_handler.playlist.playbackMode )
            if (checked) {
              if (main_handler.playlist.playbackMode == Playlist.Loop) main_handler.playlist.playbackMode = Playlist.CurrentItemInLoop
              else main_handler.playlist.playbackMode = Playlist.Sequential
            } else {
              main_handler.playlist.playbackMode = Playlist.Loop
            }
          }
        }
      }

      SectionHeader {
        text: "Playback rate"
      }

      Slider {
        id: playback_rate
        width: parent.width

        stepSize: 0.1
        minimumValue: 0.5
        maximumValue: 2.0
        handleVisible: true
        valueText: Math.round(sliderValue * 100) + ' %'
        value: main_handler.audio_player.playbackRate

        onReleased: {
          console.log('Playback rate:', sliderValue)
          main_handler.audio_player.playbackRate = sliderValue
        }
      }

      SectionHeader {
        text: "Output volume"
      }

      ProgressBar {
        width: parent.width
        minimumValue: 0.0
        maximumValue: 1.0
        value: main_handler.audio_player.volume
        valueText: Math.round(main_handler.audio_player.volume * 100) + ' %'
      }

      SectionHeader {
        text: "Player volume"
      }

      Slider {
        id: player_volume_slider
        width: parent.width

        stepSize: 0.05
        minimumValue: 0.0
        maximumValue: 1.0
        handleVisible: true
        valueText: Math.round(sliderValue * 100) + ' %'
        value: main_handler.player_volume

        onPositionChanged: {
          main_handler.player_volume = sliderValue
          app.track_volumes["player"] = sliderValue
        }
      }
      
      SectionHeader {
        text: "Track volume"
      }
      
      Slider {
        id: track_volume_slider
        width: parent.width

        stepSize: 0.05
        minimumValue: 0.0
        maximumValue: 2.0
        handleVisible: enabled
        valueText: Math.round(sliderValue * 100) + ' %'
        value: main_handler.track_volume
        label: main_handler.player_track_name
        enabled: Boolean(main_handler.player_track_id > 0)

        onPositionChanged: {
          main_handler.track_volume = sliderValue
          app.track_volumes[String(main_handler.player_track_id)] = sliderValue
        }
      }      
    }

    Component.onCompleted: {

    }
  }
}
