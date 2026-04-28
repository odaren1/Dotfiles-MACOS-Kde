import QtQuick 2.15
import QtQuick.Controls 2.15

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.3 as Kirigami

import org.kde.plasma.plasmoid 2.0
import org.kde.kcmutils as KCM


KCM.SimpleKCM {
    id: configGeneral

    property bool isDash: (Plasmoid.pluginName === "org.kde.plasma.kickerdash")

    property string cfg_icon: Plasmoid.configuration.icon
    property bool cfg_useCustomButtonImage: Plasmoid.configuration.useCustomButtonImage
    property string cfg_customButtonImage: Plasmoid.configuration.customButtonImage

    property alias cfg_useSystemFontSettings: useSystemFontSettings.checked

    property alias cfg_appsIconSize: appsIconSize.currentIndex
    property alias cfg_numberColumns: numberColumns.value

    property alias cfg_compactListItems: compactListItems.checked
    property alias cfg_showListItemDescription: showListItemDescription.checked
    property alias cfg_iconSize: iconSize.value

  Kirigami.FormLayout {

    anchors.left: parent.left
    anchors.right: parent.right

    Kirigami.Separator {
      Kirigami.FormData.isSection: true
      Kirigami.FormData.label: i18n("Grids and lists")
    }

    ComboBox {
        id: appsIconSize
        Kirigami.FormData.label: i18n("Grid icon size:")
        model: [i18n("Small"),i18n("Medium"),i18n("Large"), i18n("Huge")]
    }

    SpinBox{
      id: numberColumns

      from: 4
      to: 6
      Kirigami.FormData.label: i18n("Number of columns in grid")
    }
    CheckBox {
      id: compactListItems
      Kirigami.FormData.label: i18n("Lists:")
      text: i18n("Compact list items")
    }
    CheckBox {
      id: showListItemDescription
      text: i18n("Show list item description")
    }
    Item {
        Kirigami.FormData.isSection: true
    }
    CheckBox {
      id: useSystemFontSettings
      Kirigami.FormData.label: i18n("Use system font settings")
      text: i18n("Enabled")
      checked: Plasmoid.configuration.useSystemFontSettings
    }
    Item {
        Kirigami.FormData.isSection: true
    }
    SpinBox {
        id: iconSize
        Kirigami.FormData.label: i18n("Icon size:")
        from: 50
        to: 200
        value: Plasmoid.configuration.iconSize
        stepSize: 1
        editable: true
    }
    
    Label {
        text: "%"
        anchors.left: iconSize.right
        anchors.leftMargin: Kirigami.Units.smallSpacing
        anchors.verticalCenter: iconSize.verticalCenter
    }
  }
}
