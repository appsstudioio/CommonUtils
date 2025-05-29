//
//  Bundle+Extension.swift
//
//
// Created by Dongju Lim on 2023/06/14.
//

import Foundation

public extension Bundle {

    enum InfoPlistKey: String {
        case baseURL = "BaseURL"
        case baseSocketURL = "BaseSocketUrl"
        case firebaseServiceFile = "FirebaseServiceFile"
        case appName = "CFBundleDisplayName"
        case appStoreID = "AppStoreID"
        case appGroupID = "BaseAppGroupIdentifier"
    }
    
    static func getInfoPlistValue(forKey key: InfoPlistKey) -> String {
        return self.getInfoPlistValue(forKeyString: key.rawValue)
    }
    
    static func getInfoPlistValue(forKeyString key: String) -> String {
        return (self.main.infoDictionary?[key] as? String)?.replacingOccurrences(of: "\\", with: "") ?? ""
    }

    static func getPlistFile(fileName: String, ofType: String = "plist") -> String? {
        return self.main.path(forResource: fileName, ofType: ofType)
    }
    
    static func plistToDictionary(_ filePath: String) -> NSMutableDictionary {
        return NSMutableDictionary(contentsOfFile: filePath) ?? [:]
    }
}
