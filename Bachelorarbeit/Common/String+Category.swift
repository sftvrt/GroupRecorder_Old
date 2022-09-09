//
//  String+Category.swift
//  Bachelorarbeit
//
//

import Foundation
import UIKit

extension Encodable {
    func toJSONString() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else{ return "" }
        guard let jsonStr = String(data: data, encoding: .utf8) else{ return "" }
        return jsonStr
    }
}

extension String {
     func jSONStringToData() -> Data? {
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        return data
    }
}

extension Date {
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }

    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
}


extension Notification.Name {
    static let refreshNavigationBar = Notification.Name("refreshNavigationBar")


}
