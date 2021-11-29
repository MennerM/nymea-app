/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Nymea 1.0

SettingsPageBase {
    id: packageListPage
    title: qsTr("All packages")

    property Packages packages: engine.systemController.packages
    property alias filter: filterTextField.text

    ColumnLayout {
        Layout.fillWidth: true
        RowLayout {
            Layout.margins: Style.margins
            spacing: Style.margins
            ColorIcon {
                name: "find"
            }
            TextField {
                id: filterTextField
                Layout.fillWidth: true
            }
            ColorIcon {
                name: "close"
                visible: filterTextField.text.length > 0
                MouseArea {
                    anchors.fill: parent
                    onClicked: filterTextField.text = ""
                }
            }
        }
    }

    ListView {
        id: listView
        Layout.fillWidth: true
        Layout.preferredHeight: packageListPage.height - y
        clip: true

        ScrollBar.vertical: ScrollBar {}

        model: PackagesFilterModel {
            id: filterModel
            packages: packageListPage.packages
            nameFilter: filterTextField.displayText
        }

        delegate: NymeaSwipeDelegate {
            width: parent.width
            text: model.displayName
            subText: model.candidateVersion
            prominentSubText: false
            iconName: model.updateAvailable
                      ? Qt.resolvedUrl("../images/system-update.svg")
                      : Qt.resolvedUrl("../images/view-" + (model.installedVersion.length > 0 ? "expand" : "collapse") + ".svg")
            iconColor: model.updateAvailable
                       ? "green"
                       : model.installedVersion.length > 0 ? "blue" : Style.iconColor
            onClicked: {
                pageStack.push(packageDetailsComponent, {pkg: filterModel.get(index)})
            }
        }

        EmptyViewPlaceholder {
            anchors.centerIn: parent
            width: parent.width - Style.margins * 2
            visible: filterModel.count == 0
            title: qsTr("No package found")
            text: qsTr("We're sorry. We couldn't find any package matching the search term %1.").arg(packageListPage.filter)
            imageSource: "/ui/images/dialog-error-symbolic.svg"
            buttonVisible: false
        }

        UpdateRunningOverlay {
        }
    }
    Component {
        id: packageDetailsComponent
        SettingsPageBase {
            id: packageDetailsPage

            title: qsTr("Package information")
            property Package pkg: null

            GridLayout {
                Layout.fillWidth: true
                columns: app.landscape ? 2 : 1
                RowLayout {
                    Layout.margins: app.margins
                    spacing: app.margins
                    ColorIcon {
                        Layout.preferredHeight: Style.iconSize * 2
                        Layout.preferredWidth: Style.iconSize * 2
                        name: "../images/plugin.svg"
                        color: Style.accentColor
                    }
                    Label {
                        Layout.fillWidth: true
                        text: pkg.displayName
                        font.pixelSize: app.largeFont
                        elide: Text.ElideRight
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: packageDetailsPage.pkg.summary
                    wrapMode: Text.WordWrap
                }

                NymeaSwipeDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Installed version:")
                    subText: packageDetailsPage.pkg.installedVersion.length > 0 ? packageDetailsPage.pkg.installedVersion : qsTr("Not installed")
                    progressive: false
                }

                NymeaSwipeDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Candidate version:")
                    subText: packageDetailsPage.pkg.candidateVersion
                    visible: packageDetailsPage.pkg.updateAvailable || packageDetailsPage.pkg.installedVersion.length === 0
                    progressive: false
                }
                Button {
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    visible: packageDetailsPage.pkg.updateAvailable || packageDetailsPage.pkg.installedVersion.length === 0
                    text: packageDetailsPage.pkg.updateAvailable ? qsTr("Update") : qsTr("Install")
                    onClicked: {
                        var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                        var text = qsTr("This will start a system update. Note that the update might take several minutes and your %1 might not be functioning properly or restart during this time.").arg(Configuration.systemName)
                        + "\n\n"
                        + qsTr("\nDo you want to proceed?")
                        var popup = dialog.createObject(app,
                                                        {
                                                            headerIcon: "../images/system-update.svg",
                                                            title: qsTr("Start update"),
                                                            text: text,
                                                            standardButtons: Dialog.Ok | Dialog.Cancel
                                                        });
                        popup.open();
                        popup.accepted.connect(function() {
                            engine.systemController.updatePackages(packageDetailsPage.pkg.id)
                        })

                    }
                }
                Button {
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    text: qsTr("Remove")
                    visible: packageDetailsPage.pkg.canRemove
                    onClicked: {
                        var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                        var text = qsTr("This will start a system update. Note that the update might take several minutes and your %1 system might not be functioning properly during this time and restart during the process.\nDo you want to proceed?").arg(Configuration.systemName)
                        var popup = dialog.createObject(app,
                                                        {
                                                            headerIcon: "../images/system-update.svg",
                                                            title: qsTr("Remove package"),
                                                            text: text,
                                                            standardButtons: Dialog.Ok | Dialog.Cancel
                                                        });
                        popup.open();
                        popup.accepted.connect(function() {
                            engine.systemController.removePackages(packageDetailsPage.pkg.id)
                        })
                    }
                }

            }
            UpdateRunningOverlay {
            }
        }
    }

    Component {
        id: errorDialogComponent

        ErrorDialog {
            id: errorDialog
        }
    }
}




