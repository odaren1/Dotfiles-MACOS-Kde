import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.taskmanager       as TaskManager
import org.kde.kirigami          as Kirigami
import org.kde.activities        as Activities
import "../tools/Tools.js"       as Tools
import org.kde.plasma.private.appmenu 1.0 as AppMenuPrivate
import org.kde.plasma.extras 2.0 as PlasmaExtras

PlasmoidItem {
    id: root
    clip: true
    Plasmoid.constraintHints:   Plasmoid.CanFillArea
    preferredRepresentation:    fullRepresentation

    readonly property bool isVertical:              plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool existsWindowActive:      windowInfoLoader.item && windowInfoLoader.item.existsWindowActive
    readonly property bool isActiveWindowPinned:    existsWindowActive && activeTaskItem.isOnAllDesktops
    readonly property bool isActiveWindowMaximized: existsWindowActive && activeTaskItem.isMaximized
    readonly property var cfg:                      plasmoid.configuration

    property Item activeTaskItem:                   windowInfoLoader.item.activeTaskItem
    property var icon:                              Tools.getIcon()
    property string text:                           Tools.getText()
    states: [
        State{
            name: "editMode"
            when:  Plasmoid.containment.corona?.editMode?true:false
            PropertyChanges{
                target: root
                text:   "Edit Mode"
                icon:   "document-edit"
                Layout.minimumWidth: isVertical?parent.width:titleLayout.implicitWidth
                Layout.maximumWidth: Layout.minimumWidth
                Layout.minimumHeight: isVertical?titleLayout.implicitHeight:parent.height
                Layout.maximumHeight: Layout.minimumHeight
            }
        },
        State{
            name: "contentsLength"
            when: cfg.lengthKind === 0 && !isVertical
            PropertyChanges{
                target: root
                Layout.minimumWidth: titleLayout.implicitWidth
                Layout.maximumWidth: Layout.minimumWidth
                Layout.fillHeight:   true
            }
        },
        State{
            name: "fixedLength"
            when: cfg.lengthKind === 1 && !isVertical
            PropertyChanges{
                target: root
                Layout.minimumWidth: cfg.fixedLength
                Layout.maximumWidth: cfg.fixedLength
                Layout.fillHeight:   true
            }
        },
        State{
            name: "maximumLength"
            when: cfg.lengthKind === 2 && !isVertical
            PropertyChanges{
                target: root
                Layout.minimumWidth: Math.min(cfg.fixedLength,titleLayout.implicitWidth)
                Layout.maximumWidth: Math.min(cfg.fixedLength,titleLayout.implicitWidth)
                Layout.fillHeight:   true
            }
        },
        State{
            name: "contentsLengthVert"
            when: cfg.lengthKind === 0 && isVertical
            PropertyChanges{
                target: root
                Layout.minimumHeight: titleLayout.implicitHeight
                Layout.maximumHeight: Layout.minimumHeight
                Layout.fillWidth:     true
            }
        },
        State{
            name: "fixedLengthVert"
            when: cfg.lengthKind === 1 && isVertical
            PropertyChanges{
                target: root
                Layout.minimumHeight: cfg.fixedLength
                Layout.maximumHeight: cfg.fixedLength
                Layout.fillWidth:     true
            }
        },
        State{
            name: "maximumLengthVert"
            when: cfg.lengthKind === 2 && isVertical
            PropertyChanges{
                target: root
                Layout.minimumHeight: Math.min(cfg.fixedLength,titleLayout.implicitHeight)
                Layout.maximumHeight: Math.min(cfg.fixedLength,titleLayout.implicitHeight)
                Layout.fillWidth:     true
            }
        }
    ]

    TaskManager.ActivityInfo { id: activityInfo }
    Activities.ActivityInfo { id: fullActivityInfo; activityId: ":current" }
    TaskManager.VirtualDesktopInfo { id: virtualDesktopInfo }
    Loader {
        id: windowInfoLoader
        sourceComponent: plasmaTasksModel
        Component{
            id: plasmaTasksModel
            PlasmaTasksModel{}
        }
    }
    
    function hideOthers() {
        if (windowInfoLoader.item && existsWindowActive) {
            windowInfoLoader.item.hideOthers();
        }
    }
    
    Title { id: titleLayout }
    ActionsMouseArea{
        id: actionsMouseArea
        onClicked: function(event) {
            if (event.button === Qt.LeftButton && existsWindowActive) {
                appMenu.openRelative()
            } else if(existsWindowActive && event.button === Qt.MiddleButton && cfg.closeAllowed) {
                windowInfoLoader.item.requestClose();
            }
        }
    }
    
    // Meniu pentru Quit Application
    PlasmaExtras.Menu {
        id: appMenu
        visualParent: titleLayout
        placement: PlasmaExtras.Menu.BottomPosedLeftAlignedPopup
        
        PlasmaExtras.MenuItem {
            text: {
                if (existsWindowActive && activeTaskItem) {
                    var appName = activeTaskItem.appName || activeTaskItem.modelAppName || "Application"
                    return "Hide " + appName + "\t⌘H"
                }
                return "Hide Application\t⌘H"
            }
            icon: "window-minimize"
            enabled: existsWindowActive && activeTaskItem !== null
            onClicked: {
                if (existsWindowActive && activeTaskItem) {
                    windowInfoLoader.item.toggleMinimized()
                }
                appMenu.close()
            }
        }
        
        PlasmaExtras.MenuItem {
            text: "Hide Others\t⌥⌘H"
            icon: "view-hidden"
            enabled: existsWindowActive && activeTaskItem !== null
            onClicked: {
                if (existsWindowActive && activeTaskItem && windowInfoLoader.item) {
                    root.hideOthers()
                }
                appMenu.close()
            }
        }
        
        PlasmaExtras.MenuItem {
            separator: true
        }
        
        PlasmaExtras.MenuItem {
            text: {
                if (existsWindowActive && activeTaskItem) {
                    var appName = activeTaskItem.appName || activeTaskItem.modelAppName || "Application"
                    return "Quit " + appName + "\t⌘Q"
                }
                return "Quit Application\t⌘Q"
            }
            icon: "application-exit"
            enabled: existsWindowActive && activeTaskItem !== null
            onClicked: {
                if (existsWindowActive && activeTaskItem) {
                    windowInfoLoader.item.requestClose()
                }
                appMenu.close()
            }
        }
    }
    
    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        active: text !== ""
        interactive: true
        location: plasmoid.location
        visible: cfg.showTooltip
        mainItem: RowLayout {
            spacing:                    Kirigami.Units.largeSpacing
            Layout.margins:             Kirigami.Units.smallSpacing
            Kirigami.Icon {
                source: root.icon
            }
            PlasmaComponents.Label {
                id: fullText
                elide:Text.ElideRight
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                text:root.text
            }
        }
    }
}
