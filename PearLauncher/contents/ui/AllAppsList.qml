import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0
import org.kde.draganddrop 2.0
import org.kde.kirigami as Kirigami

ColumnLayout {
	id: allApps
	spacing: 0

	property QtObject allAppsModel: rootModel.modelForRow(2)
	property QtObject recentAppsModel
	property QtObject currentModel: rootModel.modelForRow(2)

	property var currentStateIndex: 0// Plasmoid.configuration.defaultPage

	property bool showItemsInGrid: plasmoid.configuration.showAllAppsInGrid
	property bool showItemsInList: plasmoid.configuration.showAllAppsInList

	// Grid-ul cu aplicații recente se afișează doar în "All Applications" (și listă, și grid)
	property bool isAllApplicationsView: main.showAllApps && (currentModel === allAppsModel)
	property bool showRecentAppsGrid: isAllApplicationsView && recentAppsModel && recentAppsModel.count > 0

	property Component preferredAppsViewComponent: showItemsInGrid ? applicationsGridViewComponent 
												: applicationsListViewComponent

	property alias viewItem: appViewLoader.item

	property var appsCategoriesList: { 

		var categories = [];
		var categoryName;
		var categoryIcon;

		for (var i = 2; i < rootModel.count - 2; i++) {
			categoryName  = rootModel.data(rootModel.index(i, 0), Qt.DisplayRole);
			categoryIcon  = rootModel.data(rootModel.index(i, 0), Qt.DecorationRole);
			categories.push({
				name: categoryName,
				modelIndex: i,
				icon: categoryIcon
			});
		}
		allApps.allAppsModel =  rootModel.modelForRow(2)
		allApps.currentModel =  rootModel.modelForRow(2)
		return categories;
	}

	property var slicedCategories: appsCategoriesList.slice(1)

	function updateShowedModel(index){
		currentModel = rootModel.modelForRow(index);
	}

	function reset(){
		currentStateIndex = 0
	}



	AppCategorySwitcher {
		id: categorySwitcher

		Layout.preferredWidth: parent.width-fs.innerPadding
    	Layout.preferredHeight: visible ? 40 : 0
		model: appsCategoriesList
		visible: main.showAllApps

		Component.onCompleted: {
			categorySwitcher.categorySwitched.connect(updateShowedModel)
			// Sincronizare inițială - asigură că All Applications e selectat
			if (appsCategoriesList.length > 0) {
				updateShowedModel(appsCategoriesList[0].modelIndex)
			}
		}
	}

	Loader {
		id: appViewLoader
		
		Layout.fillHeight: true		
		Layout.fillWidth: true
		
		sourceComponent: preferredAppsViewComponent
		active: true
	}

	onPreferredAppsViewComponentChanged: {
		appViewLoader.sourceComponent = preferredAppsViewComponent;
	}

	Component {
		id: applicationsListViewComponent
		AppListView {
			id: appList

			anchors.fill: parent

			showSectionSeparator: false
			headerPositioning: ListView.InlineHeader

			model: main.showAllApps ? currentModel : globalFavorites

			header: Loader {
				active: allApps.showRecentAppsGrid
				width: active && item ? parent.width : 0
				height: active && item ? item.height : 0
				sourceComponent: recentAppsGridComponent
			}
		}
	}

	property real recentAppsBottomSpacing: 25

	Component {
		id: recentAppsGridComponent
		Item {
			width: parent ? parent.width - fs.innerPadding : 0
			height: recentAppsGridInner.height + separatorLine.height + allApps.recentAppsBottomSpacing

			Item {
				id: recentAppsGridInner
				anchors.left: parent.left
				anchors.top: parent.top
				anchors.leftMargin: fs.innerPadding / 2
				width: parent.width - fs.innerPadding
				height: root.cellSizeHeight

				GridView {
					id: grid
					anchors.fill: parent
					cellWidth: root.cellSizeWidth
					cellHeight: root.cellSizeHeight
					model: recentAppsModel
					interactive: false
					clip: true
					property bool canMoveWithKeyboard: false
					property bool movedWithWheel: false

					delegate: AppGridViewDelegate {
						triggerModel: grid.model
					}
				}
			}

			Rectangle {
				id: separatorLine
				anchors.top: recentAppsGridInner.bottom
				anchors.topMargin: 10
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.leftMargin: fs.innerPadding / 2
				anchors.rightMargin: fs.innerPadding / 2
				height: 1.5
				color: main.contrastBgColor
			}
		}
	}

	Component {
		id: applicationsGridViewComponent

		Item {
			anchors.fill: parent

			property int mainGridRows: {
				var m = main.showAllApps ? currentModel : globalFavorites
				var c = m ? m.count : 0
				var cols = root.columns
				return cols > 0 ? Math.ceil(c / cols) : 0
			}
			property real mainGridContentHeight: mainGridRows * root.cellSizeHeight

			Flickable {
				id: scrollFlickable
				anchors.fill: parent
				contentWidth: scrollColumn.width
				contentHeight: scrollColumn.height
				boundsBehavior: Flickable.StopAtBounds
				clip: true
				interactive: contentHeight > height

				property bool movedWithWheel: false

				Connections {
					target: root
					function onVisibleChanged() {
						if (!root.visible) {
							scrollFlickable.contentY = 0
							grid.currentIndex = 0
						}
					}
				}

				Column {
					id: scrollColumn
					width: scrollFlickable.width
					spacing: allApps.showRecentAppsGrid ? 15 : 0

					Loader {
						id: recentAppsLoader
						width: parent.width - fs.innerPadding
						height: active && item ? item.height : 0
						active: allApps.showRecentAppsGrid
						sourceComponent: recentAppsGridComponent
						onLoaded: if (item) item.width = Qt.binding(function() { return recentAppsLoader.width })
					}

					Item {
						width: scrollColumn.width
						height: mainGridContentHeight

						AppGridView {
							id: grid
							anchors.fill: parent
							anchors.leftMargin: fs.innerPadding / 2

							model: main.showAllApps ? currentModel : globalFavorites
							canMoveWithKeyboard: true
							interactive: false
						}
					}
				}

				Kirigami.WheelHandler {
					target: scrollFlickable
					filterMouseEvents: true
					verticalStepSize: 20 * Qt.styleHints.wheelScrollLines
					onWheel: {
						scrollFlickable.movedWithWheel = true
						movedWithWheelTimer.restart()
					}
				}

				Timer {
					id: movedWithWheelTimer
					interval: 200
					onTriggered: scrollFlickable.movedWithWheel = false
				}

				ScrollBar.vertical: Scrollbar {
					active: scrollFlickable.movedWithWheel
				}

				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.NoButton
					z: 10
					onWheel: (wheel) => {
						if (scrollFlickable.contentHeight > scrollFlickable.height) {
							var step = 20 * Qt.styleHints.wheelScrollLines
							var delta = (wheel.angleDelta.y / 120) * step
							scrollFlickable.contentY = Math.max(0, Math.min(scrollFlickable.contentHeight - scrollFlickable.height,
								scrollFlickable.contentY - delta))
							scrollFlickable.movedWithWheel = true
							movedWithWheelTimer.restart()
						}
					}
				}
			}
		}
	}

	Component.onCompleted: {
		updateRecentAppsModel();
	}

	function updateRecentAppsModel() {
		// RootModel cu showRecentApps: rândul 0 conține de obicei aplicațiile recente
		var recent = rootModel.modelForRow(0);
		if (recent) {
			allApps.recentAppsModel = recent;
		}
	}

	Connections {
		target: rootModel
		function onRefreshed() {
			updateRecentAppsModel();
		}
	}
}
