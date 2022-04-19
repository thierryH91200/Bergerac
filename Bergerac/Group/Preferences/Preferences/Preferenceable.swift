import AppKit

public protocol Preferenceable: AnyObject {
    var toolbarItemTitle: String { get }
    var toolbarItemIcon: NSImage { get }
}
