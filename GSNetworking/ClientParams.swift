//
//  ClientParams.swift
//  ModuleReview
//
//  Created by leslie lee on 2023/7/26.
//

import Foundation
class ClientParams {
   class func getParams()->String{
        let appVersion = (Bundle.main.infoDictionary!["CFBundleShortVersionString"]) as! String
        let systemVersion = UIDevice.current.systemVersion
        let appLang = Bundle.init().currentLanguage()
        let mobileType = UIDevice().devicesName// TODO: 获取正确的设备类型
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let resolution = String.init(format: "%.0f", screenWidth) + "*" + String.init(format: "%.0f", screenHeight)// 分辨率
        var gamepadName = ""
        let savedName = UserDefaults.standard.object(forKey: "GamepadNameKey")
        if savedName != nil {
            gamepadName = savedName as! String
        }
        let gamepadFirmwareVersion = "1.0"// TODO: 获取正确的手柄固件版本号
        let bundleId = Bundle.main.bundleIdentifier!
        let UDID = UIDevice().UDIDString
        // "1.0.0|16.5|zh|iPhone12,3|375*812|iOSUX|A128|apple|apple|020000000000|B97B2A65-C8E4-421C-AC94-3FEA0877A9EE||手柄名称|键盘名称|鼠标名称|固件版本|APP对应包名|Cpu|memory|GPU|"
        let param = appVersion + "|" + systemVersion + "|" + appLang + "|" + mobileType + "|" + resolution + "|" + "iOSUX" + "|" + "0" + "|" + "apple" + "|" + "apple" + "|" + "020000000000" + "|" + UDID + "|" + "0" + "|" + gamepadName + "|" + "0" + "|" + "0" + "|" + gamepadFirmwareVersion + "|" + bundleId + "|Cpu|memory|GPU"
        return param
    }
   
    
}
