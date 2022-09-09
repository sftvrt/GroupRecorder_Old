//
//  AudioRecorder2.swift
//  Bachelorarbeit
//
//  Created by JT X on 10.12.20.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI

/// 音频合成类型
enum AudioSyntheticType {
    // 默认包含静音、格式转换
    case normal
    // 无静音
    case noMute
    // 无转码
    case noConvert
    // 无静音转码
    case noMuteConvert
}


class AudioRecorder:  NSObject, ObservableObject {
    
    var nearbyService: NearbyService
    
    let objectWillChange = PassthroughSubject<AudioRecorder , Never>()
    
    var audioRecorder: AVAudioRecorder!
    
    var current: Recording?
    var recordings = [Recording]()
    var Condition = ""
    let player = AVPlayer()
    var item: AVPlayerItem?
    var observation: NSKeyValueObservation?
    
    var currentMuteTime: TimeInterval = 0.0
    var currentRecordingTime: TimeInterval = 0.0
    
    var muteTimeInfoList:[[String:Any]] = [[String:Any]]()
    var atTime:TimeInterval = 0.0
    var timer:Timer!
    var playEndBlock: (()->())?
    var exportCompletedBlock: (()->())?
    
    @Published var asset: AVURLAsset?
    var isPlay: Bool {
        player.rate == 1
    }
    
    
    lazy var dateFormatter: DateFormatter = {
        let formatter =  DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        return formatter
    }()
    
    
    var isMeetingPreparation = false {
        didSet{
            objectWillChange.send(self)
        }
    }
    
    var recording = false {
        didSet{
            objectWillChange.send(self)
        }
    }
    
    var isPause = false {
        didSet{
            objectWillChange.send(self)
        }
    }
    
    var pauseIndex = 0 {
        didSet{
            objectWillChange.send(self)
        }
    }
    
    var opsTimeIndex = 0 {
        didSet{
            objectWillChange.send(self)
        }
    }
    
    var importentTimeIndex = 0 {
        didSet{
            objectWillChange.send(self)
        }
    }
    
    var isMute = false {
        didSet{
            objectWillChange.send(self)
        }
    }
    
