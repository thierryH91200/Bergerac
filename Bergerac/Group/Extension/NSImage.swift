import AppKit

extension NSImage {
    
    func imageWithTintColor(tintColor: NSColor) -> NSImage {
        if self.isTemplate == false {
            return self
        }
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        tintColor.set()
        __NSRectFillUsingOperation(NSRect(
            x: 0,
            y: 0,
            width: image.size.width,
            height: image.size.height), NSCompositingOperation.sourceAtop)
        
        image.unlockFocus()
        image.isTemplate = false
        
        return image
    }
    
    func writeToFile(file: URL, usingType type: NSBitmapImageRep.FileType) -> Bool {
        let properties = [NSBitmapImageRep.PropertyKey.compressionFactor: 1.0]
        guard
            let imageData = tiffRepresentation,
            let imageRep = NSBitmapImageRep(data: imageData),
            let fileData = imageRep.representation(using: type, properties: properties)
        else { return false }
        
        do {
            try fileData.write(to: file)
        } catch {
            return false
        }
        return true
    }
}

final class Image : NSObject {
    
    static let shared = Image()
    
    func getImage(name: String) -> NSImage
    {
        var image = NSImage(named: NSImage.Name( name))
//        var image = Bundle.main.image(forResource: NSImage.Name( name))
        if image == nil {
            let config = NSImage.SymbolConfiguration(scale: .large)
            image = NSImage(systemSymbolName: name, accessibilityDescription: nil)?.withSymbolConfiguration( config)
        }
        return image!
    }
}


