//
//  AVAudioPlayer+Extension.swift
//  CommonUtils
//
// Created by Dongju Lim on 3/18/25.
//

import UIKit
import AVFoundation

public extension AVAudioPlayer {

    var minuteCurrentDurationString: String {
        let roundVal = Int(round(currentTime))

        let s: Int = roundVal % 60
        let m: Int = roundVal / 60

        return String(format: "%d:%02d", m, s)
    }

    var minuteTotDurationString: String {
        let roundVal = Int(round(duration))
        let s: Int = roundVal % 60
        let m: Int = roundVal / 60

        return String(format: "%d:%02d", m, s)
    }

    var timeCurrentDurationString: String {
        let roundVal = Int(round(currentTime))

        let s: Int = roundVal % 60
        let m: Int = (roundVal / 60) % 60
        let h: Int = roundVal / 3600

        return String(format: "%d:%02d:%02d", h, m, s)
    }

    var timeTotDurationString: String {
        let roundVal = Int(round(duration))
        let s: Int = roundVal % 60
        let m: Int = (roundVal / 60) % 60
        let h: Int = roundVal / 3600

        return String(format: "%d:%02d:%02d", h, m, s)
    }
}

public extension AVPlayer {

    var timeTotDurationString: String {
        guard let time = self.currentItem?.asset.duration else { return "" }

        let seconds: Float = Float(CMTimeGetSeconds(time));
        let roundVal = Int(round(seconds))
        let s: Int = roundVal % 60
        let m: Int = (roundVal / 60) % 60
        let h: Int = roundVal / 3600

        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%d:%02d", m, s)
        }
    }
}
