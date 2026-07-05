import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "lyrica"

    StyledText {
        width: parent.width
        text: "Lyrica"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Display synchronized lyrics from the Lyrica backend in the bar"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    // -- Frontend --
    StyledText {
        width: parent.width
        text: "Frontend"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.surfaceText
        topPadding: Theme.spacingM
    }

    SelectionSetting {
        settingKey: "tlyricMode"
        label: "Lyric translation mode"
        description: "How to display the original lyric and its translation"
        options: [
            { label: "Show original lyric only", value: "0" },
            { label: "Show translation only", value: "1" },
            { label: "Original lyric | Translation", value: "2" },
            { label: "Translation | Original lyric", value: "3" }
        ]
        defaultValue: "0"
    }

    StringSetting {
        settingKey: "characterLimit"
        label: "Character limit"
        description: "Truncate the displayed line to this many characters (0-9999)"
        placeholder: "60"
        defaultValue: "60"
    }

    ToggleSetting {
        settingKey: "shouldUseDefaultThemeFontSize"
        label: "Use theme default font size"
        description: "Ignore the custom font size below"
        defaultValue: true
    }

    StringSetting {
        settingKey: "configuredFontSize"
        label: "Custom font size"
        description: "Pixel size used when the toggle above is off"
        placeholder: "18"
        defaultValue: "18"
    }

    StringSetting {
        settingKey: "layoutHeight"
        label: "Layout height"
        description: "Height of the lyric line in the bar"
        placeholder: "28"
        defaultValue: "28"
    }

    ToggleSetting {
        settingKey: "showReconnectingText"
        label: "Show [Reconnecting...] text when connection lost"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "shouldUseDefaultThemeTextColor"
        label: "Use theme default text color"
        description: "Ignore the custom color below"
        defaultValue: true
    }

    ColorSetting {
        settingKey: "configuredTextColor"
        label: "Custom text color"
        description: "Used when the toggle above is off"
        defaultValue: "#ffffff"
    }

    StringSetting {
        settingKey: "placeholderIconName"
        label: "Placeholder icon name"
        description: "Freedesktop icon name shown when there is no lyric. Empty to disable."
        placeholder: "music-amarok-symbolic"
        defaultValue: "music-amarok-symbolic"
    }

    // -- Backend --
    StyledText {
        width: parent.width
        text: "Backend"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.surfaceText
        topPadding: Theme.spacingM
    }

    StyledText {
        width: parent.width
        text: "Backend settings are shared among all Lyrica widgets. Using only one widget is recommended."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    StringSetting {
        settingKey: "disabledPlayers"
        label: "Disabled players (comma separated)"
        placeholder: "firefox,chromium,plasma-browser-integration,kdeconnect"
        defaultValue: "firefox,chromium,plasma-browser-integration,kdeconnect"
    }

    StringSetting {
        settingKey: "enabledLyricProviders"
        label: "Enabled lyric providers (comma separated)"
        description: "See https://github.com/chiyuki0325/lyrica/blob/v1/docs/LYRIC_PROVIDERS.md for available providers"
        placeholder: "Mpris2Text,File,YesPlayMusic,SPlayer,NeteaseTrackID,FeelUOwnNetease,Netease"
        defaultValue: "Mpris2Text,File,YesPlayMusic,SPlayer,NeteaseTrackID,FeelUOwnNetease,Netease"
    }

    StringSetting {
        settingKey: "disabledFolders"
        label: "Disabled folders (one per line)"
        description: "Music in these folders is treated as instrumental and will not be searched for lyrics"
        placeholder: "/home/user/Music/lyric"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "lyricSearchFolder"
        label: "Alternative folder to search for .lrc files"
        placeholder: "/home/user/Music/lrc"
        defaultValue: ""
    }

    SelectionSetting {
        settingKey: "onlineSearchPattern"
        label: "Online lyric search pattern"
        options: [
            { label: "Title + Artist", value: 0 },
            { label: "Title only (may not be accurate)", value: 1 }
        ]
        defaultValue: "0"
    }

    StringSetting {
        settingKey: "onlineSearchTimeout"
        label: "Online search timeout (seconds)"
        placeholder: "10"
        defaultValue: "10"
    }

    ToggleSetting {
        settingKey: "onlineSearchRetry"
        label: "Retry online search if failed"
        defaultValue: true
    }

    StringSetting {
        settingKey: "onlineSearchMaxRetries"
        label: "Max retries for online search (if retry enabled)"
        placeholder: "3"
        defaultValue: "3"
    }

    ToggleSetting {
        settingKey: "lyricCacheEnabled"
        label: "Cache online lyrics to disk"
        defaultValue: true
    }

    StringSetting {
        settingKey: "lyricCacheTtlDays"
        label: "Cache TTL (days, 0 = never expire)"
        placeholder: "30"
        defaultValue: "30"
    }
}