    init(_ nearbyService: NearbyService) {
        self.nearbyService = nearbyService
        super.init()
        fetchRecordings()
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.new], context: nil)
    }
    
    deinit {
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.player.rate == 0 {
            pasue()
            self.playEndBlock?()
        }
        
    }
    
    func updateOnlineState() {
        objectWillChange.send(self)
    }
    
    func play(_ url: URL) {
        asset = AVURLAsset(url: url)
        item = AVPlayerItem(asset: asset!)
        player.replaceCurrentItem(with: item!)
        player.play()
        objectWillChange.send(self)
    }
    func pasue() {
        if player.rate != 0 {
            player.pause()
        }
        player.replaceCurrentItem(with: nil)
        item = nil
        asset = nil
        objectWillChange.send(self)
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func startRecording(){
        startRecord()
    }
    
    func startRecord(){
        pauseIndex = 0
        opsTimeIndex = 0
        importentTimeIndex = 0
        let recordingSession = AVAudioSession.sharedInstance()
        let date = Date()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        }catch{
            debugPrint(error)
        }
        
        var audioFileName: URL!
        let dateString = self.dateFormatter.string(from: date)
        
        if nearbyService.isBrowser {
            audioFileName =  getDocumentsDirectory().appendingPathComponent("\(nearbyService.sitzung.title) \(dateString).wav")
            
        } else {
            audioFileName = getDocumentsDirectory().appendingPathComponent("\(nearbyService.peerID.displayName) \(dateString).wav")
        }
        
        //https://stackoverflow.com/questions/38969331/cant-record-on-ipad-error-domain-nsosstatuserrordomain-code-1718449215-null
        let settings:[String:Any] = [AVFormatIDKey:kAudioFormatLinearPCM,
                          AVEncoderAudioQualityKey:AVAudioQuality.max.rawValue,
                               AVEncoderBitRateKey:320000,
                             AVNumberOfChannelsKey:1,
                                     // Channel: 1
                                   AVSampleRateKey:44100.0 ] as [String : Any]
        
        
        do {
            self.currentRecordingTime = 0.0
            self.muteTimeInfoList.removeAll()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(recordingTime), userInfo: nil, repeats: true)
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.record()
            recording = true
            if nearbyService.isBrowser {
                nearbyService.send(msg: "start")
            }
            current = Recording.init(fileURL: audioFileName, createdAt: getCreationDate(for: audioFileName))
        }catch{
            debugPrint(error)
        }
    }
    
    @objc func recordingTime() {
        self.currentRecordingTime += 1.0
    }
    
    func getSlienceUrl()-> URL {
        guard let filePathFive = Bundle.main .path(forResource: "silence1s", ofType: "wav") else { return URL.init(fileURLWithPath: "") }
        return URL.init(fileURLWithPath: filePathFive)
    }
    
    @objc func update() {
        if !isMute {
            CFRunLoopStop(CFRunLoopGetCurrent())
        }
        
        currentMuteTime += 1.0
        print("update \(currentMuteTime)")
        
    }
    
    func pauseRecording(){
        if(audioRecorder.isRecording) {
            audioRecorder.pause()
            pauseIndex += 1
            isPause = true
            if nearbyService.isBrowser {
                nearbyService.send(msg: "pause")
            }
        }else {
            isPause = false
            audioRecorder.record()
            if nearbyService.isBrowser {
                nearbyService.send(msg: "record")
            }
        }
    }
    
    func muteRecording(){
        if(audioRecorder.isRecording) {
            audioRecorder.pause()
            isMute = true
            currentMuteTime = 0.0
            atTime = self.currentRecordingTime
            DispatchQueue.global().async {
                let timer = Timer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                RunLoop.current.add(timer, forMode: .common)
                CFRunLoopRun()
            }
        }else {
            isMute = false
            print("record \(currentMuteTime)")
            let muteInfo = [
                "muteAtTime":atTime,
                "muteTime":currentMuteTime,
            ] as [String : Any]
            
            muteTimeInfoList.append(muteInfo)
            
            audioRecorder.record()
        }
        
    }
    
    func stopRecording(){
        pauseIndex = 0
        opsTimeIndex = 0
        importentTimeIndex = 0
        if timer != nil {
            timer.invalidate()
        }
        audioRecorder.stop()
        recording = false
        if nearbyService.isBrowser {
            nearbyService.send(msg: "stop")
        }
        /// 合成音频，可以根据不同的类型传参，处理不同的业务逻辑
        syntheticAudio()
        
        self.current = nil
        fetchRecordings()
    }
    
    func fetchRecordings(){
        DispatchQueue.main.async {
            self.recordings.removeAll()
            let fileManager = FileManager.default
            // fetch all data from document directory
            
            let directoryContent = try! fileManager.contentsOfDirectory(at: DataStorageManager().recordingStorageURL, includingPropertiesForKeys: nil)
            
            for audio in directoryContent{
                let recording = Recording(fileURL: audio, createdAt: getCreationDate(for: audio))
                self.recordings.append(recording)
                //url + data
            }
                        
            self.objectWillChange.send(self)
        }
    }
    
    func deleteRecording(urlsToDelete: [URL]) {
        
        for url in urlsToDelete {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("File could not be deleted!")
            }
        }
        
        fetchRecordings()
    }
}

