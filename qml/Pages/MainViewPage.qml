import QtQuick 2.4
import Material 0.3
import Material.ListItems 0.1 as ListItem

import com.sunrain.bnetdisk.qmlplugin 1.0

import ".."
import "../QuickFlux/Stores"
import "../QuickFlux/Actions"
import "../QuickFlux/Scripts"

import "../Script/Utility.js" as Utility

Page {
    id: mainViewPage

    actions: [
        Action {
            iconName: "action/search"
            name: qsTr("Search")
            onTriggered: {
//                musicLibraryManager.scanLocalMusic();
//                AppActions.selectMusicScannerDirs();
            }
        },
        Action {
            iconName: "action/account_box"
            name: qsTr("Logout")
            onTriggered: {
                LoginProvider.logout();
            }
        },
        Action {
            iconName: "file/cloud_download"
            name: qsTr("Transmission")
            onTriggered: {
//                pageStack.push(Qt.resolvedUrl("DownloadViewPage.qml"))
                AppActions.showDownloadPage(pageStack);
            }
        },
        Action {
            iconName: "action/settings"
            name: qsTr("Settings")
        }
    ]

    backAction: Action {
        iconName: "navigation/menu"
        visible: true
        onTriggered: {
            sidebar.expanded = !sidebar.expanded
        }
    }

    // use an Item for extendedContent wrapper
//    actionBar.extendedContent: Item {
//        width: parent.width
//        height: dp(48)
//        Item {
//            x: (parent.width - width) +16 * Units.dp // 16 * Units.dp from ActionBar->label topMargin
//            width: actionBar.width
//            height: parent.height
//            Row {
//                id: navRow
//                spacing: Const.largeSpace
//                height: childrenRect.height
//                anchors {
//                    left: parent.left
//                    leftMargin: 16 * Units.dp //from ActionBar->leftItem
//                    verticalCenter: parent.verticalCenter
//                }
//                IconButton {
//                    color: Theme.lightDark(theme.primaryColor,
//                                           Theme.light.iconColor, Theme.dark.iconColor)
//                    action: Action {
//                        iconName: "navigation/arrow_back"
//                    }
//                }
//                IconButton {
//                    color: Theme.lightDark(theme.primaryColor,
//                                           Theme.light.iconColor, Theme.dark.iconColor)
//                    action: Action {
//                        iconName: "navigation/arrow_forward"
//                    }
//                }
//                IconButton {
//                    color: Theme.lightDark(theme.primaryColor,
//                                           Theme.light.iconColor, Theme.dark.iconColor)
//                    action: Action {
//                        iconName: "navigation/arrow_upward"
//                    }
//                }
//                IconButton {
//                    color: Theme.lightDark(theme.primaryColor,
//                                           Theme.light.iconColor, Theme.dark.iconColor)
//                    action: Action {
//                        iconName: "navigation/refresh"
//                    }
//                }
//            }
//            View {
//                radius: 2
//                anchors {
//                    left: navRow.right
//                    leftMargin: Const.largeSpace
//                    right: parent.right
//                    rightMargin: Const.largeSpace
//                }
//                height: parent.height
//                TextField {
//                    id: addrText
//                    width: parent.width
//                    text: "Here/bdisk/file/path"
//                    anchors {
////                        bottom: parent.bottom
//                        verticalCenter: parent.verticalCenter
//                    }

//                    onAccepted: {
//                        console.log("=== addrText onAccepted "+text);
//                    }
//                }
//            }

//        }
//    }

    actionBar.customContent: Item {
        anchors.fill: parent
        IconButton {
            id: refreshBtn
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            color: Theme.lightDark(theme.primaryColor, Theme.light.iconColor, Theme.dark.iconColor)
            action: Action {
                iconName: "navigation/refresh"
                onTriggered: {
                    AppActions.refreshCurrentDir();
                }
            }
        }
        ListView {
            id: pathView
            anchors {
                left: refreshBtn.right
                leftMargin: Const.middleSpace
                right: parent.right
                rightMargin: Const.middleSpace
            }
            height: parent.height > dp(48) ? dp(48) : parent.height
            clip: true
            orientation: Qt.Horizontal
            spacing: Const.tinySpace
            onCountChanged: {
                pathView.positionViewAtEnd();
            }
            onWidthChanged: {
                pathView.positionViewAtEnd();
            }
            model: DirListStore.currentPathList
            delegate: ListItem.BaseListItem {
                id: pathItem
                height: parent.height
                /// NOTE anchors.left && anchors.right should set before width property,
                /// This fix qml-material View component bug
                anchors.left: undefined
                anchors.right: undefined
                width: itemRow.width
                onClicked: {
                    if (index == 0) {
                        AppActions.showDir("/");
                    } else {
                        var dir = "";
                        for(var i=1; i<=index; ++i) {
                            dir += "/";
                            dir += DirListStore.currentPathList[i];
                        }
                        AppActions.showDir(dir);
                    }
                }
                Row {
                    id: itemRow
                    height: parent.height
                    spacing: Const.tinySpace
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        style: "subheading"
                        color:  Theme.isDarkColor(actionBar.backgroundColor)
                                ? Theme.dark.textColor
                                : Theme.light.accentColor
                        text: index == 0 ? qsTr("BNetDisk") : DirListStore.currentPathList[index]
                        verticalAlignment: Text.AlignVCenter
                    }
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.isDarkColor(actionBar.backgroundColor)
                               ? Theme.dark.iconColor
                               : Theme.light.accentColor
                        name: "navigation/chevron_right"
                        visible: index != DirListStore.currentPathList.length -1
                    }
                }
            }
        }
        Scrollbar {
            flickableItem: pathView
        }
    }

    FileSavePathDialog {}

    Sidebar {
        id: sidebar
        anchors.bottom: infoBanner.top
        width: dp(200)
        property var nameList: [qsTr("All"), qsTr("Image"), qsTr("Document"), qsTr("Video"),
            qsTr("BT"), qsTr("Audio"), qsTr("Other")]
        property var iconList: ["file/attachment", "image/image", "image/texture", "av/movie",
        "file/attachment", "image/music_note", "file/attachment"]
        Column {
            width: parent.width
            ListItem.Subheader {
                text: qsTr("Cloud Storage")
            }
            Repeater {
                model: sidebar.nameList.length
                delegate: ListItem.Standard {
                    text: sidebar.nameList[index]
                    iconName: sidebar.iconList[index]
                }
            }
            ListItem.Divider{}
            ListItem.Standard {
                action: IconButton {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    action: Action {
                        iconName: "social/share"
                        onTriggered: {
                            console.log("===== share icon click")
                        }
                    }
                }
                content: IconButton {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    action: Action {
                        iconName: "action/delete"
                        onTriggered: {
                            console.log("===== trash icon click")
                        }
                    }
                }
            }
        }
    }
    View {
        id: infoBanner
        width: sidebar.width
        height: infoColumn.height
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        backgroundColor: style === "default" ? "white" : "#333"
        Rectangle {
            width: 1
            height: parent.height
            anchors.right: parent.right
            color: style === "dark" ? Qt.rgba(0.5,0.5,0.5,0.5) : Theme.light.dividerColor
        }
        Column {
            id: infoColumn
            width: parent.width
            Rectangle {
                width: parent.width
                height: 1
                color: style === "dark" ? Qt.rgba(0.5,0.5,0.5,0.5) : Theme.light.dividerColor
            }
            ListItem.Standard {
                width: parent.width
                text: DownloadStore.downloadingModel.length + " " + qsTr("running task");
                secondaryItem: IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    action: Action {
                        iconName: "action/settings"
                        onTriggered: {
                            AppActions.showDownloadPage(pageStack);
                        }
                    }
                }
            }
        }
    }

    ListView {
        id: content
        width: parent.width
        anchors {
            top: parent.top
            left: sidebar.right
            leftMargin: Const.tinySpace
            right: parent.right
            rightMargin: Const.tinySpace
            bottom: parent.bottom
        }
        clip: true
        interactive: contentHeight > height
        onContentXChanged: {
            if(contentX != 0 && contentWidth <= width)
                contentX = 0
        }
        onContentYChanged: {
            if(contentY != 0 && contentHeight <= height)
                contentY = 0
        }
        spacing: dp(8)
        model: DirListStore.dirlistModel
        delegate: ListItem.Subtitled {
            id: dirItem
            property var object: DirListStore.dirlistModel[index] //.get(index)
            property bool isDir: object[FileObjectKey.keyIsdir] == 1
            property string path: object[FileObjectKey.keyPath]
            property string fileName: AppUtility.fileObjectPathToFileName(path)
            property string mtime: object[FileObjectKey.keyServerMTime]
            property int category: object[FileObjectKey.keyCategory]
            property int size: object[FileObjectKey.keySize]
            showDivider: true
            iconName: isDir ? "file/folder" : Utility.categoryToIcon(category)
            text: fileName
            subText: {
                var v = isDir ? qsTr("Dir") : AppUtility.sizeToStr(size)
                v += " - ";
                v += AppUtility.formatDate(mtime);
                return v;
            }
            secondaryItem: Row {
                height: childrenRect.height
                anchors.verticalCenter: parent.verticalCenter
                spacing: Const.middleSpace
                IconButton {
                    visible: !dirItem.isDir
                    enabled: !dirItem.isDir
                    action: Action {
                        iconName: "file/file_download"
                    }
                    onClicked: {
                        console.log("=== download file");
                        if (!dirItem.isDir) {
                            AppActions.askToSelectDownloadPath(path, fileName);
                        }
                    }
                }
                IconButton {
                    action: Action {
                        iconName: "social/share"
                    }
                }
                IconButton {
                    action: Action {
                        iconName: "navigation/more_vert"
                    }
                }
            }
            onClicked: {
                if (dirItem.isDir) {
                    AppActions.showDir(object[FileObjectKey.keyPath]);
                }
            }
        }
    }

    Scrollbar {
        flickableItem: content
    }
}