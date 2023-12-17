import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import Sailfish.WebEngine 1.0

Page {
    id: mainpage

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable

    SilicaFlickable {
        anchors.fill: parent
        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem {
                text: qsTr("Download")
                onClicked: py.download(webview.url.toString(),'/home/defaultuser/Music/')

            }
        }

        WebView {
            id: webview
            anchors.fill: parent
            /* This will probably be required from 4.4 on. */
            Component.onCompleted: {
                WebEngineSettings.setPreference("security.disable_cors_checks", true, WebEngineSettings.BoolPref)
                WebEngineSettings.setPreference("security.fileuri.strict_origin_policy", false, WebEngineSettings.BoolPref)
            }

            url: Qt.resolvedUrl("https://das-das.bandcamp.com")

            onViewInitialized: {
                //webview.loadFrameScript(Qt.resolvedUrl("../html/framescript.js"));
                //webview.addMessageListener("webview:action");
                //webview.runJavaScript("return latlon('" + lat + "','" + lon + "')");
            }
            on_PageOrientationChanged: {
                /*if ( data.topic != lon ) {
                        webview.runJavaScript("return latlon('" + lat + "','" + lon + "')");
                }*/

            }

            onRecvAsyncMessage: {
                if (debug) console.debug(message)
                //webview.runJavaScript("return latlon('" + lat + "','" + lon + "')");
                /*
                switch (message) {
                case "embed:contentOrientationChanged":
                    break
                case "webview:action":
                    if ( data.topic != lon ) {
                        webview.runJavaScript("return latlon('" + lat + "','" + lon + "')");
                        if (debug) console.debug(data.topic)
                        if (debug) console.debug(data.also)
                        if (debug) console.debug(data.src)
                    }
                    break
                }
                */
            }
        }


    }
}
