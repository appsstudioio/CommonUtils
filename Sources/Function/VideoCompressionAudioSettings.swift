import AVFoundation
import AudioToolbox

struct VideoCompressionAudioSettings {
    let outputSettings: [String: Any]
    let layoutSource: String
    let usesDefaultFormat: Bool

    /// 부족한 형식 정보는 기존 기본값으로 보완하고, 다채널에 필수인 레이아웃을 검증한다.
    static func prepare(formatDescription: CMAudioFormatDescription?) throws -> VideoCompressionAudioSettings {
        let description = formatDescription.flatMap {
            CMAudioFormatDescriptionGetStreamBasicDescription($0)?.pointee
        }
        var layoutSize = 0
        let sourceLayout = formatDescription.flatMap { format -> Data? in
            guard let layout = CMAudioFormatDescriptionGetChannelLayout(format, sizeOut: &layoutSize),
                  layoutSize > 0 else { return nil }
            return Data(bytes: layout, count: layoutSize)
        }
        return try prepare(channels: description?.mChannelsPerFrame ?? 0,
                           sampleRate: description?.mSampleRate ?? 0, channelLayout: sourceLayout)
    }

    static func prepare(channels sourceChannels: UInt32, sampleRate sourceSampleRate: Double,
                        channelLayout: Data? = nil) throws -> VideoCompressionAudioSettings {
        let channels = sourceChannels > 0 ? Int(sourceChannels) : 2
        let validSampleRate = sourceSampleRate.isFinite && sourceSampleRate > 0
        let usesDefaultFormat = sourceChannels == 0 || !validSampleRate
        var settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: channels,
            AVSampleRateKey: validSampleRate ? sourceSampleRate : 44100.0,
            AVEncoderBitRateKey: 128_000
        ]
        var hasInvalidLayout = false
        if let data = channelLayout {
            var layoutChannels: UInt32 = 0
            var channelsSize = UInt32(MemoryLayout<UInt32>.size)
            let status = data.withUnsafeBytes {
                AudioFormatGetProperty(kAudioFormatProperty_NumberOfChannelsForLayout,
                                       UInt32(data.count), $0.baseAddress, &channelsSize, &layoutChannels)
            }
            if status == noErr, layoutChannels == UInt32(channels) {
                settings[AVChannelLayoutKey] = data
                return VideoCompressionAudioSettings(outputSettings: settings, layoutSource: "source",
                                                     usesDefaultFormat: usesDefaultFormat)
            }
            // 모노·스테레오는 표준 구성을 사용하고, 실제 다채널 구성은 임의로 바꾸지 않는다.
            guard channels <= 2 else {
                throw CommonUtilCompressionError.unsupportedAudioFormat("오디오 채널 수와 레이아웃이 일치하지 않음")
            }
            hasInvalidLayout = true
        }

        if channels == 2 {
            var layout = AudioChannelLayout()
            layout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo
            settings[AVChannelLayoutKey] = Data(bytes: &layout, count: MemoryLayout<AudioChannelLayout>.size)
            return VideoCompressionAudioSettings(outputSettings: settings,
                                                 layoutSource: hasInvalidLayout ? "stereo_fallback" : "stereo",
                                                 usesDefaultFormat: usesDefaultFormat)
        }
        guard channels == 1 else {
            throw CommonUtilCompressionError.unsupportedAudioFormat("다채널 오디오의 채널 레이아웃을 찾을 수 없음")
        }
        return VideoCompressionAudioSettings(outputSettings: settings,
                                             layoutSource: hasInvalidLayout ? "mono_fallback" : "implicit_mono",
                                             usesDefaultFormat: usesDefaultFormat)
    }

    /// 전체 입력과 다채널·설정 거절을 구분하여 공통 외부 로그 핸들러에 전달한다.
    static func reportInput(_ details: [String: Any]) {
        DebugLog("동영상 압축 오디오 입력", param: details, isFileLog: false,
                 externalEventName: "video_compression_audio")
        if (details["input_channels"] as? Int ?? 0) > 2 {
            DebugLog("다채널 오디오 입력", level: .warning, param: details, isFileLog: false,
                     externalEventName: "video_compression_multichannel")
        }
        if details["status"] as? String == "invalid_audio_settings" {
            DebugLog("오디오 설정을 사용할 수 없음", level: .error, param: details, isFileLog: false,
                     externalEventName: "video_compression_audio_rejected")
        }
    }

    /// AAC 인코더가 지원하지 않는 채널 수를 입력 생성 전에 거절한다.
    static func supportsAACChannelCount(_ channels: Int) -> Bool {
        guard channels > 0, channels <= Int(UInt32.max) else { return false }
        var description = AudioStreamBasicDescription()
        description.mFormatID = kAudioFormatMPEG4AAC
        let descriptionSize = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        var size: UInt32 = 0
        guard AudioFormatGetPropertyInfo(kAudioFormatProperty_AvailableEncodeNumberChannels,
                                        descriptionSize, &description, &size) == noErr, size > 0 else { return false }
        var counts = [UInt32](repeating: 0, count: Int(size) / MemoryLayout<UInt32>.size)
        let status = counts.withUnsafeMutableBytes {
            AudioFormatGetProperty(kAudioFormatProperty_AvailableEncodeNumberChannels,
                                   descriptionSize, &description, &size, $0.baseAddress)
        }
        return status == noErr && (counts.contains(UInt32(channels)) || counts.contains(UInt32.max))
    }
}
