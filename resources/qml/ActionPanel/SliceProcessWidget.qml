// Copyright (c) 2018 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 as Controls1

import UM 1.1 as UM
import Cura 1.0 as Cura


// This element contains all the elements the user needs to create a printjob from the
// model(s) that is(are) on the buildplate. Mainly the button to start/stop the slicing
// process and a progress bar to see the progress of the process.
Column
{
    id: widget

    spacing: UM.Theme.getSize("thin_margin").height

    UM.I18nCatalog
    {
        id: catalog
        name: "cura"
    }

    property real progress: UM.Backend.progress
    property int backendState: UM.Backend.state

    function sliceOrStopSlicing()
    {
        if (widget.backendState == UM.Backend.NotStarted)
        {
            CuraApplication.backend.forceSlice()
        }
        else
        {
            CuraApplication.backend.stopSlicing()
        }
    }

    Label
    {
        id: autoSlicingLabel
        width: parent.width
        visible: prepareButtons.autoSlice && (widget.backendState == UM.Backend.Processing || widget.backendState == UM.Backend.NotStarted)

        text: catalog.i18nc("@label:PrintjobStatus", "Auto slicing...")
        color: UM.Theme.getColor("text")
        font: UM.Theme.getFont("default")
        renderType: Text.NativeRendering
    }

    Cura.IconWithText
    {
        id: unableToSliceMessage
        width: parent.width
        visible: widget.backendState == UM.Backend.Error

        text: catalog.i18nc("@label:PrintjobStatus", "Unable to Slice")
        source: UM.Theme.getIcon("warning")
        iconColor: UM.Theme.getColor("warning")
    }

    // Progress bar, only visible when the backend is in the process of slice the printjob
    ProgressBar
    {
        id: progressBar
        width: parent.width
        height: UM.Theme.getSize("progressbar").height
        value: progress
        indeterminate: widget.backendState == UM.Backend.NotStarted
        visible: (widget.backendState == UM.Backend.Processing || (prepareButtons.autoSlice && widget.backendState == UM.Backend.NotStarted))

        background: Rectangle
        {
            anchors.fill: parent
            radius: UM.Theme.getSize("progressbar_radius").width
            color: UM.Theme.getColor("progressbar_background")
        }

        contentItem: Item
        {
            anchors.fill: parent
            Rectangle
            {
                width: progressBar.visualPosition * parent.width
                height: parent.height
                radius: UM.Theme.getSize("progressbar_radius").width
                color: UM.Theme.getColor("progressbar_control")
            }
        }
    }

    Item
    {
        id: prepareButtons
        // Get the current value from the preferences
        property bool autoSlice: UM.Preferences.getValue("general/auto_slice")
        // Disable the slice process when

        width: parent.width
        height: UM.Theme.getSize("action_button").height
        visible: !autoSlice
        Cura.PrimaryButton
        {
            id: sliceButton
            fixedWidthMode: true
            anchors.fill: parent
            text: catalog.i18nc("@button", "Slice")
            tooltip: catalog.i18nc("@label", "Start the slicing process")
            enabled: widget.backendState != UM.Backend.Error
            visible: widget.backendState == UM.Backend.NotStarted || widget.backendState == UM.Backend.Error
            onClicked: sliceOrStopSlicing()
        }

        Cura.SecondaryButton
        {
            id: cancelButton
            fixedWidthMode: true
            anchors.fill: parent
            text: catalog.i18nc("@button", "Cancel")
            enabled: sliceButton.enabled
            visible: !sliceButton.visible
            onClicked: sliceOrStopSlicing()
        }
    }


    // React when the user changes the preference of having the auto slice enabled
    Connections
    {
        target: UM.Preferences
        onPreferenceChanged:
        {
            var autoSlice = UM.Preferences.getValue("general/auto_slice")
            if(prepareButtons.autoSlice != autoSlice)
            {
                prepareButtons.autoSlice = autoSlice
                if(autoSlice)
                {
                    CuraApplication.backend.forceSlice()
                }
            }
        }
    }

    // Shortcut for "slice/stop"
    Controls1.Action
    {
        shortcut: "Ctrl+P"
        onTriggered:
        {
            if (prepareButton.enabled)
            {
                sliceOrStopSlicing()
            }
        }
    }
}
