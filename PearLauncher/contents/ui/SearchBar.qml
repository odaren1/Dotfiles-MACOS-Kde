import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

RowLayout {

    property alias textField: textField
    property alias showMenuButton: menuButton.visible
    property string customIconSource: ""
    property string customPlaceholderText: ""
    property bool useCustomIcon: customIconSource != ""

    Kirigami.Icon {
        id: searchIcon
        Layout.rightMargin: 0
        source: {
            if (useCustomIcon) {
                return customIconSource;
            }
            if (iconMouseArea.containsMouse && main.showAllApps) {
                return "go-previous-symbolic";
            }
            return main.showAllApps ? Qt.resolvedUrl('icons/AppsIcon.svg') : "favorite-symbolic";
        }
        isMask: useCustomIcon ? true : main.showAllApps
        color: main.dimmedTextColor
        width: useCustomIcon ? 20 : implicitWidth
        height: useCustomIcon ? 20 : implicitHeight
        MouseArea {
            id: iconMouseArea
            anchors.fill: parent
            enabled: !useCustomIcon
            hoverEnabled: true
            
            Timer {
                id: activateSearchTimer
                interval: 150 // Sincronizat cu animația de fade out (200ms) - începem mai devreme pentru o tranziție mai smooth
                onTriggered: {
                    plasmoid.activated(); // Declanșăm același eveniment ca Alt+Space
                }
            }
            
            onClicked: {
                if (main.showAllApps) {
                    // Când suntem pe toate aplicațiile, deschidem fereastra de search
                    if (root && root.visible) {
                        // Începem animația de fade out
                        if (root.closeAnimated) {
                            root.closeAnimated(); // Aceasta va declanșa animația de fade out
                        } else {
                            root.visible = false;
                        }
                    }
                    // Folosim un timer pentru a deschide fereastra de search după ce animația de fade out a început
                    activateSearchTimer.start();
                } else {
                    // Când suntem pe favorite, revenim la toate aplicațiile
                    main.showAllApps = !main.showAllApps;
                    textField.forceActiveFocus(Qt.BacktabFocusReason)
                }
            }
        }
    }

    TextField {
        id: textField
        Layout.fillHeight: true
        Layout.fillWidth: true
        font.pointSize: 18

        placeholderText: customPlaceholderText != "" ? customPlaceholderText : "Applications"
        placeholderTextColor: main.dimmedTextColor
        background: Rectangle{
            color: "transparent"
        }
        focus: true
        onTextChanged: {
            textField.forceActiveFocus(Qt.ShortcutFocusReason)
            runnerModel.query = text;   
        }

        Keys.onPressed: event => {
            if (event.key == Qt.Key_Escape) {
                event.accepted = true;
                if (searching) {
                    clear();
                } else {
                    if (root && root.toggle) {
                        root.toggle();
                    }
                }
            }

        }
    }

    MenuButton {
        id: menuButton
    }
}