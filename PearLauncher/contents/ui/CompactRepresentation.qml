/*****************************************************************************
 *   Copyright (C) 2013-2014 by Eike Hein <hein@kde.org>                     *
 *   Copyright (C) 2021 by Prateek SU <pankajsunal123@gmail.com>             *
 *   Copyright (C) 2022 by Friedrich Schriewer <friedrich.schriewer@gmx.net> *
 *                                                                           *
 *   This program is free software; you can redistribute it and/or modify    *
 *   it under the terms of the GNU General Public License as published by    *
 *   the Free Software Foundation; either version 2 of the License, or       *
 *   (at your option) any later version.                                     *
 *                                                                           *
 *   This program is distributed in the hope that it will be useful,         *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           *
 *   GNU General Public License for more details.                            *
 *                                                                           *
 *   You should have received a copy of the GNU General Public License       *
 *   along with this program; if not, write to the                           *
 *   Free Software Foundation, Inc.,                                         *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .          *
 ****************************************************************************/

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore

import org.kde.kirigami as Kirigami

MouseArea {
    id: root

    anchors.fill: parent

    property QtObject dashWindow: null
    property QtObject searchWindow: null
    readonly property bool useCustomButtonImage: (Plasmoid.configuration.useCustomButtonImage && Plasmoid.configuration.customButtonImage.length != 0)

    readonly property bool inPanel: (Plasmoid.location === PlasmaCore.Types.TopEdge
        || Plasmoid.location === PlasmaCore.Types.RightEdge
        || Plasmoid.location === PlasmaCore.Types.BottomEdge
        || Plasmoid.location === PlasmaCore.Types.LeftEdge)

    activeFocusOnTab: true
    hoverEnabled: true

    onClicked: {
        if (searchWindow && searchWindow.visible) {
            searchWindow.visible = false;
        }
        dashWindow.visible = !dashWindow.visible;
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
       // anchors.horizontalCenterOffset: 15
        anchors.verticalCenterOffset: -2
        readonly property bool isHorizontal: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
        readonly property real baseSize: isHorizontal ? parent.height : parent.width
        width: baseSize
        height: baseSize
        scale: Plasmoid.configuration.iconSize / 100
        transformOrigin: Item.Center

        Kirigami.Icon {
            id: buttonIcon

            source: Plasmoid.icon

            anchors.fill: parent
            smooth: true

            active: false
        }
    }

    Component.onCompleted: {
        dashWindow = Qt.createQmlObject("MenuRepresentation {}", root);
        searchWindow = Qt.createQmlObject("SearchOnlyRepresentation {}", root);
        plasmoid.activated.connect(function() {
            if (dashWindow && dashWindow.visible) {
                dashWindow.visible = false;
            }
            searchWindow.visible = !searchWindow.visible;
        });
    }
}
