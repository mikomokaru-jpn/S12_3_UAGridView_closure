//---- AppDelegate.swift ----
import Cocoa
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var canvasView: FlipedView!  //一覧表の表示領域
    var dataList = [[String:Any]]()             //表示データ（JSONオブジェクト）
    let gridObject =  GridObject()              //Gridオブジェクトの作成
    var commonDef = [String : Any]()            //共通定義
    var colsDef = [[String : Any]]()            //列の定義
    //アプリケーション開始時
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.setProperty()            //Gridの定義の実行
        self.display()                //表示
    }
    //ウィンドウの再表示
    func applicationShouldHandleReopen(_ sender: NSApplication,
                                       hasVisibleWindows flag: Bool) -> Bool{
        if !flag{
            window.makeKeyAndOrderFront(self)
        }
        return true
    }
    //Gridの定義
    private func setProperty(){
        //<<< 共通定義 >>>
        gridObject.rowHeight = 28                   //行の高さ
        gridObject.borderLine = 1                   //枠線の太さ
        gridObject.borderColor = .gray              //枠線の色
        //<<< 見出し行の定義 >>>
        gridObject.headerBackColor = .lightGray     //背景色
        gridObject.headerHeight = 30                //行の高さ
        gridObject.headerFontSize = 14              //フォントサイズ
        //<<< 列の定義 >>>
        //日付
        var gridCol1 = GridCol(identifire: "date", width: 120.0)
        gridCol1.fontSize = 16
        gridCol1.align = .left
        gridCol1.title = "日付"
        gridCol1.sort = true
        gridCol1.initialSort = .ascending
        //最低血圧
        var gridCol2 = GridCol(identifire: "lower", width: 100.0)
        gridCol2.fontSize = 18
        gridCol2.align = .right
        gridCol2.title = "　最低血圧"
        gridCol2.headerAlign = .left
        gridCol2.sort = true
        //最高血圧
        var gridCol3 = GridCol(identifire: "upper", width: 100.0)
        gridCol3.fontSize = 18
        gridCol3.align = .right
        gridCol3.title = "　最高血圧"
        gridCol3.headerAlign = .left
        gridCol3.sort = true
        //脈圧
        var gridCol4 = GridCol(identifire: "pulse", width: 70.0)
        gridCol4.fontSize = 16
        gridCol4.align = .right
        gridCol4.title = "脈圧"
        //平均血圧
        var gridCol5 = GridCol(identifire: "average", width: 70.0)
        gridCol5.fontSize = 16
        gridCol5.align = .right
        gridCol5.title = "平均血圧"
        //日付・クロージャの実装
        gridCol1.formatText = { (val:Any) -> (String) in
            if let value = val as? Int{
                let year = value / 10000
                let month = (value % 10000) / 100
                let day = value % 100
                return "\(year) / \(month) / \(day)"
            }
            return "?"
        }
        //最低血圧・クロージャの実装
        gridCol2.dynamicForeColor2 = { (vals:[String:Any]) -> GridColor in
            var color: GridColor = .black
            if let lower = vals["lower"] as? Int {
                if let upper = vals["upper"] as? Int{
                    if lower >= 85 && upper >= 135{
                        color = .white    //文字色
                    }
                }
            }
            return color
        }
        gridCol2.dynamicBackColor2 = { (vals:[String:Any]) -> GridColor in
            var color: GridColor = .white
            if let lower = vals["lower"] as? Int {
                if let upper = vals["upper"] as? Int{
                    if lower >= 85 {
                        color = .yellow
                        if upper >= 135{
                            color = .red    //背景色
                        }
                    }
                }
            }
            return color
        }
        //最高血圧・クロージャの実装
        gridCol3.dynamicForeColor2 = { (vals:[String:Any]) -> GridColor in
            var color: GridColor = .black
            if let lower = vals["lower"] as? Int {
                if let upper = vals["upper"] as? Int{
                    if lower >= 85 && upper >= 135{
                        color = .white    //文字色
                    }
                }
            }
            return color
        }
        gridCol3.dynamicBackColor2 = { (vals:[String:Any]) -> GridColor in
            var color: GridColor = .white
            if let lower = vals["lower"] as? Int {
                if let upper = vals["upper"] as? Int{
                    if upper >= 135 {
                        color = .yellow
                        if lower >= 85{
                            color = .red    //背景色
                        }
                    }
                }
            }
            return color
        }
        //脈圧・クロージャの実装
        gridCol4.dynamicForeColor = { (val:Any) -> GridColor in
            if let intVlue = val as? Int{
                if intVlue >= 45{
                    return .red    //文字色
                }
            }
            return .black
        }
        //平均血圧・クロージャの実装
        gridCol5.dynamicForeColor = { (val:Any) -> GridColor in
            if let intVlue = val as? Int{
                if intVlue >= 95{
                    return .red    //文字色
                }
            }
            return .black
        }
        //登録
        gridObject.setCols([gridCol1, gridCol2, gridCol3, gridCol4, gridCol5])
    }
    //表示
    private func display(){
        //データの取得
        self.getData()
        //表示
        gridObject.display(dataList: dataList, view: canvasView)
    }
    //DBレコードの取得
    private func getData(){
        //let cmd = "http://192.168.11.3/doc_health_calendar/php/sql_r11.php"
        let cmd = "http://localhost/doc_health_calendar/php/sql_r11.php"
        let fromDate = "20180101"
        let toDate = "20201231"
        let param = "id=500&from_date=\(fromDate)&to_date=\(toDate)"
        let list = UAServerRequest.postSync(urlString:cmd, param:param)
        //受信データのキャスト  Any -> [[String:Any]]
        guard let unwrappedList  = list as? [[String:Any]] else{
            print("cast error")
            return
        }
        self.dataList = unwrappedList
    }
}

