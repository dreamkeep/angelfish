import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: root
    property bool connection: angel.isConnected

    onConnectionChanged: {
        if(angel.sensorState == "Connecting") {
            connectSwitch.busy = true
            connectSwitch.description = "Connecting..press button on sensor"
        } else {
            connectSwitch.busy = false
            connectSwitch.checked = angel.isConnected
            connectSwitch.description = angel.sensorState
        }

        if(angel.isConnected) {
            activityTimer.start()
        } else {
            activityTimer.stop()
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge
        contentWidth: parent.width

        PullDownMenu {
            MenuItem {
                text: qsTr("About AngelFish")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
            MenuItem {
                text: qsTr("Scan for devices")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Scan.qml"))
                }
            }
            MenuItem {
                enabled: angel.hasSensor
                text: qsTr("Sensor Info")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SensorInfo.qml"))
                }
            }
        }

        VerticalScrollDecorator {}

        ViewPlaceholder {
            enabled: !angel.hasSensor
            text: "No sensor configured"
            hintText: "Setup new sensor by scanning for device"
        }

        Column {
            visible: angel.hasSensor
            id: column
            spacing: Theme.paddingLarge
            width: root.width
            PageHeader {
                title: qsTr("AngelFish")
            }

            IconTextSwitch {
                id: connectSwitch
                text: qsTr("Angel Sensor")
                busy: angel.sensorState == "Connecting"
                checked: angel.isConnected
                description: angel.sensorState
                icon.source: "image://theme/icon-m-bluetooth"
                onCheckedChanged: checked ? angel.connectSensor() : angel.disconnectSensor()
            }

            DetailItem {
                label: "Battery"
                value: battery.level + qsTr(" %")
            }

            DetailItem {
                label: "Heart Rate"
                value: heart.rate + qsTr(" bpm")
            }

            Repeater {
                width: parent.width
                model: 1
                ListItem {
                    menu: resetStepsMenu
                    contentHeight: Theme.itemSizeSmall

                    function resetSteps() {
                        remorseAction("Resetting", function() { activity.resetSteps(); activity.readSteps() });
                    }

                    DetailItem {
                        anchors.centerIn: parent
                        label: "Steps"
                        value: activity.steps
                    }

                    Component {
                        id: resetStepsMenu
                        ContextMenu {
                            MenuItem {
                                text: "Reset Steps"
                                onClicked: resetSteps();
                            }
                        }
                    }
                }
            }

            Repeater {
                width: parent.width
                model: 1
                ListItem {
                    menu: resetAccelerationMenu
                    contentHeight: Theme.itemSizeSmall

                    function resetAcceleration() {
                        remorseAction("Resetting", function() { activity.resetAcceleration() })
                    }

                    DetailItem {
                        anchors.centerIn: parent
                        label: "Acceleration"
                        value: activity.acceleration + qsTr(" g")
                    }

                    Component {
                        id: resetAccelerationMenu
                        ContextMenu {
                            MenuItem {
                                text: "Reset Acceleration"
                                onClicked: resetAcceleration()
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: activityTimer
        interval: 10000
        running: false
        repeat: true
        onTriggered: {
            activity.readAcceleration()
        }
    }
}
