import * as React from "C:\\Program Files (x86)\\Oni\\resources\\app\\node_modules\\react"
import * as Oni from "C:\\Program Files (x86)\\Oni\\resources\\app\\node_modules\\oni-api"

export const activate = (oni: Oni.Plugin.Api) => {
    console.log("config activated")

    // Input
    //
    // Add input bindings here:
    //
    oni.input.bind("<c-enter>", () => console.log("Control+Enter was pressed"))

    //
    // Or remove the default bindings here by uncommenting the below line:
    //
    // oni.input.unbind("<c-p>")

}

export const deactivate = (oni: Oni.Plugin.Api) => {
    console.log("config deactivated")
}

export const configuration = {
    //add custom config here, such as

    "ui.colorscheme": "nord",

    "oni.useDefaultConfig": false,
    //"oni.bookmarks": ["~/Documents"],
    "oni.loadInitVim": true,
    //"editor.fontSize": "12px",
    //"editor.fontFamily": "Monaco",

    // UI customizations
    "ui.animations.enabled": true,
    "ui.fontSmoothing": "auto",
}
