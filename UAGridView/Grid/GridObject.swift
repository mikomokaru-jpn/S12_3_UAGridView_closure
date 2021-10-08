//---- UAGridObject.swift ----
import Cocoa
//行の選択列　構造体
struct RowSelector {
    var yPos: CGFloat = 0
    var view: NSView
    //イニシャライザ
    init(_ pos: CGFloat, _ vew: NSView) {
        self.yPos = pos
        self.view = vew
    }
}
//クラス定義
class GridObject: NSObject, GridRecordViewDelegate,
                            GridBaseViewDelegate,
                            GridHeaderItemViewDelegate{
    //<<< 共通定義 >>>
    var fontName: String = "HiraginoSans-W3"                //フォント名
    var fontSize: CGFloat = 0                               //フォントサイズ
    var rowHeight: CGFloat = 0                              //行の高さ
    var borderLine: CGFloat = 0                             //枠線の太さ
    var borderColor: GridColor = .black                     //枠線の色
    var headerFontSize: CGFloat = 0                         //ヘッダーのフォントサイズ
    var headerForeColor: GridColor = .black                 //ヘッダー文字色
    var headerBackColor: GridColor = .white                 //ヘッダー背景色
    var headerHeight: CGFloat = 0                           //列見出しの高さ
    var headerVerticalAlign: GridVerticalAlign = .middle    //列見出しの垂直方向の配置位置
    private var canvasView: NSView?                         //表示エリア（引数で受け取る）
    private let headerView = GridHeaderView.init(frame: NSZeroRect)     //ヘッダービューオブジェクト
    private let scrollView = NSScrollView.init(frame: NSZeroRect)       //スクロールビューオブジェクト
    private var selectedIndex: Int = 0                      //選択行
    private var rowList = [RowSelector]()                   //行の選択列のリスト
    private var baseWidth: CGFloat = 0                      //ベースビューの幅
    private var gridColList = [GridCol]()                   //列定義のリスト
    private var baseView = GridBaseView.init(frame: NSZeroRect)     //ベースビューオブジェクト
    private var dataList: Array<Dictionary<String,Any>> = [[:]]     //表示データのリスト
    private let selectorWidth:CGFloat = 20                  //先頭列の幅
    private var wIncrement: CGFloat = 0                     //罫線に見合う行の幅の増分
    private let nc = NotificationCenter.default             //通知センター
    private var currentYpos: CGFloat = 0                    //スクロールによる縦位置の保存
    //ソート関連
    private var sortPriorityList = [String]()               //ソートキーの優先順位
    private var headerList = [GridHeaderItemView]()         //ヘッダ列オブジェクトのリスト
    //イニシャライザ
    override init(){
        super.init()
        //ベースビューのセット
        scrollView.documentView = baseView
        //スクロールビューのスクロールを監視する
        nc.addObserver(self,
                       selector: #selector(self.getYpos(notification:)),
                       name: NSView.boundsDidChangeNotification,
                       object: nil)
    }
    //ベースビューの垂直方向の表示位置を保存する
    @objc func getYpos(notification: NSNotification){
        self.currentYpos =  self.baseView.bounds.origin.y
    }
    //列の定義を設定する（Appから呼ばれる）
    func setCols(_ gridColList: [GridCol]){
        //定義
        self.gridColList = gridColList
        //列の幅
        for gridCol in gridColList{
            self.baseWidth += gridCol.width
        }
        //ソート優先順位
        // 初期値は、１列目を最高の優先度とし右に向かって下げていく。
        for col in gridColList{
            if col.sort{
                sortPriorityList.append(col.identifire)
            }
        }
    }
    //表示処理（Appから呼ばれる）
    func display(dataList dataList_: Array<Dictionary<String,Any>>, view view_: NSView){
        self.dataList = dataList_
        self.canvasView = view_
        //ビューオブジェクトの削除
        self.removeObjects()
        self.rowList.removeAll()
        //ビューオブジェクトの追加
        canvasView!.addSubview(headerView)
        canvasView!.addSubview(scrollView)
        //スクロールビューの属性
        let scrollViewSize = NSMakeSize(canvasView!.frame.size.width,
                                        canvasView!.frame.size.height - self.headerHeight)
        scrollView.setFrameSize(scrollViewSize)
        scrollView.setFrameOrigin(NSMakePoint(0, self.headerHeight))
        scrollView.contentView.setBoundsOrigin(NSMakePoint(0, self.currentYpos))
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autoresizingMask = [.height, .width]
        //ベースビューの設定
        let fDataCount = CGFloat(dataList.count)                    //データ件数
        let fColCount = CGFloat(gridColList.count)                  //列定義の件数
        //罫線に見合う行の幅の増分
        wIncrement = selectorWidth + self.borderLine + self.borderLine * (fColCount + 1)
        //罫線に見合う列の高さの増分
        let hIncrement = self.borderLine * (fDataCount + 1)
        baseView.setFrameSize(NSMakeSize(self.baseWidth + wIncrement,
                                         self.rowHeight * fDataCount + hIncrement))
        baseView.backColor = self.setColor(self.borderColor).cgColor
        baseView.delegate = self
        //ヘッダビュー
        let size = NSMakeSize(canvasView!.frame.size.width, self.headerHeight)
        headerView.setFrameSize(size)
        headerView.autoresizingMask = [.width]
        headerView.backColor = self.setColor(self.headerBackColor).cgColor
        //列見出しの設定
        var wOffset: CGFloat = selectorWidth + self.borderLine
        var firstSort = (-1, GridSort.ascending) //初期表示時のソートキー(列インデックス, 昇降順)
        for i in 0 ..< gridColList.count{
            let itemRect = NSMakeRect(wOffset,
                                      0,
                                      gridColList[i].width,
                                      self.headerHeight)
            let hitemView = GridHeaderItemView.init(frame: itemRect)
            //識別子
            hitemView.gridIdentifire = gridColList[i].identifire
            //フォント名
            hitemView.fontName =  self.fontName
            //フォントサイズ
            hitemView.fontSize =  self.headerFontSize
            //文字色
            hitemView.foreColor = self.setColor(headerForeColor)
            //背景色
            hitemView.backColor = self.setColor(headerBackColor).cgColor
            //水平方向の配置位置
            hitemView.allign = gridColList[i].headerAlign
            //垂直方向の配置位置
            hitemView.verticalAllign = self.headerVerticalAlign
            //タイトル
            hitemView.text = gridColList[i].title
            //ソート対象列
            if gridColList[i].sort{
                hitemView.sort = true
                hitemView.delegate = self //ソート処理を受託する
                if gridColList[i].initialSort != nil{
                    //初期表示時ソート対象列のときの設定
                    firstSort = (i, gridColList[i].initialSort!)
                }
            }
            //オブジェクトリストに保存
            self.headerList.append(hitemView)
            //ビューに追加
            headerView.addSubview(hitemView)
            //横移動
            wOffset += gridColList[i].width
        }
        //初期表示時にソートを行うか否か
        if firstSort.0 >= 0{
            //指定された列をキーにソートする
            self.headerList[firstSort.0].sortKey = firstSort.1
            self.headerList[firstSort.0].buttonClick(nil) // 内部でcreateRecords()を実行している
        }else{
            //ソートしない
            createRecords()
        }
        canvasView!.window?.makeFirstResponder(baseView)
    }
    //レコード行の作成
    private func createRecords(){
        //レコードビューオブジェクトの解放
        self.removeRecords()
        //データの読み込み
        for i in 0 ..< dataList.count{
            //レコードビューの作成
            //枠線処理
            let height = self.rowHeight
            let hIncrement = CGFloat(i+1) * self.borderLine
            let yPos = CGFloat(i) * self.rowHeight + hIncrement
            //レコードビューオブジェクトの作成
            let recordRect = NSMakeRect(self.borderLine,
                                        yPos,
                                        self.baseWidth + wIncrement,
                                        height)
            let recordView = GridRecordView.init(frame: recordRect)
            recordView.backColor = self.setColor(self.borderColor).cgColor
            recordView.index = i
            recordView.delegate = self
            //先頭列 SelectRow
            let rect = NSMakeRect(0, 0, selectorWidth, self.rowHeight)
            let selectRowView = GridItemView.init(frame: rect)
            selectRowView.wantsLayer = true
            if i == self.selectedIndex{
                selectRowView.layer?.backgroundColor = NSColor.blue.cgColor
            }else{
                selectRowView.layer?.backgroundColor = NSColor.lightGray.cgColor
            }
            self.rowList.append(RowSelector(recordView.frame.origin.y, selectRowView))
            recordView.addSubview(selectRowView)
            //アイテムビューの作成
            var wOffset: CGFloat = selectorWidth + self.borderLine
            for j in 0 ..< gridColList.count{
                let dataRecord = dataList[i]
                let itemRect = NSMakeRect(wOffset,
                                          0,
                                          gridColList[j].width,
                                          self.rowHeight)
                let itemView = GridItemView.init(frame: itemRect)
                //フォント名
                itemView.fontName = self.fontName
                //フォントサイズ
                if gridColList[j].fontSize == 0{
                    itemView.fontSize = self.fontSize
                }else{
                    itemView.fontSize = gridColList[j].fontSize
                }
                //文字色
                itemView.foreColor = self.setColor(gridColList[j].foreColor)
                //単項目の条件による文字色の変更：クロージャの実行
                if let closure = gridColList[j].dynamicForeColor{
                    let id = gridColList[j].identifire
                    if let value = dataRecord[id]{
                        let color = closure(value)
                        itemView.foreColor = self.setColor(color)
                    }
                }
                //全項目の条件による文字色の変更：クロージャの実行
                if let closure = gridColList[j].dynamicForeColor2{
                    let color = closure(dataRecord)
                    itemView.foreColor = self.setColor(color)
                }
                //水平方向の配置位置
                itemView.allign = gridColList[j].align
                //左右余白
                itemView.padding = gridColList[j].padding
                //垂直方向の配置位置
                itemView.verticalAllign = gridColList[j].verticalAlign
                //アイテムの背景色
                itemView.backColor = self.setColor(gridColList[j].backColor).cgColor
                //単項目の条件による背景色の変更：クロージャの実行
                if let closure = gridColList[j].dynamicBackColor{
                    let id = gridColList[j].identifire
                    if let value = dataRecord[id]{
                        let color = closure(value)
                        itemView.backColor = self.setColor(color).cgColor
                    }
                }
                //全項目の条件による背景色の変更：クロージャの実行
                if let closure = gridColList[j].dynamicBackColor2{
                    let color = closure(dataRecord)
                    itemView.backColor = self.setColor(color).cgColor
                }
                //表示テキスト
                let value = dataRecord[gridColList[j].identifire]
                
                //テキストの整形
                if let closure = gridColList[j].formatText{
                    itemView.text = closure(value as Any)
                }else{
                    //値の型を判定する方法
                    if value is Int{
                        itemView.text = String(value as! Int)
                    }else if value is String{
                        itemView.text = value as! String
                    }else if value is Float{
                        itemView.text = String(value as! Float)
                    }else{
                        itemView.text = "?"
                    }
                }
                
                recordView.addSubview(itemView)
                wOffset += (gridColList[j].width + self.borderLine)
            }
            baseView.addSubview(recordView)
        }
    }
    //全てのビューオブジェクトの解放
    private func removeObjects(){
        for itemView in headerView.subviews{
            itemView.removeFromSuperview()
        }
        headerView.removeFromSuperview()
        for recordView in baseView.subviews{
            for itemView in recordView.subviews{
                itemView.removeFromSuperview()
            }
            recordView.removeFromSuperview()
        }
        scrollView.removeFromSuperview()
        headerView.removeFromSuperview()
    }
    //レコードビューオブジェクトの解放
    private func removeRecords(){
        for recordView in baseView.subviews{
            for itemView in recordView.subviews{
                itemView.removeFromSuperview()
            }
            recordView.removeFromSuperview()
        }
    }
    //Delegate
    //マウスのクリックで現在行を変える
     func mouseOperation(_ index :Int){
        //同じ行のクリック
        if self.selectedIndex == index{
            return
        }
        //選択行の色の変更
        self.rowList[selectedIndex].view.layer?.backgroundColor = NSColor.lightGray.cgColor
        self.selectedIndex = index
        self.rowList[selectedIndex].view.layer?.backgroundColor = NSColor.blue.cgColor
        //スクロールビューの表示範囲
        let span = self.rowHeight + self.borderLine
        let upper = self.scrollView.contentView.bounds.origin.y + self.borderLine
        let lower = upper + self.scrollView.contentView.bounds.size.height
        //表示中の行の取得
        var visibleRows = [Int]()
        for i in 0 ..< self.rowList.count{
            if self.rowList[i].yPos > upper &&
                self.rowList[i].yPos + span  < lower {
                visibleRows.append(i)
            }
        }
        if  index > visibleRows.last!{
            //スクロールビュー最下段の行の位置調整
            let diff = (rowList[selectedIndex].yPos + span) - lower
            self.baseView.scroll(NSMakePoint(0, self.scrollView.contentView.bounds.origin.y
                                                + self.borderLine
                                                + diff))
        }else if index < visibleRows.first!{
            //スクロールビュー最上段の行の位置調整
            let diff = (rowList[selectedIndex].yPos) - upper
            self.baseView.scroll(NSMakePoint(0, self.scrollView.contentView.bounds.origin.y
                                                + diff))
        }
    }
    //上下の矢印キーでスクロールする
    func keyOperation(_ keyCode: UInt16){
        //スクロールビューの表示範囲
        let span = self.rowHeight + self.borderLine
        let upper = self.scrollView.contentView.bounds.origin.y + self.borderLine
        let lower = upper + self.scrollView.contentView.bounds.size.height
        //キーコード判定
        if keyCode == 125{
            //下に
            if self.selectedIndex >= self.rowList.count - 1{
                return //最後の行
            }
            //選択行の色の変更
            self.rowList[selectedIndex].view.layer?.backgroundColor
                = NSColor.lightGray.cgColor
            self.selectedIndex += 1
            self.rowList[selectedIndex].view.layer?.backgroundColor =
                NSColor.blue.cgColor
            //スクロールビュー最下段の行の位置調整
            let diff = (rowList[selectedIndex].yPos + span) - lower
            if  diff > 0{
                self.baseView.scroll(NSMakePoint(0, self.scrollView.contentView.bounds.origin.y
                    + self.borderLine
                    + diff))
            }
        }else if keyCode == 126{
            //上に
            if self.selectedIndex <= 0{
                return //先頭行
            }
            //選択行の色の変更
            self.rowList[selectedIndex].view.layer?.backgroundColor = NSColor.lightGray.cgColor
            self.selectedIndex -= 1
            self.rowList[selectedIndex].view.layer?.backgroundColor = NSColor.blue.cgColor
            //スクロールビュー最上段の行の位置調整
            let diff = (rowList[selectedIndex].yPos) - upper
            if  diff < 0{
                self.baseView.scroll(NSMakePoint(0, self.scrollView.contentView.bounds.origin.y
                                                    + diff))
            }
        }
    }
    //色の変換
    private func setColor(_ color: GridColor) -> NSColor{
        switch color {
        case GridColor.black:
            return NSColor.black
        case GridColor.red:
            return NSColor.red
        case GridColor.blue:
            return NSColor.blue
        case GridColor.green:
            return NSColor.green
        case GridColor.yellow:
            return NSColor.yellow
        case GridColor.gray:
            return NSColor.gray
        case GridColor.lightGray:
            return NSColor.lightGray
        case GridColor.pink:
            return NSColor.systemPink
        case GridColor.white:
            return NSColor.white
        case GridColor.clear:
            return NSColor.clear
        }
    }
    //--------------------------------------------------------------------------
    // ソート（オプション機能）
    //--------------------------------------------------------------------------
    //ソートの実行
    func doSort(_ idetifires:String, _ flg: GridSort) {
        //ソート順位の決定：指定された列が最優先、それ以外は列の左端から優先
        var ids = [String]()
        ids.append(idetifires)
        for id in sortPriorityList{
            if id != idetifires{
                ids.append(id)
            }
        }
        //データリストのソート
        dataList.sort(by:{ lRecord, rRecord -> Bool in
            //大小が確定するまで全てのソートキーを試す
            for id in ids{
                var ret = 0
                //ソート対象要素の型の判定し、比較関数を呼ぶ
                if lRecord[id] is Int{
                    ret = hantei(lRecord[id] as! Int, rRecord[id] as! Int)
                }else if lRecord[id]  is String{
                    ret = hantei(lRecord[id] as! String, rRecord[id] as! String)
                }else if lRecord[id] is Float{
                    ret = hantei(lRecord[id] as! Float, rRecord[id] as! Float)
                }
                //昇降順フラグによる戻り値の変換
                if ret == 1{
                    if flg == .ascending{
                        return true
                    }else{
                        return false
                    }
                }else if ret == -1{
                    if flg == .ascending{
                        return false
                    }else{
                        return true
                    }
                }
            }
            return false
        })
        //見出しのソートボタンの上下矢印を表示する
        for header in self.headerList{
            if header.gridIdentifire == idetifires{
                if flg == .ascending{
                    header.button.title = "↑"
                }else{
                    header.button.title = "↓"
                }
            }else{
                header.button.title = ""
            }
        }
        //レコードの再作成と再表示
        self.createRecords()
    }
    //大小の判定関数（引数の型はジェネリック型）
    private func hantei<T :Comparable>(_ lValue: T, _ rValue: T) -> Int{
        if lValue < rValue{
            return 1
        }else if lValue > rValue{
            return -1
        }else{
            return 0
        }
    }
    //--------------------------------------------------------------------------
    //属性を外部ファイルから読み込む（オプション機能）
    //--------------------------------------------------------------------------
    func setPropaties(_ commonDef:[String : Any]){
        //<<< 共通定義 >>>
        //フォント名
        if let value = (commonDef["fontName"] as? String){
            self.fontName = value
        }
        //フォントサイズ
        if let value = commonDef["fontSize"] as? Int{
            self.fontSize = CGFloat(value)
        }
        //行の高さ
        if let value = commonDef["rowHeight"] as? Int{
            self.rowHeight = CGFloat(value)
        }
        //枠線の太さ
        if let value = commonDef["borderLine"] as? Int{
            self.borderLine = CGFloat(value)
        }
        //枠線の色
        if let value = (commonDef["borderColor"] as? String){
            let color =  GridDefinition.colorOfString(value)
            self.borderColor  = color
        }
        //<<< 見出し行の定義 >>>
        //ヘッダーの文字色
        if let value = (commonDef["headerForeColor"] as? String){
            let color = GridDefinition.colorOfString(value)
            self.headerForeColor = color
        }
        //ヘッダーの背景色
        if let value = (commonDef["headerBackColor"] as? String){
            let color = GridDefinition.colorOfString(value)
            self.headerBackColor = color
        }
        //ヘッダーのフォントサイズ
        if let value = commonDef["headerFontSize"] as? Int{
            self.headerFontSize = CGFloat(value)
        }
        //列見出しの高さ
        if let value = commonDef["headerHeight"] as? Int{
            self.headerHeight = CGFloat(value)
        }
        //列見出しの垂直方向の配置位置
        if let value = (commonDef["headerVerticalAlign"] as? String){
            let verticalAlign = GridDefinition.VerticalAlignOfString(value)
            self.headerVerticalAlign = verticalAlign
        }
    }
}
