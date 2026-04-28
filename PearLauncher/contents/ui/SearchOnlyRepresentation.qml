/*****************************************************************************
 *   Copyright (C) 2014 by Weng Xuetian <wengxt@gmail.com>                   *
 *   Copyright (C) 2013-2017 by Eike Hein <hein@kde.org>                     *
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
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ****************************************************************************/

import QtQuick
import QtQuick.Layouts
import QtQml
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmaCore.Dialog {
	id: root

	objectName: "searchOnlyPopupWindow"
	flags: Qt.WindowStaysOnTopHint

	location: PlasmaCore.Types.Floating
	hideOnWindowDeactivate: true

	Plasmoid.status: root.visible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus

	property int minWidth: 600
	property int maxHeight: 600

	onVisibleChanged: {
		if (!visible) {
			reset();
		} else {
			var pos = popupPosition(width, height);
			x = pos.x;
			y = pos.y;
			requestActivate();
		}
	}

	onHeightChanged: {
		var pos = popupPosition(width, height);
		x = pos.x;
		y = pos.y;
	}

	onWidthChanged: {
		var pos = popupPosition(width, height);
		x = pos.x;
		y = pos.y;
	}

	function toggle() {
		root.visible = false;
	}

	function reset() {
		main.reset()
	}

	function popupPosition(width, height) {
		var screenAvail = Plasmoid.availableScreenRect;
		var screen = kicker.screenGeometry;
		var horizMidPoint = screen.x + (screen.width / 2);
		var vertMidPoint = screen.y + (screen.height / 2);

		var x = horizMidPoint - width / 2;
		var y = vertMidPoint - height / 2;

		return Qt.point(x, y);
	}

	FocusScope {
		id: fs
		focus: true
		width: root.minWidth
		height: main.searching ? root.maxHeight : 60
		
		// Animație pentru fade in
		opacity: root.visible ? 1.0 : 0.0
		Behavior on opacity {
			NumberAnimation {
				duration: 200
				easing.type: Easing.OutCubic
			}
		}
		
		property real innerPadding: 15 

		Item {
			id: mainItem
			x: - dialogSvg.margins.left
			y: - dialogSvg.margins.top
			width: parent.width + dialogSvg.margins.left + dialogSvg.margins.right
			height: parent.height + dialogSvg.margins.top + dialogSvg.margins.bottom

			SearchOnlyView {
				id: main
				width:  mainItem.width - (fs.innerPadding * 2)
				height: mainItem.height - (fs.innerPadding * 2)
				x: fs.innerPadding
				y: fs.innerPadding
				property QtObject root: root
			}
		}

		Keys.onPressed: {
			if (event.key == Qt.Key_Escape) {
				root.visible = false;
			}
		}
	}

	function refreshModel() {
		main.reload()
	}

	Component.onCompleted: {
		kicker.reset.connect(reset);
		rootModel.refresh();
	}
}

