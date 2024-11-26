//
//  UIDevice+Extension.swift
//
//
//  Created by 10-N3344 on 2023/06/14.
//

import Foundation
import AVFoundation
import UIKit

public extension UIDevice {

    static var deviceIdentifier: String? {
        return current.identifierForVendor?.uuidString
    }

    static func vibrate() {
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    // https://iphonedev.wiki/index.php/AudioServices
    static func alertSound(_ inSystemSoundID: SystemSoundID = 1031) {
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(inSystemSoundID)
        }
    }
}
