/*
 * Copyright 2021 Rui Wang <wangrui@jingos.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtQuick.Controls 2.3 as Controls
import QtGraphicalEffects 1.6
import QtQml 2.12
import org.kde.kirigami 2.5
import org.kde.kirigami 2.15
import QtQuick.Controls 2.14
import QtQuick.Window 2.14
import org.kde.kcm 1.2

import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: root

    anchors.fill: parent

    Rectangle {
        id: authenticationrect

        width: root.width*0.3
        height: root.height*0.321
        anchors.horizontalCenter: root.horizontalCenter
        anchors.top: root.top
        anchors.topMargin: root.height*0.102
        
        radius: 12
        color: Qt.rgba(1,1,1,1)

        PlasmaComponents.Label {
            id:authenticationtitle

            anchors.top: authenticationrect.top
            anchors.topMargin: root.height*0.0247
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Math.ceil(root.height*0.02)

            color: "black"
            font.weight : Font.Medium
            text: i18n("Certification required")
        }

        Text {
            id: authenticationtip

            width: root.width * 0.262
            height: authenticationtip.contentHeight
            anchors.top: authenticationtitle.bottom
            anchors.topMargin: root.height*0.0124
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.verticalCenter

            font.pixelSize: Math.ceil(root.height*0.015)
            color: "black"
            wrapMode: Text.Wrap
            textFormat: Text.RichText
            text: policyKitListener.getMessage()
        }

        JKeyBdLineEdit {
            id:keyLineEdit

            width: root.width * 0.2639
            height: root.height * 0.0463
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: authenticationtip.bottom
            anchors.topMargin:  root.height * 0.024

            courseColor: "#FF3C4BE8"
            textColor: "black"
            cleanIconBackgroundColor: "#FFAEAEAE"
            cleanIconColor: "#FFFFFF"

            onMousePress: {
                virtuaKey.open()
            }
        }

        PlasmaComponents.Label {
            id: errortTip

            anchors.top: keyLineEdit.bottom//authenticationinput.bottom
            anchors.topMargin: root.height * 0.0124
            anchors.horizontalCenter: parent.horizontalCenter

            font.pixelSize: Math.ceil(root.height * 0.015)
            height: root.height * 0.0216
            color: "#E95B4E"
            horizontalAlignment: Text.AlignHCenter
            text: ""

            Connections {
                target: policyKitListener
                onErrorMessageChanged: {
                    errortTip.text = errorStr
                    errortTip.color = "#E95B4E"
                    errortTip.horizontalAlignment = Text.AlignHCenter
                }
            }
        }

        Item {
            id: name

            anchors.top: errortTip.bottom//authenticationinput.bottom
            anchors.topMargin: root.height * 0.02
            anchors.horizontalCenter: parent.horizontalCenter
            height: root.height * 0.0509
            width: root.width * 0.2635

            Row {
                id: btnLay
                anchors.fill: parent
                spacing: root.width * 0.0112
                Rectangle {
                    id: closeButton

                    height: parent.height//appHeightResolution * 66
                    width:  root.width * 0.126
                    visible: true
                    radius: closeButton.height * 0.21
                    color: Qt.rgba(239/255,239/255,239/255,0.70)

                    Text {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: "#000000"
                        font.pixelSize: 11
                        text: i18n("Cancel")
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            policyKitListener.invokeSendCancelSig()
                            policyKitListener.dialogCanceled()
                            var list = policyKitListener.getIdentities()
                        }

                        onEntered: {
                            closeButton.color = Qt.rgba(118/255,118/255,128/255,0.12)
                        }

                        onExited: {
                            closeButton.color = Qt.rgba(239/255,239/255,239/255,0.70)
                        }

                        onPressed: {
                            closeButton.color = Qt.rgba(120/255,120/255,120/255,0.16)
                        }

                        onReleased: {
                            closeButton.color = Qt.rgba(239/255,239/255,239/255,0.70)
                        }
                    }
                }

                Rectangle {
                    id: enterButton
                    
                    visible: true
                    height: parent.height//appHeightResolution * 66
                    width:  root.width*0.126
                    radius: enterButton.height*0.21
                    color: Qt.rgba(239/255,239/255,239/255,0.70)

                    Text {
                        anchors.fill: parent

                        color: keyLineEdit.labelData ? "#3C4BE8" : "#000000"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: i18n("Certify")
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            policyKitListener.dialogAccepted(keyLineEdit.labelData)
                            errortTip.text = i18n("In the validation")
                            errortTip.color="#000000"
                            errortTip.horizontalAlignment=Text.AlignLeft
                        }

                        onEntered: {
                            enterButton.color = Qt.rgba(118/255,118/255,128/255,0.12)
                        }

                        onExited: {
                            enterButton.color = Qt.rgba(239/255,239/255,239/255,0.70)
                        }

                        onPressed: {
                            enterButton.color = Qt.rgba(120/255,120/255,120/255,0.16)
                        }

                        onReleased: {
                            enterButton.color = Qt.rgba(239/255,239/255,239/255,0.70)
                        }
                    }
                }
            }
        }
    }
    DropShadow {
        anchors.fill: authenticationrect
        horizontalOffset: 0
        verticalOffset: 4
        radius: 12.0
        samples: 16
        cached: true
        color: Qt.rgba(0, 0, 0, 0.1)
        source: authenticationrect
        visible: true
    }

    JPasswdKeyBd {
        id: virtuaKey

        boardWidth: root.width
        boardHeight: root.height*0.5069
        y: root.height-boardHeight
        closePolicy: Popup.NoAutoClose

        onKeyBtnClick: {
            keyLineEdit.opAddStr(str)
        }

        onKeyBtnEnter: {
            policyKitListener.dialogAccepted(keyLineEdit.labelData)
            errortTip.text = i18n("In the validation")
            errortTip.color = "#000000"
            event.accepted = true
        }

        onKeyBtnDel: {
            keyLineEdit.opSubStr()
        }
    }

    Component.onCompleted: {
        timer.running = true
    }

    Timer {
        id: timer
        
        interval: 500
        onTriggered: {
            keyLineEdit.lableId.forceActiveFocus()
            virtuaKey.open()
        }
    }

    Keys.onPressed: {
        if(event.key === Qt.Key_Return) {
            policyKitListener.dialogAccepted(keyLineEdit.labelData)
            errortTip.text = i18n("In the validation")
            errortTip.color = "#000000"
            event.accepted = true
        }
    }
}
