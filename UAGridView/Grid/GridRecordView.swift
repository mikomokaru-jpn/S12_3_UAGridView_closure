//---- GridRecordView.swift ----
import Cocoa
//------------------------------------------------------------------------------
// １行のレコードビュー
//------------------------------------------------------------------------------
protocol GridRecordViewDelegate: class {
    func mouseOperation(_ :Int)
}
class GridRecordView: NSView {
    var index: Int = 0                                  //順序番号
    weak var delegate: GridRecordViewDelegate?  = nil   //デリゲートへの参照
    //背景色
    var backColor: CGColor = NSColor.black.cgColor{
        didSet{
            self.layer?.backgroundColor = self.backColor
        }
    }
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
    //マウスのクリックで現在行を変える
    override func mouseDown(with event: NSEvent) {
        self.delegate?.mouseOperation(self.index)
    }
    /*
    deinit {
        print("denit RecordView")
    }
    */
}
