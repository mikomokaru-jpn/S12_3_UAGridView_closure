//---- GridHeaderView.swift ----
import Cocoa
//------------------------------------------------------------------------------
// 列見出しビュー
//------------------------------------------------------------------------------
class GridHeaderView: NSView {
    var backColor: CGColor = NSColor.clear.cgColor{              //背景色
        didSet{
            self.layer?.backgroundColor = backColor
        }
    }
    //イニシャライザ
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = backColor
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    override var isFlipped:Bool {
        get {return true}
    }
}
