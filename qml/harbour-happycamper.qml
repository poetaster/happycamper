import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4
import Nemo.DBus 2.0

import "pages"

ApplicationWindow {
    initialPage: Component { MainPage { }  }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

   property bool debug: false
   property var notificationObj
   notificationObj: pageStack.currentPage.notification
   property var musicFolder: StandardPaths.MusicLocation

   MainHandler {
     id: main_handler
   }

    Python {
        id: py

        Component.onCompleted: {

            console.log(musicFolder)

            addImportPath(Qt.resolvedUrl('../lib/'));
            importModule('happy', function () {});

            // Handlers do something to QML whith received Infos from Pythonfile (=pyotherside.send)
            setHandler('homePathFolder', function( homeDir ) {
                tempAudioFolderPath = homeDir + "/.cache/de.poetaster/happycamper/"
                saveAudioFolderPath = homeDir + "/Music/"
                homeDirectory = homeDir
                //py.createTmpAndSaveFolder(tempAudioFolderPath, saveAudioFolderPath )
                //py.createTmpAndSaveFolder( )
                //py.deleteAllTMPFunction(tempAudioFolderPath)
            });

            setHandler('downloadCompleted', function() {
                notificationObj.notify("Download completed")
            });

            setHandler('copiedToClipboard', function() {
                clipboardAvailable = true
            });

            setHandler('trackQueue', function(queue) {
                console.log(queue)
            });
            setHandler('currentDir', function(dir) {
                console.log(dir)
            });

            setHandler('error', error_handler);

        }

        function error_handler(module_id, method_id, description) {
          console.log('Module ERROR - source:', module_id, method_id, 'error:', description);
          //app.signal_error(module_id, method_id, description);
        }

        // file operations
        function download_url(url,dir) {
            call("happy.download_url", [url,dir])
        }

        function get_media_folder_items(folder_path) {
           return call_sync('happy.get_media_folder_items', [folder_path]);
         }

        function get_local_media(track_id, video_id) {
          var params = []
          if (track_id) {
            params.push(track_id)
            if (video_id) params.push(video_id)
          }
          return call_sync('happy.get_local_media', params);
        }
        // this is a fint to get track info using ID3 tags.
        function get_track_cache(media_url) {
          return call_sync('happy.get_track_info', [media_url])
        }

        function save_playlist(file_name, playlist_items) {
          return call_sync('happy.save_playlist', [file_name, playlist_items])
        }
        function get_home_path() {
            call("happy.get_home_path", [])
        }
        onError: {
            // when an exception is raised, this error handler will be called
            console.log('python error: ' + traceback);
        }
        onReceived: {
            // asychronous messages from Python arrive here via pyotherside.send()
            console.log('got message from python: ' + data);
        }
    } // end python

}
