import QtQuick 2.0

Item {
    property color backgroundColor: "#fafafa"
    property color foregroundColor: "#202020"
    property color unobtrusiveForegroundColor: Qt.tint(foregroundColor, Qt.rgba(backgroundColor.r, backgroundColor.g, backgroundColor.b, 0.4))

    property color accentColor: "#57baae"
    property color iconColor: "#808080"

    property color tileBackgroundColor: Qt.tint(backgroundColor, Qt.rgba(foregroundColor.r, foregroundColor.g, foregroundColor.b, 0.05))
    property color tileForegroundColor: foregroundColor
    property color tileOverlayColor: Qt.tint(backgroundColor, Qt.rgba(foregroundColor.r, foregroundColor.g, foregroundColor.b, 0.1))
    property color tileOverlayForegroundColor: foregroundColor
    property color tileOverlayIconColor: iconColor

    property color tooltipBackgroundColor: tileOverlayColor

    property int cornerRadius: 6
    property int smallCornerRadius: 4

    readonly property int smallMargins: 8
    readonly property int margins: 16
    readonly property int bigMargins: 32
    readonly property int hugeMargins: 64

    readonly property int smallDelegateHeight: 50
    readonly property int delegateHeight: 60
    readonly property int largeDelegateHeight: 80

    readonly property int smallIconSize: 16
    readonly property int iconSize: 24
    readonly property int bigIconSize: 32
    readonly property int largeIconSize: 40
    readonly property int hugeIconSize: 64

    // Note: Font files need to be provided in a "fonts" folder in the style
    property string fontFamily: "Ubuntu"


    // Fonts
    readonly property font extraSmallFont: Qt.font({
        family: "Ubuntu",
        pixelSize: 10
    })
    readonly property font smallFont: Qt.font({
        family: "Ubuntu",
        pixelSize: 13
    })
    readonly property font font: Qt.font({
        family: "Ubuntu",
        pixelSize: 16
    })
    readonly property font bigFont: Qt.font({
        family: "Ubuntu",
        pixelSize: 20
    })
    readonly property font largeFont: Qt.font({
        family: "Ubuntu",
        pixelSize: 32
    })
    readonly property font hugeFont: Qt.font({
        family: "Ubuntu",
        pixelSize: 46
    })


    // Icon/graph colors for various interfaces
    property var interfaceColors: {
        "temperaturesensor": "red",
        "humiditysensor": "deepskyblue",
        "moisturesensor":"blue",
        "lightsensor": "orange",
        "conductivitysensor": "green",
        "pressuresensor": "grey",
        "noisesensor": "darkviolet",
        "cosensor": "darkgray",
        "co2sensor": "turquoise",
        "gassensor": "yellow",
        "daylightsensor": "gold",
        "presencesensor": "darkblue",
        "closablesensor": "green",
        "smartmeterconsumer": "orange",
        "smartmeterproducer": "lightgreen",
        "energymeter": "deepskyblue",
        "heating" : "crimson",
        "cooling": "dodgerBlue",
        "thermostat": "dodgerblue",
        "irrigation": "lightblue",
        "windspeedsensor": "blue",
        "ventilation": "lightblue",
        "watersensor": "aqua",
        "waterlevelsensor": "aqua",
        "phsensor": "green",
        "o2sensor": "lightblue",
        "orpsensor": "yellow",
        "powersocket": "aquamarine",
        "evcharger": "limegreen",
        "energystorage": "limegreen"
    }

    property var stateColors: {
        "totalEnergyConsumed": "orange",
        "totalEnergyProduced": "lightgreen",
        "currentPower": "deepskyblue",
    }

    property color red: "indianred"
    property color green: "mediumseagreen"
    property color yellow: "gold"
    property color white: "white"
    property color gray: "gray"
    property color darkGray: "darkGray"
    property color blue: "deepskyblue"
    property color orange: "#f6a625"
    property color purple: "#6d5fd5"
    property color lime: "#99ca53"

    readonly property int fastAnimationDuration: 100
    readonly property int animationDuration: 150
    readonly property int slowAnimationDuration: 300
    readonly property int sleepyAnimationDuration: 2000
}
