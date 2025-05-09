import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import Sailfish.WebEngine 1.0
import Nemo.DBus 2.0

Page {
    id: mainpage
    property alias notification: popup
    property string musicPath: StandardPaths.writableLocation(StandardPaths.MusicLocation)

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable

    function setUrl(url){
        webview.url = Qt.resolvedUrl(url)
    }
    DBusAdaptor {
        id: dbus
        bus: DBus.SessionBus
        service: 'de.poetaster.happycamper'
        iface: 'de.poetaster.happycamper'
        path: '/de/poetaster/happycamper'
        xml: '<interface name="de.poetaster.happycamper">
               <method name="openUrl">
                 <arg name="url" type="s" direction="in">
                   <doc:doc><doc:summary>url to open</doc:summary></doc:doc>
                 </arg>
               </method>
             </interface>'
        function openUrl(u) {
            console.log("openUrl called via DBus:" + u)
            webview.url = Qt.resolvedUrl(u.toString())
            //mainpage.setUrl(u)
        }
    }
    SilicaFlickable {
        anchors.fill: parent
        PullDownMenu {
            /*MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("Settings.qml"))
            }*/
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("About.qml"))

            }
            MenuItem {
                text: qsTr("Back")
                onClicked:
                    if (webview.canGoBack)
                        webview.goBack()

            }
            MenuItem {
                text: qsTr("Player")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("PlayerPage.qml"))
            }
            MenuItem {
                text: qsTr("Download")
                onClicked: {
                    notification.notify("Download starting...")
                    py.download_url(webview.url.toString(),musicPath)
                }
            }
        }
        PushUpMenu {
            MenuItem {
                text: qsTr("Forward")
                onClicked:
                    if (webview.canGoForward)
                        webview.goForward()
            }
        }
        Popup {
            id: popup
            z: 10
            timeout: 3000
            padding: Theme.paddingLarge
        }

        WebView {
            id: webview
            anchors.fill: parent
            /* This will probably be required from 4.4 on. */
            Component.onCompleted: {
                //WebEngineSettings.setPreference("security.disable_cors_checks", true, WebEngineSettings.BoolPref)
                //WebEngineSettings.setPreference("security.fileuri.strict_origin_policy", false, WebEngineSettings.BoolPref)
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
                //popup.notify(message)
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
