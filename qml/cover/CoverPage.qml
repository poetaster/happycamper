import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Label {
        id: label
        anchors.centerIn: parent
        text: qsTr("Happycamper")
    }
    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium

        Item {
            width: 1
            height: 3 * Theme.paddingLarge
        }

        Image {
            width: 172
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            source: "/usr/share/icons/hicolor/172x172/apps/harbour-happycamper.png"
            smooth: true
            asynchronous: true
        }

    }
    /*
    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-pause"
        }
    }*/
}
