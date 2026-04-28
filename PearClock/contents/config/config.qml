/*
    SPDX-FileCopyrightText: 2025 Alexandru Balan

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.15

import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18n("General")
         icon: "preferences-desktop-plasma"
         source: "../ui/ConfigGeneral.qml"
    }
}

