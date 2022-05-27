import Cocoa

extension NSStoryboard.SceneIdentifier
{
    // The scene identifier for your custom titlebar accessory view controller
    static let customTitlebarAccessoryViewController = NSStoryboard.SceneIdentifier("CustomTitlebarAccessoryViewController")
}

extension NSToolbar.Identifier
{
    static let mainWindowToolbarIdentifier = NSToolbar.Identifier("MainWindowToolbar")
}

extension NSToolbarItem.Identifier
{
    //  Standard examples of `NSToolbarItem`
    static let toolbarColorItem = NSToolbarItem.Identifier("ToolbarColorItem")

    //  `visibilityPriority` is set to `.low` for these items to demostrate how
    //  to make some items disappear before others when space gets a bit tight.
    static let toolbarItemMoreInfo = NSToolbarItem.Identifier("ToolbarMoreInfoItem")
    static let toolbarItemCalc = NSToolbarItem.Identifier("toolbarItemCalc")
    static let toolbarItemPreference = NSToolbarItem.Identifier("toolbarPreferenceItem")

    /// Example of `NSMenuToolbarItem`
    static let toolbarMoreActions = NSToolbarItem.Identifier("toolbarMoreActionsItem")
    
    /// Example of `NSSharingServicePickerToolbarItem`
    static let toolbarShareButtonItem = NSToolbarItem.Identifier(rawValue: "toolbarShareButtonItem")
    
    /// Example of `NSToolbarItemGroup`
    static let toolbarLightDarItem = NSToolbarItem.Identifier("toolbarLightDarItem")
    
    /// Example of `NSSearchToolbarItem`
    static let toolbarSearchItem = NSToolbarItem.Identifier("ToolbarSearchItem")
    
}
