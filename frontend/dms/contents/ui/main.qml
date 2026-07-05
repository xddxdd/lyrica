import QtQuick
import QtWebSockets
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    layerNamespacePlugin: "lyrica"

    readonly property string serverHost: "127.0.0.1"
    readonly property int serverPort: 15650

    // Frontend config (defaults match frontend/kde/contents/config/main.xml)
    property int tlyricMode: parseInt(pluginData.tlyricMode ?? "0") ?? 0
    property int characterLimit: parseInt(pluginData.characterLimit ?? "60") || 60
    property bool shouldUseDefaultThemeFontSize: pluginData.shouldUseDefaultThemeFontSize ?? true
    property int configuredFontSize: parseInt(pluginData.configuredFontSize ?? "18") || 18
    property int layoutHeight: parseInt(pluginData.layoutHeight ?? "28") || 28
    property bool showReconnectingText: pluginData.showReconnectingText ?? true
    property bool shouldUseDefaultThemeTextColor: pluginData.shouldUseDefaultThemeTextColor ?? true
    property color configuredTextColor: pluginData.configuredTextColor ?? "#ffffff"
    property string placeholderIconName: pluginData.placeholderIconName ?? "music-amarok-symbolic"

    // Backend config (defaults match frontend/kde/contents/config/main.xml Backend group)
    property string disabledPlayers: pluginData.disabledPlayers ?? "firefox,chromium,plasma-browser-integration,kdeconnect"
    property string enabledLyricProviders: pluginData.enabledLyricProviders ?? "Mpris2Text,File,YesPlayMusic,SPlayer,NeteaseTrackID,FeelUOwnNetease,Netease"
    property string disabledFolders: pluginData.disabledFolders ?? ""
    property int onlineSearchPattern: parseInt(pluginData.onlineSearchPattern ?? "0") ?? 0
    property string onlineSearchTimeout: pluginData.onlineSearchTimeout ?? "10"
    property bool onlineSearchRetry: pluginData.onlineSearchRetry ?? true
    property string onlineSearchMaxRetries: pluginData.onlineSearchMaxRetries ?? "3"
    property string lyricSearchFolder: pluginData.lyricSearchFolder ?? ""
    property bool lyricCacheEnabled: pluginData.lyricCacheEnabled ?? true
    property string lyricCacheTtlDays: pluginData.lyricCacheTtlDays ?? "30"

    property int effectiveFontSize: shouldUseDefaultThemeFontSize ? Theme.fontSizeSmall : configuredFontSize
    property color effectiveTextColor: shouldUseDefaultThemeTextColor ? Theme.surfaceText : configuredTextColor

    property string currentText: ""
    property bool showPlaceholder: true

    function splitAndTrim(value, separator) {
        if (!value) return []
        return value.split(separator).map(s => s.trim()).filter(s => s.length > 0)
    }

    function splitMulti(value) {
        if (!value) return []
        return value.split(/[\n,]/).map(s => s.trim()).filter(s => s.length > 0)
    }

    function sendConfigToBackend() {
        const configString = JSON.stringify({
            disabled_players: splitAndTrim(disabledPlayers, ","),
            enabled_lyric_providers: splitAndTrim(enabledLyricProviders, ","),
            online_search_pattern: onlineSearchPattern,
            disabled_folders: splitMulti(disabledFolders),
            online_search_timeout_secs: parseInt(onlineSearchTimeout) || 10,
            online_search_retry: onlineSearchRetry,
            online_search_max_retries: parseInt(onlineSearchMaxRetries) || 3,
            lyric_search_folder: lyricSearchFolder || "~/Music/lrc",
            lyric_cache_enabled: lyricCacheEnabled,
            lyric_cache_ttl_days: parseInt(lyricCacheTtlDays) || 30,
        })
        const xhr = new XMLHttpRequest()
        console.log("[lyrica] Updating config")
        xhr.open("POST", "http://" + serverHost + ":" + serverPort + "/config/update", true)
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.onreadystatechange = () => {
            if (xhr.readyState == 4) {
                console.log("[lyrica]" + xhr.responseText)
            }
        }
        xhr.send(configString)
    }

    Timer {
        id: reconnectTimer
        interval: 500
        repeat: false
        onTriggered: {
            if (socket.active == false) {
                socket.active = true
            }
        }
    }

    WebSocket {
        id: socket
        url: "ws://" + serverHost + ":" + serverPort + "/ws"
        active: false

        onTextMessageReceived: (message) => {
            message = JSON.parse(message)
            switch (message["id"]) {
                case 1:
                    // Update music metadata
                    root.currentText = ""
                    root.showPlaceholder = true
                    break
                case 0:
                    // Update lyric line
                    let lyric_text = message["data"]["update_lyric_line"]["text"]
                    let lyric_alt = message["data"]["update_lyric_line"]["alt"]
                    let update_line = "[No lyric]"
                    switch (root.tlyricMode) {
                        case 0:
                            update_line = lyric_text || ""
                            break
                        case 1:
                            update_line = lyric_alt || lyric_text || ""
                            break
                        case 2:
                            update_line = lyric_text || ""
                            if (lyric_alt) {
                                update_line += " | " + lyric_alt
                            }
                            break
                        case 3:
                            if (lyric_alt) {
                                update_line = lyric_alt + " | " + lyric_text
                            } else {
                                update_line = lyric_text || ""
                            }
                            break
                    }
                    if (update_line.length > root.characterLimit) {
                        update_line = update_line.slice(0, root.characterLimit) + "..."
                    }
                    root.currentText = update_line
                    root.showPlaceholder = (update_line.length == 0)
                    break
            }
        }

        onStatusChanged: (status) => {
            if (status == WebSocket.Closed || status == WebSocket.Error) {
                if (root.showReconnectingText) {
                    root.currentText = "[Reconnecting...]"
                } else {
                    root.currentText = ""
                }
                root.showPlaceholder = (root.currentText.length == 0)
                socket.active = false
                reconnectTimer.start()
            } else if (status == WebSocket.Open) {
                console.log("[lyrica] WebSocket connected")
                sendConfigToBackend()
            }
        }
    }

    Component.onCompleted: {
        socket.active = true
    }

    function showIcon() {
        return showPlaceholder && placeholderIconName.length > 0
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS
            DankIcon {
                name: root.placeholderIconName
                size: root.iconSize
                color: root.effectiveTextColor
                visible: root.showIcon()
                anchors.verticalCenter: parent.verticalCenter
            }
            StyledText {
                text: root.currentText
                font.pixelSize: root.effectiveFontSize
                color: root.effectiveTextColor
                height: root.layoutHeight
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS
            DankIcon {
                name: root.placeholderIconName
                size: root.iconSize
                color: root.effectiveTextColor
                visible: root.showIcon()
                anchors.horizontalCenter: parent.horizontalCenter
            }
            StyledText {
                text: root.currentText
                font.pixelSize: root.effectiveFontSize
                color: root.effectiveTextColor
                height: root.layoutHeight
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            headerText: "Lyrica"
            showCloseButton: true

            StyledText {
                width: parent.width
                text: root.currentText
                font.pixelSize: Theme.fontSizeMedium
                color: root.effectiveTextColor
                wrapMode: Text.Wrap
            }
        }
    }

    popoutWidth: 360
    popoutHeight: 140
}