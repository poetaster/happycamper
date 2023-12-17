import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4
import "pages"

ApplicationWindow {
    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations


    Python {
        id: py
        Component.onCompleted: {
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
            setHandler('warningCamperNotAvailable', function() {
                warningNoPydub = true
            });
            setHandler('campError', function() {
                console.log('error')
            });

            setHandler('deletedFile', function() {
                origAudioFilePath = ""
                origAudioFileName = ""
                origAudioFolderPath = ""
                origAudioType = ""
                origAudioName = ""
                idAudioPlayer.source = ""
                idImageWaveform.source = ""
                idImageWaveformZoom.source = ""
                audioLengthSecondsPython = 0
                millisecondsPerPixelPython = 0
                showTools = false
            });
            setHandler('copiedToClipboard', function() {
                clipboardAvailable = true
            });
        }

        // file operations
        function download(url,dir) {
            call("happy.downLoad", [url,dir])
        }
        function getHomePath() {
            call("happy.getHomePath", [])
        }

        function deleteFile() {
            stopPlayingResetWaveform()
            py.deleteAllTMPFunction()
            call("happy.deleteFile", [ origAudioFilePath ])
        }
        function renameOriginal() {
            stopPlayingResetWaveform()
            py.deleteAllTMPFunction()
            var newFilePath = origAudioFolderPath + idFilenameRenameText.text + "." + origAudioType
            var newFileName = idFilenameRenameText.text
            var newFileType = origAudioType
            call("happy.renameOriginal", [ origAudioFilePath, newFilePath, newFileName, newFileType ])
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
