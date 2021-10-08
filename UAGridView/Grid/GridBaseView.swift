//---- GridBaseView.swift ----
import Cocoa
//------------------------------------------------------------------------------
// スクロールビューに含まれるコンテントビュー
//------------------------------------------------------------------------------
protocol GridBaseViewDelegate: class {
    func keyOperation(_ :UInt16)
}
class GridBaseView: NSView {
    var backColor: CGColor = NSColor.black.cgColor{ //背景色
        didSet{
            self.wantsLayer = true
            self.layer?.backgroundColor = self.backColor
        }
    }
    weak var delegate: GridBaseViewDelegate?  = nil  //デリゲートへの参照
    //イニシャライザ
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = self.backColor
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    override var isFlipped:Bool {
        get {return true}
    }
    //キー押下：上下の矢印キーでビューをスクロールする
    override func keyDown(with event: NSEvent) {
        delegate?.keyOperation(event.keyCode)
    }
}
