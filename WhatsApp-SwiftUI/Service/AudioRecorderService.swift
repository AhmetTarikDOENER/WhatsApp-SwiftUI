import Foundation
import AVFoundation

final class AudioRecorderService {
    
    private var audioRecorder: AVAudioRecorder?
    private var isRecording = false
    
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
        } catch {
            print("AudioRecorderService -> Failed to setup AVAudioSession")
        }
        
        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileName = Date().toString(format: "dd-MM-YY 'at' HH:mm:ss") + ".m4a"
        let audioFileURL = docPath.appendingPathComponent(audioFileName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFileMPEG4Type),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("AudioRecorderService -> Failed to setup AVAudioRecorder")
        }
    }
    
    func stopRecording() {
        
    }
}
