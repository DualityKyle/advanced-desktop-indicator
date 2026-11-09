/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.taskmanager as TaskManager

// A single tracker that monitors every screen, regardless
// of what screen mode is selected
Item {
  id: tracker

  property var occupiedDesktops: []
  property var occupiedByScreen: ({})

  readonly property var taskRoles: TaskManager.AbstractTasksModel
  // Only changes to these roles trigger a refresh
  readonly property var watchedRoles: [
    taskRoles.IsWindow,
    taskRoles.IsOnAllVirtualDesktops,
    taskRoles.VirtualDesktops,
    taskRoles.ScreenGeometry
  ]

  function refresh() {
    const screens = Array.from(Qt.application.screens);
    const all = new Set();
    const byScreen = {};
    for (let i = 0; i < tasksModel.count; ++i) {
      const task = tasksModel.index(i, 0);
      if (!tasksModel.data(task, taskRoles.IsWindow) || tasksModel.data(task, taskRoles.IsOnAllVirtualDesktops))
        continue;
      const geometry = tasksModel.data(task, taskRoles.ScreenGeometry);
      const screenName = screens.find((screen) =>
        screen.virtualX === geometry.x && screen.virtualY === geometry.y)?.name ?? "";
      if (!byScreen[screenName])
        byScreen[screenName] = new Set();
      for (const desktopId of tasksModel.data(task, taskRoles.VirtualDesktops) ?? []) {
        all.add(desktopId);
        byScreen[screenName].add(desktopId);
      }
    }
    // Only assign values if something changed, instead
    // of desktops constantly re-checking
    const occupied = [...all].sort();
    if (occupied.join() !== occupiedDesktops.join())
      occupiedDesktops = occupied;

    const result = {};
    for (const name of Object.keys(byScreen).sort())
      result[name] = [...byScreen[name]].sort();
    // Compare as JSON text so object contents can be compared
    if (JSON.stringify(result) !== JSON.stringify(occupiedByScreen))
      occupiedByScreen = result;
  }

  Component.onCompleted: refresh()

  Connections {
    target: Qt.application

    function onScreensChanged() {
      Qt.callLater(tracker.refresh);
    }
  }

  TaskManager.ActivityInfo {
    id: activityInfo
    onCurrentActivityChanged: Qt.callLater(tracker.refresh)
  }

  TaskManager.TasksModel {
    id: tasksModel

    groupMode: TaskManager.TasksModel.GroupDisabled
    sortMode: TaskManager.TasksModel.SortDisabled
    activity: activityInfo.currentActivity
    filterByActivity: activityInfo.currentActivity !== ""

    // Use callLater to combine bursts of changes into a single refresh
    onCountChanged: Qt.callLater(tracker.refresh)
    onDataChanged: (topLeft, bottomRight, roles) => {
      if (roles.length === 0 || roles.some((role) =>
          tracker.watchedRoles.includes(role)))
        Qt.callLater(tracker.refresh);
    }
  }
}
