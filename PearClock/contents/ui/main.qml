import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtCore

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    Plasmoid.title: i18n("PearClock")
    Plasmoid.icon: "clock"
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property string currentDate: ""
    property string currentTime: ""

    Timer {
        id: updateTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateDateTime()
    }

    function updateDateTime() {
        var now = new Date()
        
        // Formatăm data folosind Qt.formatDateTime
        currentDate = Qt.formatDateTime(now, Plasmoid.configuration.dateFormat)
        
        // Formatăm ora folosind Qt.formatDateTime
        // Dacă use24HourFormat este activat, folosim formatul 24h, altfel 12h cu AM/PM
        var timeFormatStr
        if (Plasmoid.configuration.use24HourFormat) {
            // Folosim formatul custom dacă este setat și conține HH, altfel folosim HH:mm
            if (Plasmoid.configuration.timeFormat && Plasmoid.configuration.timeFormat.indexOf("HH") !== -1) {
                timeFormatStr = Plasmoid.configuration.timeFormat
            } else {
                timeFormatStr = "HH:mm"
            }
        } else {
            // Folosim formatul custom dacă este setat și conține hh, altfel folosim hh:mm AP
            if (Plasmoid.configuration.timeFormat && Plasmoid.configuration.timeFormat.indexOf("hh") !== -1 && Plasmoid.configuration.timeFormat.indexOf("AP") !== -1) {
                timeFormatStr = Plasmoid.configuration.timeFormat
            } else {
                timeFormatStr = "hh:mm AP"
            }
        }
        currentTime = Qt.formatDateTime(now, timeFormatStr)
    }

    Component.onCompleted: {
        updateDateTime()
    }

    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        id: clockItem
        Layout.minimumWidth: clockText.implicitWidth
        Layout.preferredWidth: clockText.implicitWidth
        Layout.minimumHeight: clockText.implicitHeight
        Layout.preferredHeight: clockText.implicitHeight

        Text {
            id: clockText
            anchors.centerIn: parent
            text: {
                var dateStr = root.currentDate
                var timeStr = root.currentTime
                if (Plasmoid.configuration.showSeparator) {
                    return dateStr + Plasmoid.configuration.separatorText + timeStr
                } else {
                    return dateStr + " " + timeStr
                }
            }
            font.pointSize: Plasmoid.configuration.fontSize
            color: Kirigami.Theme.textColor
        }

        PlasmaCore.ToolTipArea {
            anchors.fill: parent
            mainText: Plasmoid.title
            subText: root.currentDate + " " + root.currentTime
        }
    }
}

