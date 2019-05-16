import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

ListView {
    id: listView
    anchors { fill: parent }
    interactive: contentHeight > height
    model: ListModel {
        Component.onCompleted: {
            var supportedInterfaces = ["temperaturesensor", "humiditysensor", "pressuresensor", "moisturesensor", "lightsensor", "conductivitysensor", "noisesensor", "co2sensor", "presencesensor", "daylightsensor", "closablesensor"]
            for (var i = 0; i < supportedInterfaces.length; i++) {
                if (root.deviceClass.interfaces.indexOf(supportedInterfaces[i]) >= 0) {
                    append({name: supportedInterfaces[i]});
                }
            }
        }
    }
    delegate: Loader {
        id: loader
        width: parent.width

        property StateType stateType: root.deviceClass.stateTypes.findByName(interfaceStateMap[modelData])
        property string interfaceName: modelData

        sourceComponent: stateType && stateType.type.toLowerCase() === "bool" ? boolComponent : graphComponent

        property var interfaceStateMap: {
            "temperaturesensor": "temperature",
            "humiditysensor": "humidity",
            "pressuresensor": "pressure",
            "moisturesensor": "moisture",
            "lightsensor": "lightIntensity",
            "conductivitysensor": "conductivity",
            "noisesensor": "noise",
            "co2sensor": "co2",
            "presencesensor": "isPresent",
            "daylightsensor": "daylight",
            "closablesensor": "closed"
        }
    }

    Component {
        id: graphComponent

        GenericTypeGraph {
            device: root.device
            color: app.interfaceToColor(interfaceName)
            iconSource: app.interfaceToIcon(interfaceName)
            implicitHeight: width * .6
            property string interfaceName: parent.interfaceName
            stateType: parent.stateType
        }
    }

    Component {
        id: boolComponent
        GridLayout {
            id: boolView
            property string interfaceName: parent.interfaceName
            property StateType stateType: parent.stateType
            height: listView.height
            columns: app.landscape ? 2 : 1
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: app.iconSize * 5
                Layout.rowSpan: app.landscape ? 5 : 1
                ColorIcon {
                    anchors.centerIn: parent
                    height: app.iconSize * 4
                    width: height
                    name: {
                        switch (boolView.interfaceName) {
                        case "closablesensor":
                            return device.states.getState(boolView.stateType.id).value === true ? Qt.resolvedUrl("../images/lock-closed.svg") : Qt.resolvedUrl("../images/lock-open.svg")
                        default:
                            return app.interfaceToIcon(boolView.interfaceName)
                        }
                    }
                    color: {
                        switch (boolView.interfaceName) {
                        case "closablesensor":
                            return device.states.getState(boolView.stateType.id).value === true ? "green" : "red"
                        default:
                            device.states.getState(boolView.stateType.id).value === true ? app.interfaceToColor(boolView.interfaceName) : keyColor
                        }
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignHCenter
                property StateType lastSeenStateType: root.deviceClass.stateTypes.findByName("lastSeenTime")
                property State lastSeenState: lastSeenStateType ? root.device.states.getState(lastSeenStateType.id) : null
                visible: lastSeenStateType !== null
                Label {
                    text: qsTr("Last seen:")
                    font.bold: true
                }
                Label {
                    text: parent.lastSeenState ? Qt.formatDateTime(new Date(parent.lastSeenState.value * 1000)) : ""
                }
            }
            RowLayout {
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignHCenter
                property StateType sunriseStateType: root.deviceClass.stateTypes.findByName("sunriseTime")
                property State sunriseState: sunriseStateType ? root.device.states.getState(sunriseStateType.id) : null
                visible: sunriseStateType !== null
                Label {
                    text: qsTr("Sunrise:")
                    font.bold: true
                }
                Label {
                    text: parent.sunriseStateType ? Qt.formatDateTime(new Date(parent.sunriseState.value * 1000)) : ""
                }
            }
            RowLayout {
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignHCenter
                property StateType sunsetStateType: root.deviceClass.stateTypes.findByName("sunsetTime")
                property State sunsetState: sunsetStateType ? root.device.states.getState(sunsetStateType.id) : null
                visible: sunsetStateType !== null
                Label {
                    text: qsTr("Sunset:")
                    font.bold: true
                }
                Label {
                    text: parent.sunsetStateType ? Qt.formatDateTime(new Date(parent.sunsetState.value * 1000)) : ""
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }
}
