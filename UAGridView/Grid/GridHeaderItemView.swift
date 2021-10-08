//---- GridHeaderItemView.swift ----
import Cocoa
//------------------------------------------------------------------------------
// 列見出しの要素ビュー
//------------------------------------------------------------------------------
protocol GridHeaderItemViewDelegate: class {
    //この列をキーとしてソートする
    func doSort(_ idetifire: String, _ flg :GridSort)
}
class GridHeaderItemView: GridItemView {
    //ソートフラグ
    var sort = false {
        didSet{
            if self.sort{
                //列見出しにソートボタンを表示する
                let rect = NSMakeRect(self.frame.size.width - 22,
                                      self.frame.size.height / 2 - 10,
                                      20, 20)
                button.frame = rect
                button.title = ""
                button.bezelStyle = .texturedSquare
                button.wantsLayer = true
                button.target = self
                button.action = #selector(self.buttonClick)
                self.addSubview(button)
            }
        }
    }
    var sortKey = GridSort.ascending                            //ソートキー
    let button = NSButton.init(frame: NSMakeRect(0, 0, 0, 0))   //ボタンオブジェクト
    weak var delegate: GridHeaderItemViewDelegate?  = nil       //デリゲートへの参照
    //ボタンアクション
    @objc func buttonClick(_ sender: Any?){
        //ソート処理の依頼
        self.delegate?.doSort(self.gridIdentifire, self.sortKey)
        //昇降順を反転する
        if self.sortKey == .ascending{
            self.sortKey = .descending
        }else{
            self.sortKey = .ascending
        }
    }
    deinit {
        //print("denit HeaderItemView")
    }
}
