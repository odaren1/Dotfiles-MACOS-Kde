import QtQuick 2.15
import QtQuick.Controls 2.15

import org.kde.kirigami 2.3 as Kirigami
import org.kde.plasma.plasmoid 2.0
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configGeneral

    property alias cfg_dateFormat: dateFormat.text
    property alias cfg_timeFormat: timeFormat.text
    property alias cfg_use24HourFormat: use24HourFormat.checked
    property alias cfg_showSeparator: showSeparator.checked
    property alias cfg_separatorText: separatorText.text
    property alias cfg_fontSize: fontSize.value

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Date and Time Format")
        }

        TextField {
            id: dateFormat
            Kirigami.FormData.label: i18n("Date format:")
            placeholderText: "ddd MMM d"
            text: Plasmoid.configuration.dateFormat
        }

        TextField {
            id: timeFormat
            Kirigami.FormData.label: i18n("Time format:")
            placeholderText: "HH:mm"
            text: Plasmoid.configuration.timeFormat
            enabled: !use24HourFormat.checked
        }

        CheckBox {
            id: use24HourFormat
            Kirigami.FormData.label: i18n("24-hour format:")
            checked: Plasmoid.configuration.use24HourFormat
            text: checked ? i18n("Enabled (HH:mm)") : i18n("Disabled (hh:mm AP)")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Separator")
        }

        CheckBox {
            id: showSeparator
            Kirigami.FormData.label: i18n("Show separator:")
            checked: Plasmoid.configuration.showSeparator
        }

        TextField {
            id: separatorText
            Kirigami.FormData.label: i18n("Separator text:")
            enabled: showSeparator.checked
            text: Plasmoid.configuration.separatorText
            placeholderText: "  "
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Appearance")
        }

        SpinBox {
            id: fontSize
            Kirigami.FormData.label: i18n("Font size:")
            from: 8
            to: 72
            value: Plasmoid.configuration.fontSize
            stepSize: 1
            editable: true
        }
    }
}