/// 音频合成
extension AudioRecorder {
    /// Synthetic audio -  合成音频，可以根据不同的类型传参，处理不同的业务逻辑
    func syntheticAudio(_ audioSyntheticType:AudioSyntheticType = AudioSyntheticType.normal) {
        
        let composition:AVMutableComposition = AVMutableComposition()
        
        let slienceUrl = getSlienceUrl()
        if (audioSyntheticType != AudioSyntheticType.noMute && audioSyntheticType != AudioSyntheticType.noMuteConvert) && (self.muteTimeInfoList.count > 0) {
            let audioAsset:AVURLAsset = AVURLAsset(url: current!.fileURL, options:nil)
            
            var lastMuteAtTime: Double = 0.0
            var lastMuteTime: Double = 0.0
            
            var audioAtTime: Double = 0.0
            
            var hadAudioDurationTime: Double = 0.0
            
            for metuInfo in self.muteTimeInfoList {
                let muteAtTime = metuInfo["muteAtTime"] as! Double
                let muteTime = metuInfo["muteTime"] as! Double
                
                let muteDuration = CMTime.init(seconds: muteTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                
                // Duration of audio clip
                let audioDurationTime = (muteAtTime - lastMuteAtTime - lastMuteTime)
                
                // Length of clipped audio - the starting point for clipping the next audio
                hadAudioDurationTime += audioDurationTime
                
                // Audio insertion point
                audioAtTime = (lastMuteAtTime + lastMuteTime)
                
                // mute
                let silenceOriginalAsset1:AVURLAsset = AVURLAsset(url: slienceUrl, options:nil)
                
                let p_appendedAudioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
                let p_assetTrack1 =  silenceOriginalAsset1.tracks(withMediaType: (AVMediaType.audio))[0]
                let p_timeRange1 = CMTimeRangeMake(start:CMTime.zero, duration: muteDuration)
                
                try? p_appendedAudioTrack.insertTimeRange(p_timeRange1, of: p_assetTrack1, at:silenceOriginalAsset1.duration + CMTime.init(seconds: muteAtTime/1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
                
                
                lastMuteAtTime = muteAtTime
                lastMuteTime = muteTime
            }
            
            audioAtTime = (lastMuteAtTime + lastMuteTime)
            
            let audioStart = CMTime.init(seconds: hadAudioDurationTime/1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            let audioDuration = (audioAsset.duration - audioStart)
            
            let a_audioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
            let a_assetTrack =  audioAsset.tracks(withMediaType: (AVMediaType.audio))[0]
            let a_timeRange = CMTimeRangeMake(start:audioStart, duration: audioDuration)
            try? a_audioTrack.insertTimeRange(a_timeRange, of: a_assetTrack, at:CMTime.init(seconds: audioAtTime/1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            
        }else {
            let anotherAudioTrack2:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
            let newAsset2:AVURLAsset = AVURLAsset(url: current!.fileURL, options:nil)
            let assetTrack2 =  newAsset2.tracks(withMediaType: (AVMediaType.audio))[0]
            let timeRange2 = CMTimeRangeMake(start: CMTime.zero, duration: newAsset2.duration)
            //            let beginTime2 = originalAsset1.duration
            try? anotherAudioTrack2.insertTimeRange(timeRange2, of: assetTrack2, at: CMTime.zero)
        }
        
        let dateString = self.dateFormatter.string(from: Date())
        let name = nearbyService.isBrowser ? nearbyService.sitzung.title : nearbyService.peerID.displayName
        
        let t_totleAudioFileName =  getDocumentsDirectory().appendingPathComponent("tempTotleAudioFile\(nearbyService.sitzung.title) \(dateString).m4a")
        
        var totleAudioFileName = DataStorageManager().getStorageRecordPathUrl(subPath: "\(name)\(dateString).m4a")
        
        
        print("export totleAudioFileName ...\(String(describing: t_totleAudioFileName))")
        let exportSession:AVAssetExportSession = AVAssetExportSession(asset: composition, presetName:AVAssetExportPresetAppleM4A)!
        // make sure to fill this value in
        exportSession.outputURL = ((audioSyntheticType == AudioSyntheticType.noConvert || audioSyntheticType == AudioSyntheticType.noMuteConvert)) ? totleAudioFileName : t_totleAudioFileName
        exportSession.outputFileType = AVFileType.m4a
        exportSession.exportAsynchronously(completionHandler: {() ->Void in
            // exported successfully?
            print("exportSession...",exportSession)
            switch exportSession.status {
            case .failed:
                print("export...failed \(String(describing: exportSession.error))")
                break
            case .completed:
                // you should now have the appended audio file
                if (audioSyntheticType != AudioSyntheticType.noConvert && audioSyntheticType != AudioSyntheticType.noMuteConvert) {
                    totleAudioFileName = DataStorageManager().getStorageRecordPathUrl(subPath: "\(name)\(dateString).wav")
                    
                    self.convertAudio(t_totleAudioFileName, outputURL: totleAudioFileName)
                }
                
                print("export...completed")
                
                if  !self.nearbyService.isBrowser {
                    self.nearbyService.sendFile(url: totleAudioFileName)
                }
                self.fetchRecordings()
                self.exportCompletedBlock?()
                break
            case .waiting:break
            default:break
            }
            //  var error: NSErrorPointer? = nil
        })
    }
}

/// 格式转换
extension AudioRecorder {
    func convertAudio(_ url: URL, outputURL: URL) {
        var error : OSStatus = noErr
        var destinationFile: ExtAudioFileRef? = nil
        var sourceFile : ExtAudioFileRef? = nil
        
        var srcFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()
        var dstFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()
        
        ExtAudioFileOpenURL(url as CFURL, &sourceFile)
        
        var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: srcFormat))
        
        ExtAudioFileGetProperty(sourceFile!,
                                kExtAudioFileProperty_FileDataFormat,
                                &thePropertySize, &srcFormat)
        
        dstFormat.mSampleRate = 44100  //Set sample rate
        dstFormat.mFormatID = kAudioFormatLinearPCM
        dstFormat.mChannelsPerFrame = 1
        dstFormat.mBitsPerChannel = 16
        dstFormat.mBytesPerPacket = 2 * dstFormat.mChannelsPerFrame
        dstFormat.mBytesPerFrame = 2 * dstFormat.mChannelsPerFrame
        dstFormat.mFramesPerPacket = 1
        dstFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked |
        kAudioFormatFlagIsSignedInteger
        
        // Create destination file
        error = ExtAudioFileCreateWithURL(
            outputURL as CFURL,
            kAudioFileWAVEType,
            &dstFormat,
            nil,
            AudioFileFlags.eraseFile.rawValue,
            &destinationFile)
        print("Error 1 in convertAudio: \(error.description)")
        
        error = ExtAudioFileSetProperty(sourceFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        print("Error 2 in convertAudio: \(error.description)")
        
        error = ExtAudioFileSetProperty(destinationFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        print("Error 3 in convertAudio: \(error.description)")
        
        let bufferByteSize : UInt32 = 32768
        var srcBuffer = [UInt8](repeating: 0, count: 32768)
        var sourceFrameOffset : ULONG = 0
        
        while(true){
            var fillBufList = AudioBufferList(
                mNumberBuffers: 1,
                mBuffers: AudioBuffer(
                    mNumberChannels: 2,
                    mDataByteSize: UInt32(srcBuffer.count),
                    mData: &srcBuffer
                )
            )
            var numFrames : UInt32 = 0
            
            if(dstFormat.mBytesPerFrame > 0){
                numFrames = bufferByteSize / dstFormat.mBytesPerFrame
            }
            
            error = ExtAudioFileRead(sourceFile!, &numFrames, &fillBufList)
            print("Error 4 in convertAudio: \(error.description)")
            
            if(numFrames == 0){
                error = noErr;
                break;
            }
            
            sourceFrameOffset += numFrames
            error = ExtAudioFileWrite(destinationFile!, numFrames, &fillBufList)
            print("Error 5 in convertAudio: \(error.description)")
        }
        
        error = ExtAudioFileDispose(destinationFile!)
        print("Error 6 in convertAudio: \(error.description)")
        error = ExtAudioFileDispose(sourceFile!)
        print("Error 7 in convertAudio: \(error.description)")
    }
    
}

