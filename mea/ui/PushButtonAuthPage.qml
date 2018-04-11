import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Mea 1.0
import "components"

Page {
    id: root
    signal backPressed();

    header: GuhHeader {
        text: "Welcome to nymea!"
        backButtonVisible: true
        onBackPressed: {
            root.backPressed();
        }
    }

    Component.objectName: {
        Engine.jsonRpcClient.requestPushButtonAuth("");
    }

    Connections {
        target: Engine.jsonRpcClient
        onPushButtonAuthFailed: {
            var popup = errorDialog.createObject(root)
            popup.text = qsTr("Sorry, something went wrong during the setup. Try again please.")
            popup.open();
            popup.accepted.connect(function() {root.backPressed()})
        }
    }

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
        anchors.margins: app.margins
        spacing: app.margins

        RowLayout {
            Layout.fillWidth: true
            spacing: app.margins

            ColorIcon {
                height: app.iconSize * 2
                width: height
                color: app.guhAccent
                name: "../images/info.svg"
            }

            Label {
                color: app.guhAccent
                text: qsTr("Authentication required")
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                font.pixelSize: app.largeFont
            }
        }


        Label {
            Layout.fillWidth: true
            text: "Please press the button on your nymea box to authenticate this device."
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    Component {
        id: errorDialog
        ErrorDialog {

        }
    }
}
