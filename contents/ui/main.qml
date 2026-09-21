/*
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation
    Plasmoid.constraintHints: Plasmoid.CanFillArea

    TaskManager.TasksModel {
        id: tasksModel
        groupMode: TaskManager.TasksModel.GroupApplications
        groupInline: false
        sortMode: TaskManager.TasksModel.SortManual
        filterByVirtualDesktop: true
        filterByActivity: true

        onDataChanged: root.rebuildGroups()
        onRowsInserted: root.rebuildGroups()
        onRowsRemoved: root.rebuildGroups()
        onModelReset: root.rebuildGroups()
    }

    property var groups: []

    function rebuildGroups() {
        var result = []
        for (var i = 0; i < tasksModel.rowCount(); i++) {
            var idx = tasksModel.index(i, 0)
            var childCount = tasksModel.rowCount(idx)
            if (childCount >= 2) {
                var name = tasksModel.data(idx, TaskManager.AbstractTasksModel.AppName) || ""
                var abbr = name.length > 0 ? name.substring(0, 3).toUpperCase() : "???"
                result.push({ name: name, abbr: abbr, count: childCount })
            }
        }
        root.groups = result
    }

    Component.onCompleted: rebuildGroups()

    fullRepresentation: Item {
        id: fullRep

        // Size to content, collapse when empty
        implicitWidth: root.groups.length > 0 ? countRow.implicitWidth + 8 : 0
        implicitHeight: countRow.implicitHeight + 4
        Layout.fillHeight: true
        Layout.minimumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth
        clip: true

        Row {
            id: countRow
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: root.groups

                delegate: Item {
                    id: chip
                    required property var modelData
                    width: chipRow.implicitWidth + 10
                    height: Math.min(fullRep.height - 4, 22)
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        radius: height / 2
                        color: Qt.rgba(
                            Kirigami.Theme.highlightColor.r,
                            Kirigami.Theme.highlightColor.g,
                            Kirigami.Theme.highlightColor.b,
                            0.2
                        )
                        border.color: Qt.rgba(
                            Kirigami.Theme.highlightColor.r,
                            Kirigami.Theme.highlightColor.g,
                            Kirigami.Theme.highlightColor.b,
                            0.55
                        )
                        border.width: 1
                    }

                    Row {
                        id: chipRow
                        anchors.centerIn: parent
                        spacing: 3

                        PlasmaComponents3.Label {
                            text: chip.modelData.abbr
                            font.pixelSize: 9
                            font.bold: true
                            color: Kirigami.Theme.textColor
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: 2; height: 2; radius: 1
                            color: Kirigami.Theme.textColor
                            opacity: 0.4
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        PlasmaComponents3.Label {
                            text: chip.modelData.count
                            font.pixelSize: 9
                            font.bold: true
                            color: Kirigami.Theme.highlightColor
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    PlasmaComponents3.ToolTip {
                        text: chip.modelData.name + ": " + chip.modelData.count + " windows"
                    }
                }
            }
        }
    }
}
