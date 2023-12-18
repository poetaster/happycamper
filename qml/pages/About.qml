import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    objectName: "AboutPage"

    allowedOrientations: Orientation.All

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium

        PageHeader {
            title: qsTr("About Happycamper")
        }

        Item {
            width: 1
            height: 3 * Theme.paddingLarge
        }

        Image {
            width: parent.width / 5
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            source: "/usr/share/icons/hicolor/172x172/apps/harbour-happycamper.png"
            smooth: true
            asynchronous: true
        }

        Item {
            width: 1
            height: Theme.paddingLarge
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.primaryColor
            textFormat: Text.StyledText
            linkColor: Theme.highlightColor
            text: qsTr("A simple downloader for") + "\n" +
                       "<a href=\"https://bandcamp.com\">Bandcamp</a>"
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }
        Label {
            id: dwdLabel
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.primaryColor
            textFormat: Text.StyledText
            linkColor: Theme.highlightColor
            text: qsTr("Many thanks to: ") + "<a href=\"https://github.com/catlinman/campdown\">Campdown (github)</a>"
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }
        Item {
            width: parent.width
            height: Theme.paddingLarge
        }
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
            text:  qsTr(" © 2023-2024 Mark Washeim")
        }

        Item {
            width: parent.width
            height: 2 * Theme.paddingLarge
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr("This program is FOSS software licensed") + "\n"
                  + qsTr("GNU General Public License v3.")
        }

        Item {
            width: parent.width
            height: Theme.paddingLarge
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: Theme.paddingSmall
            color: Theme.secondaryColor
            textFormat: Text.StyledText
            linkColor: Theme.highlightColor
            text: "<a href=\"https://github.com/poetaster/harbour-happycamper\">Source: github</a>"
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }

    }
}
