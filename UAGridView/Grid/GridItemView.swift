//---- GridItemView.swift ----
import Cocoa
//------------------------------------------------------------------------------
// セル（行列の要素）ビュー
//------------------------------------------------------------------------------
class GridItemView: NSView {
    var gridIdentifire: String = ""                             //識別子
    var fontName: String = ""                                   //フォント名
    var fontSize: CGFloat = 0                                   //フォントサイズ
    var font: NSFont = NSFont.systemFont(ofSize: 0)             //フォントオブジェクト
    var foreColor: NSColor = NSColor.black                      //文字色
    var allign: GridTextAlign = .left                           //テキストの水平方向の配置
    var verticalAllign: GridVerticalAlign = .middle             //テキストの水平方向の配置
    var padding: CGFloat = 0                                    //左右余白
    var backColor: CGColor = NSColor.clear.cgColor              //背景色
    var attributes = [NSAttributedString.Key:Any]()              //文字列の属性
    var attrText = NSMutableAttributedString.init(string: "")   //属性付き文字列
    //表示テキスト
    var text: String = ""{
        didSet{
            if let font = NSFont.init(name: self.fontName, size: self.fontSize){
                self.font = font
            }else{
                self.font = NSFont.systemFont(ofSize: self.fontSize)
            }
            attributes.updateValue(self.font, forKey: .font)
            attributes.updateValue(self.foreColor, forKey: .foregroundColor)
            self.attrText = NSMutableAttributedString.init(string: self.text,
                                                           attributes: attributes)
            //背景色
            self.wantsLayer = true
            self.layer?.backgroundColor = self.backColor
        }
    }
    override var isFlipped:Bool {
        get {return true}
    }
    //イニシャライザ
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    //ビューの再表示
    override func draw(_ dirtyRect: NSRect) {
        //super.draw(dirtyRect)
        //文字列の表示位置
        var x :CGFloat = self.padding
        if self.allign == .center{
            x = dirtyRect.size.width / 2 - self.attrText.size().width / 2;
        }
        if self.allign == .right{
            x = dirtyRect.size.width - self.attrText.size().width - self.padding
        }
        var y :CGFloat = 0
        if self.verticalAllign == .middle{
            y = dirtyRect.size.height / 2 - self.attrText.size().height / 2
        }
        if self.verticalAllign == .bottom{
            y = dirtyRect.size.height - self.attrText.size().height
        }
        self.attrText.draw(at: NSMakePoint(x, y))
    }
    /*
    deinit {
        print("denit ItemView")
    }
    */
}
