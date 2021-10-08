//---- GridDefinition.swift ----
import Foundation
//--------------------------------------------------------------------------
// 列定義
//--------------------------------------------------------------------------
struct GridCol{
    var identifire: String = ""                             //ID
    var width: CGFloat = 0                                  //列幅
    var fontSize: CGFloat = 0                               //フォントサイズ
    var foreColor: GridColor = .black                       //文字色
    var align: GridTextAlign = .left                        //水平方向の配置位置
    var verticalAlign: GridVerticalAlign = .middle          //垂直方向の配置位置
    var backColor: GridColor = .white                       //背景色
    var padding: CGFloat = 4                                //左右余白
    var title: String = ""                                  //列見出し
    var headerAlign: GridTextAlign = .center                //列見出しの水平方向の配置位置
    var sort: Bool = false                                  //ソート可否
    var initialSort: GridSort? = nil                        //最初のソート
    //クロージャ定義
    var formatText: ((Any) -> (String))? = nil                     //テキストの整形
    var dynamicForeColor: ((Any) -> GridColor)? = nil              //条件による文字色の変更
    var dynamicForeColor2: (([String:Any]) -> GridColor)? = nil    //条件による文字色の変更
    var dynamicBackColor: ((Any) -> GridColor)? = nil              //条件による背景色の変更
    var dynamicBackColor2: (([String:Any]) -> GridColor)? = nil    //条件による背景色の変更
    //イニシャライザ
    init(identifire: String, width: CGFloat) {
        self.identifire = identifire
        self.width = width
    }
    //イニシャライザ
    init(_ colsDef:[String : Any]) {
        //辞書データから列の定義を作成する
        if let identifire = colsDef["identifire"] as? String{
            self.identifire = identifire
        }
        if let value = colsDef["width"] as? Int{
            self.width = CGFloat(value)
        }
        if let value = colsDef["fontSize"] as? Int{
            self.fontSize = CGFloat(value)
        }
        if let value = colsDef["foreColor"] as? String{
            let color = GridDefinition.colorOfString(value)
            self.foreColor  = color
        }
        if let value = colsDef["align"] as? String{
            let align = GridDefinition.TextAlignOfString(value)
            self.align = align
        }
        if let value = colsDef["verticalAlign"] as? String{
            let verticalAlign = GridDefinition.VerticalAlignOfString(value)
            self.verticalAlign = verticalAlign
        }
        if let value = colsDef["backColor"] as? String{
            let color = GridDefinition.colorOfString(value)
            self.backColor  = color
        }
        if let value = colsDef["padding"] as? Int{
            self.padding = CGFloat(value)
        }
        if let value = colsDef["title"] as? String{
            self.title = value
        }
        if let value = colsDef["headerAlig"] as? String{
            let align = GridDefinition.TextAlignOfString(value)
            self.headerAlign = align
        }
        if let value = colsDef["sort"] as? Int{
            if value == 1{
                self.sort = true
            }
        }
        if let value = colsDef["initialSort"] as? String{
            if value == "ascending"{
                self.initialSort = .ascending
            }else if value == "descending"{
                self.initialSort = .descending
            }
        }
    }
}




