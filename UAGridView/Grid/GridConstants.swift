import Foundation
//<<< enum型定数 >>>
//データ型
enum GridType {
    case String
    case Int
    case Float
}
//色
enum GridColor {
    case black
    case red
    case blue
    case green
    case yellow
    case white
    case gray
    case lightGray
    case pink
    case clear
}
//水平方向の配置
enum GridTextAlign {
    case left
    case center
    case right
}
//垂直方向の配置
enum GridVerticalAlign {
    case top
    case middle
    case bottom
}
//垂直方向の配置
enum GridSort {
    case ascending
    case descending
}
//クラスメソッドの定義
class GridDefinition{
    //文字列 -> GridColor型
    static func colorOfString(_ str :String) -> GridColor{
        switch str {
        case "black":
            return .black
        case "red":
            return .red
        case "blue":
            return .blue
        case "green":
            return .green
        case "yellow":
            return .yellow
        case "white":
            return .white
        case "gray":
            return .gray
        case "lightGray":
            return .lightGray
        case "pink":
            return .pink
        default:
            return .clear
        }
    }
    //文字列 -> GridTextAlign型
    static func TextAlignOfString(_ str: String) -> GridTextAlign{
        switch str {
        case "left":
            return .left
        case "center":
            return .center
        case "right":
            return .right
        default:
            return .left
        }
    }
    //文字列 -> GridVerticalAlign型
    static func VerticalAlignOfString(_ str: String) -> GridVerticalAlign{
        switch str {
        case "top":
            return .top
        case "middle":
            return .middle
        case "bottom":
            return .bottom
        default:
            return .top
        }
    }
}
