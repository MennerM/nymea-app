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

import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"

ItemDelegate {
    id: root

    property var paramType: null
    property var value: null
    property int operatorType: ParamDescriptors.ValueOperatorEquals

    contentItem: ColumnLayout {
        Label {
            Layout.fillWidth: true
            text: paramType.displayName
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: app.margins
            ComboBox {
                FontMetrics {
                    id: fm
                }

                Layout.fillWidth: true
                Layout.minimumWidth: {
                    var minWidth = 0;
                    for (var i = 0; i < model.length; i++) {
                        minWidth = Math.max(minWidth, fm.boundingRect(model[i]).width)
                    }
                    return minWidth + 60;
                }

                property bool isNumeric: {
                    switch (paramType.type.toLowerCase()) {
                    case "bool":
                    case "string":
                    case "qstring":
                    case "color":
                        return false;
                    case "uint":
                    case "int":
                    case "double":
                        return true;
                    }
                    console.warn("ParamDescriptorDelegate: Unhandled data type:", paramType.type.toLowerCase());
                    return false;
                }

                model: isNumeric ?
                           [qsTr("is"), qsTr("is not"), qsTr("is greater"), qsTr("is smaller"), qsTr("is greater or equal"), qsTr("is smaller or equal")]
                         : [qsTr("is"), qsTr("is not")];

                onCurrentTextChanged: {
                    switch (currentText) {
                    case qsTr("is"):
                        root.operatorType = ParamDescriptor.ValueOperatorEquals;
                        break;
                    case qsTr("is not"):
                        root.operatorType = ParamDescriptor.ValueOperatorNotEquals;
                        break;
                    case qsTr("is greater"):
                        root.operatorType = ParamDescriptor.ValueOperatorGreater;
                        break;
                    case qsTr("is smaller"):
                        root.operatorType = ParamDescriptor.ValueOperatorLess;
                        break;
                    case qsTr("is greater or equal"):
                        root.operatorType = ParamDescriptor.ValueOperatorGreaterOrEqual;
                        break;
                    case qsTr("is smaller or equal"):
                        root.operatorType = ParamDescriptor.ValueOperatorLessOrEqual;
                        break;
                    }
                    print("set operator to", root.operatorType, currentText)
                }
            }


            Loader {
                id: placeHolder
                Layout.fillWidth: true

                sourceComponent: {
                    print("Datatye is:", paramType.name, paramType.type, paramType.minValue, paramType.maxValue, paramType.allowedValues)
                    switch (paramType.type.toLowerCase()) {
                    case "bool":
                        return boolComponent;
                    case "uint":
                    case "int":
                    case "double":
                        if (paramType.minValue !== undefined && paramType.maxValue !== undefined) {
                            return labelComponent;
                        }
                        return spinboxComponent;
                    case "string":
                    case "qstring":
                    case "color":
                        if (paramType.allowedValues.length > 0) {
                            return comboBoxComponent
                        }
                        return textFieldComponent;
                    }
                    console.warn("ParamDescriptorDelegate: Type delegate not implemented", paramType.type)
                    return null;
                }
            }

            Label {
                text: Types.toUiUnit(paramType.unit)
                visible: paramType.unit !== Types.UnitNone
            }
        }

        Loader {
            Layout.fillWidth: true
            sourceComponent: {
                print("***********+ loading", paramType.type)
                switch (paramType.type.toLowerCase()) {
                case "int":
                case "double":
                    if (paramType.minValue !== undefined && paramType.maxValue !== undefined) {
                        return sliderComponent
                    }


                }
            }
        }

    }

    Component {
        id: labelComponent
        Label {
            text: {
                switch (root.paramType.type.toLowerCase()) {
                case "double":
                    return Math.round(Types.toUiValue(root.value, root.paramType.unit) * 10) / 10
                }
                return Types.toUiValue(root.value, root.paramType.unit)
            }
        }
    }

    Component {
        id: textFieldComponent
        TextField {
            text: ""
            onTextChanged: {
                root.value = text;
            }
        }
    }

    Component {
        id: sliderComponent
        RowLayout {
            spacing: app.margins
            Label { text: Types.toUiValue(root.paramType.minValue, root.paramType.unit) }
            Slider {
                from: paramType.minValue
                to: paramType.maxValue
                value: root.value
                stepSize: {
                    switch (root.paramType.type.toLowerCase()) {
                    case "double":
                        return 0.1
                    }
                    return 1
                }
                Layout.fillWidth: true
                onMoved: {
                    root.value = value;
                }
            }
            Label { text: Types.toUiValue(root.paramType.maxValue, root.paramType.unit) }
        }

    }

    Component {
        id: spinboxComponent
        NymeaSpinBox {
            from: paramType.minValue
            to: paramType.maxValue
            value: root.value != undefined ? root.value : 0
            onValueModified: root.value = value
            floatingPoint: root.paramType.type.toLowerCase() === "double"
        }
    }

    Component {
        id: boolComponent
        ComboBox {
            model: ListModel {
                ListElement { modelData: "true"; value: true }
                ListElement { modelData: "false"; value: false }
            }
            onCurrentIndexChanged: {
                root.value = model.get(currentIndex).value
            }
        }
    }

    Component {
        id: comboBoxComponent
        ComboBox {
            model: paramType.allowedValues
            onCurrentIndexChanged: {
                root.value = paramType.allowedValues[currentIndex]
            }
        }
    }
}
