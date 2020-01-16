import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("General settings")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        id: settingsGrid
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; margins: app.margins }
        width: Math.min(500, parent.width - app.margins * 2)

        RowLayout {
            Layout.fillWidth: true
            spacing: app.margins
            Label {
                text: qsTr("Name")
            }
            TextField {
                id: nameTextField
                Layout.fillWidth: true
                text: engine.nymeaConfiguration.serverName
            }
            Button {
                text: qsTr("OK")
                visible: nameTextField.displayText !== engine.nymeaConfiguration.serverName
                onClicked: engine.nymeaConfiguration.serverName = nameTextField.displayText
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: engine.jsonRpcClient.ensureServerVersion("4.1") && engine.systemController.automaticTimeAvailable
            Label {
                text: qsTr("Set date and time automatically")
                Layout.fillWidth: true
            }
            CheckBox {
                checked: engine.systemController.automaticTime
                onClicked: {
                    engine.systemController.automaticTime = checked
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: app.margins
            Layout.preferredHeight: dateButton.implicitHeight
            visible: engine.jsonRpcClient.ensureServerVersion("4.1")
            Label {
                text: qsTr("Date")
                Layout.fillWidth: true
            }
            Label {
                text: engine.systemController.serverTime.toLocaleDateString()
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
            }
            Button {
                id: dateButton
                visible: !engine.systemController.automaticTime && engine.systemController.timeManagementAvailable
                contentItem: Item {
                    ColorIcon {
                        name: "../images/edit.svg"
                        color: app.foregroundColor
                        anchors.centerIn: parent
                        height: parent.height
                        width: height
                    }
                }

                onClicked: {
                    var popup = datePickerComponent.createObject(root, {dateTime: engine.systemController.serverTime})
                    popup.accepted.connect(function() {
                        print("setting new date", popup.dateTime)
                        engine.systemController.serverTime = popup.dateTime
                    })
                    popup.open();

                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: app.margins
            Layout.preferredHeight: timeButton.implicitHeight
            visible: engine.jsonRpcClient.ensureServerVersion("4.1")
            Label {
                text: qsTr("Time")
                Layout.fillWidth: true
            }
            Label {
                text: engine.systemController.serverTime.toLocaleTimeString(/*Locale.ShortTimeString*/)
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
            }
            Button {
                id: timeButton
                visible: !engine.systemController.automaticTime && engine.systemController.timeManagementAvailable
                contentItem: Item {
                    ColorIcon {
                        name: "../images/edit.svg"
                        color: app.foregroundColor
                        anchors.centerIn: parent
                        height: parent.height
                        width: height
                    }
                }

                onClicked: {
                    var popup = timePickerComponent.createObject(root, {hour: engine.systemController.serverTime.getHours(), minute: engine.systemController.serverTime.getMinutes()})
                    popup.accepted.connect(function() {
                        var date = new Date(engine.systemController.serverTime)
                        date.setHours(popup.hour);
                        date.setMinutes(popup.minute)
                        engine.systemController.serverTime = date;
                    })
                    popup.open();

                }
            }
        }


        RowLayout {
            Layout.fillWidth: true
            spacing: app.margins
            visible: engine.jsonRpcClient.ensureServerVersion("4.1")
            Label {
                Layout.fillWidth: true
                text: qsTr("Time zone")
            }
            ComboBox {
                Layout.minimumWidth: 200
                model: engine.systemController.timeZones
                currentIndex: model.indexOf(engine.systemController.serverTimeZone)
                onActivated: {
                    engine.systemController.serverTimeZone = currentText;
                }
            }
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Reboot %1:core").arg(app.systemName)
            visible: engine.systemController.powerManagementAvailable
            onClicked: {
                var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                var text = qsTr("Are you sure you want to reboot your %1:core sytem now?").arg(app.systemName)
                var popup = dialog.createObject(app,
                                                {
                                                    headerIcon: "../images/dialog-warning-symbolic.svg",
                                                    title: qsTr("Reboot %1:core").arg(app.systemName),
                                                    text: text,
                                                    standardButtons: Dialog.Ok | Dialog.Cancel
                                                });
                popup.open();
                popup.accepted.connect(function() {
                    engine.systemController.reboot()
                })
            }
        }
        Button {
            Layout.fillWidth: true
            text: qsTr("Shutdown %1:core").arg(app.systemName)
            visible: engine.systemController.powerManagementAvailable
            onClicked: {
                var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                var text = qsTr("Are you sure you want to shut down your %1:core sytem now?").arg(app.systemName)
                var popup = dialog.createObject(app,
                                                {
                                                    headerIcon: "../images/dialog-warning-symbolic.svg",
                                                    title: qsTr("Shut down %1:core").arg(app.systemName),
                                                    text: text,
                                                    standardButtons: Dialog.Ok | Dialog.Cancel
                                                });
                popup.open();
                popup.accepted.connect(function() {
                    engine.systemController.shutdown()
                })
            }
        }
    }

    Component {
        id: timePickerComponent
        Dialog {
            id: timePicker
            property int maxSize: Math.min(parent.width, parent.height)
            property int size: Math.min(maxSize, 500)
            property alias hour: p.hour
            property alias minute: p.minute
            width: size - 80
            height: size
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            TimePicker {
                id: p
                width: parent.width
                height: parent.height
            }
            standardButtons: Dialog.Ok | Dialog.Cancel
        }
    }

    Component {
        id: datePickerComponent
        Dialog {
            id: datePicker
            property int maxSize: Math.min(parent.width, parent.height)
            property int size: Math.min(maxSize, 500)
            property alias dateTime: p.date
            width: size - 80
            height: size
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            DatePicker {
                id: p
                width: parent.width
                height: parent.height
                date: datePicker.dateTime
            }
            standardButtons: Dialog.Ok | Dialog.Cancel
        }
    }
}
