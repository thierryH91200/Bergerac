import AppKit


public extension Notification.Name {
    
    static let updateTransaction         = Notification.Name( "updateTransaction")
    static let updateBalance             = Notification.Name( "updateBalance")
    static let updateAccount             = Notification.Name( "updateAccount")

    static let selectionDidChangeTable   = NSTableView.selectionDidChangeNotification
    static let selectionDidChangeOutLine = NSOutlineView.selectionDidChangeNotification
    //    static let selectionDidChangeComboBox = NSComboBox.selectionDidChangeNotification
    static let selectionDidChangePopUp = NSPopUpButton.willPopUpNotification
}

extension NotificationCenter {
    
    // Send(Post) Notification
    static func send(_ key: Notification.Name) {
        self.default.post(
            name: key,
            object: nil
        )
    }
    
    // Receive(addObserver) Notification
    static func receive(_ instance: Any, selector: Selector, name: Notification.Name, object : Any? = nil) {
        self.default.addObserver(
            instance,
            selector: selector,
            name: name,
            object: object
        )
    }
    
    // Remove(removeObserver) Notification
    static func remove(_ instance: Any, name: Notification.Name, object : Any? = nil ) {
        self.default.removeObserver(
            instance,
            name: name,
            object: object
        )
    }

}
