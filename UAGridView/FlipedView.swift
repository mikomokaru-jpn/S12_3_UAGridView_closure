//---- FlipedView.swift ----
import Cocoa

class FlipedView: NSView {
    //イニシャライザ
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.wantsLayer = true
        self.layer?.borderWidth = 1
        self.layer?.borderColor = NSColor.black.cgColor
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    override var isFlipped:Bool {
        get {return true}
    }
    override func keyDown(with event: NSEvent) {
        print("keyDown in FlippedView")
    }
    

}
