import Foundation
import AVFoundation
import Combine

final class AudioRecorderService {
    
    private var audioRecorder: AVAudioRecorder?
    private(set) var isRecording = false
    private var startingTime: Date?
    private var timer: AnyCancellable?
    private var elapsedTime: TimeInterval = 0
    
    deinit { tearDown() }
    
    /// Setup audio session + define where to store + settings + start recording
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
        } catch {
            print("❌ AudioRecorderService -> Failed to setup AVAudioSession")
        }
        
        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileName = Date().toString(format: "dd-MM-YY 'at' HH:mm:ss") + ".m4a"
        let audioFileURL = docPath.appendingPathComponent(audioFileName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.record()
            isRecording = true
            startingTime = Date()
            startTimer()
        } catch {
            print("❌ AudioRecorderService -> Failed to setup AVAudioRecorder")
        }
    }
    
    func stopRecording(completion: ((_ audioURL: URL?, _ audioDuration: TimeInterval) -> Void)? = nil) {
        guard isRecording else { return }
        let audioDuration = elapsedTime

        audioRecorder?.stop()
        isRecording = false
        timer?.cancel()
        elapsedTime = 0
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
            guard let audioURL = audioRecorder?.url else { return }
            completion?(audioURL, audioDuration)
        } catch {
            print("❌ AudioRecorderService -> Failed to teardown AVAudioSession")
        }
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let startingTime = self?.startingTime else { return }
                self?.elapsedTime = Date().timeIntervalSince(startingTime)
            }
    }
    
    func tearDown() {
        let fileManager = FileManager.default
        let folder = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderContens = try! fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
        deleteRecordings(folderContens)
        print("✅ AudioRecorderService -> AudioRecorderService was successfully teared down")
    }
    
    private func deleteRecordings(_ urls: [URL]) {
        for url in urls {
            deleteRecording(at: url)
        }
    }
    
    func deleteRecording(at fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("✅ AudioRecorderService -> Audio file was successfully deleted")
        } catch {
            print("❌ AudioRecorderService -> Failed to delete file")
        }
    }
}
