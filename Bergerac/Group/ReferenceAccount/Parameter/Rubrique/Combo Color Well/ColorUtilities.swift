import AppKit

extension NSColor {
    func colorByDesaturating(_ desaturationRatio: CGFloat) -> NSColor {
        return NSColor(hue: self.hueComponent,
                       saturation: self.saturationComponent * desaturationRatio,
                       brightness: self.brightnessComponent,
                       alpha: self.alphaComponent)
    }
}
