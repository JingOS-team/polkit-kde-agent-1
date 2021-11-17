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
import jingos.display 1.0

Item {
    id: root
    anchors.fill: parent

    Rectangle {
        id: authenticationrect

        anchors.horizontalCenter: root.horizontalCenter
        anchors.top: root.top
        anchors.topMargin: JDisplay.dp(66)
        width: JDisplay.dp(264)
        height: errortTip.text === "" ? (JDisplay.dp(15) * 2 + authenticationtitle.height + authenticationtip.height + authenticationtip.anchors.topMargin + keyLineEdit.height + keyLineEdit.anchors.topMargin + name.height + name.anchors.topMargin )
        : (JDisplay.dp(15) * 2 + authenticationtitle.height + authenticationtip.height + authenticationtip.anchors.topMargin + keyLineEdit.height + keyLineEdit.anchors.topMargin + name.height + name.anchors.topMargin + errortTip.height + errortTip.anchors.topMargin)
        radius: JDisplay.dp(12)

        color: JTheme.colorScheme === "jingosLight" ? Qt.rgba(1,1,1,1) : Qt.rgba(38 / 255, 38 / 255, 42 / 255, 0.9)

        PlasmaComponents.Label {
            id: authenticationtitle

            anchors.top: authenticationrect.top
            anchors.topMargin: JDisplay.dp(15)
            anchors.horizontalCenter: parent.horizontalCenter
            height: contentHeight

            font.pixelSize: JDisplay.sp(12)
            color: JTheme.majorForeground
            font.weight :Font.Medium
            text: i18n("Certification required")
        }

        Text {
            id: authenticationtip

            anchors.top: authenticationtitle.bottom
            anchors.topMargin: JDisplay.dp(5)
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.verticalCenter

            font.pixelSize: JDisplay.sp(10)
            color: JTheme.majorForeground
            wrapMode: Text.Wrap
            width: JDisplay.dp(234)
            height: contentHeight
            textFormat: Text.RichText
            text: policyKitListener.getMessage()
        }

        JKeyBdLineEdit {
            id: keyLineEdit

            width: JDisplay.dp(234)
            height: JDisplay.dp(30)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: authenticationtip.bottom
            anchors.topMargin: JDisplay.dp(8)
            courseColor:"#FF3C4BE8"
            textColor:JTheme.majorForeground
            cleanIconBackgroundColor:"#FFAEAEAE"
            cleanIconColor:"#FFFFFF"
            color: JTheme.textFieldBackground
            onMousePress:{
                virtuaKey.open()
            }
        }

        PlasmaComponents.Label {
            id: errortTip

            anchors.top: keyLineEdit.bottom
            anchors.topMargin: JDisplay.dp(8)
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: JDisplay.sp(648 * 0.015)
            height: JDisplay.dp(14)
            horizontalAlignment: Text.AlignHCenter
            color: "#E95B4E"
            text: ""
            visible: text !== ""
            Connections {
                target: policyKitListener
                onErrorMessageChanged: {
                    errortTip.text = errorStr
                    errortTip.color = "#E95B4E"
                    errortTip.horizontalAlignment=Text.AlignHCenter
                    keyLineEdit.clearData()
                }
            }
        }

        Item {
            id: name

            anchors.top: errortTip.visible ?  errortTip.bottom : keyLineEdit.bottom
            anchors.topMargin:  errortTip.visible ? JDisplay.dp(8) : JDisplay.dp(15)
            anchors.horizontalCenter: parent.horizontalCenter
            height: JDisplay.dp(648 * 0.0509)
            width: JDisplay.dp(888 * 0.2635)

            Row {
                id: btnLay

                anchors.fill: parent
                spacing: JDisplay.dp(888 * 0.0112)
                Rectangle {
                    id: closeButton

                    height: parent.height
                    width: JDisplay.dp(888 * 0.126)

                    visible: true
                    radius: closeButton.height * 0.21
                    color: JTheme.colorScheme==="jingosLight" ? mouseClose.containsMouse ?( mouseClose.pressed ? "#28787878" : "#1E767676") : "#B2EFEFEF"
                                                              : mouseClose.containsMouse ?( mouseClose.pressed ? JTheme.pressBackground : JTheme.hoverBackground) : JTheme.buttonBackground
                    Text {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        color: JTheme.majorForeground//"#000000"
                        font.pixelSize: JDisplay.sp(648 * 0.017)//11
                        text: i18n("Cancel")
                    }

                    MouseArea {
                        id: mouseClose

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            policyKitListener.invokeSendCancelSig();
                            policyKitListener.dialogCanceled();
                            var list = policyKitListener.getIdentities()
                            for (var i =0; i < list.length; i++) {
                                console.log(list[i])
                            }
                        }
                    }
                }

                Rectangle {
                    id: enterButton

                    visible: true
                    height: parent.height
                    width:  JDisplay.dp(888 * 0.126)
                    radius: enterButton.height * 0.21
                    color: JTheme.colorScheme==="jingosLight" ? mouseEnter.containsMouse ?(mouseEnter.pressed ? "#28787878" : "#1E767676") : "#B2EFEFEF"
                                                              : mouseEnter.containsMouse ?( mouseEnter.pressed ? JTheme.pressBackground : JTheme.hoverBackground) : JTheme.buttonBackground
                    Text {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        color: keyLineEdit.labelData.length >= 4 ? Qt.rgba(69 /255, 107 / 255, 255 / 255,1) : JTheme.colorScheme==="jingosLight" ? Qt.rgba(0,0,0,0.3) : Qt.rgba(247 / 255, 247 / 255, 247 / 255,0.3)

                        font.pixelSize: JDisplay.sp(648 * 0.017)//11
                        text: i18n("OK")
                    }
                    enabled: keyLineEdit.labelData.length >= 4 ? true : false
                    MouseArea {
                        id: mouseEnter

                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            policyKitListener.dialogAccepted(keyLineEdit.labelData)
                            errortTip.text = i18n("In the validation")
                            errortTip.color=JTheme.majorForeground
                            errortTip.horizontalAlignment=Text.AlignLeft
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

    JPasswdKeyBd{
        id: virtuaKey

        boardWidth:root.width
        boardHeight:JDisplay.sp(648 * 0.5069)
        y:root.height-boardHeight
        closePolicy:Popup.NoAutoClose
        onKeyBtnClick:{
            keyLineEdit.opAddStr(str)
        }
        onKeyBtnEnter:{
            policyKitListener.dialogAccepted(keyLineEdit.labelData)
            errortTip.text = i18n("In the validation")
            errortTip.color=JTheme.majorForeground
            event.accepted = true
        }
        onKeyBtnDel:{
            keyLineEdit.opSubStr()
        }
    }

    Component.onCompleted: {
        timer.running=true
    }

    Timer {
        id:timer

        interval: 500
        onTriggered: {
            keyLineEdit.lableId.forceActiveFocus()
            virtuaKey.open()
        }
    }

    Keys.onPressed: {
        if(event.key === Qt.Key_Return){
            policyKitListener.dialogAccepted(keyLineEdit.labelData)
            errortTip.text = i18n("In the validation")
            errortTip.color=JTheme.majorForeground
            event.accepted = true
        }
    }
}
