import Foundation
import AVFoundation

final class AudioMessagePlayer: ObservableObject {
    
    //  MARK: - Properties
    private var player: AVPlayer?
    private(set) var currentAudioURL: URL?
    @Published private(set) var playerItem: AVPlayerItem?
    @Published private(set) var playbackState = PlaybackState.stopped
    @Published private(set) var currentTime = CMTime.zero
    private var currentTimeObserver: Any?
    
    //  MARK: - Deinit
    deinit { removeObservers() }
    
    func playAudio(from url: URL) {
        if let currentAudioURL, currentAudioURL == url {
            /// Resumes to playing that already playing
            resumePlaying()
        } else {
            /// Plays an audio message
            currentAudioURL = url
            let playerItem = AVPlayerItem(url: url)
            self.playerItem = playerItem
            player = AVPlayer(playerItem: playerItem)
            player?.play()
            playbackState = .playing
            observeCurrentPlayerTime()
            observeEndOfPlayback()
        }
    }
    
    func pauseAudio() {
        player?.pause()
        playbackState = .paused
    }
    
    func seek(to timeInterval: TimeInterval) {
        guard let player else { return }
        let targetTime = CMTime(seconds: timeInterval, preferredTimescale: 1)
        player.seek(to: targetTime)
    }
    
    //  MARK: - Private
    private func observeCurrentPlayerTime() {
        currentTimeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            self?.currentTime = time
        }
    }
    
    private func observeEndOfPlayback() {
        NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: player?.currentItem,
            queue: .main) { [weak self] _ in
                self?.stopAudioPlayer()
            }
    }
    
    private func stopAudioPlayer() {
        player?.pause()
        player?.seek(to: .zero)
        playbackState = .stopped
        currentTime = .zero
    }
    
    private func resumePlaying() {
        if playbackState == .paused || playbackState == .stopped {
            player?.play()
            playbackState = .playing
        }
    }
    
    private func removeObservers() {
        guard let currentTimeObserver else { return }
        player?.removeTimeObserver(currentTimeObserver)
        self.currentTimeObserver = nil
    }
    
    private func tearDown() {
        removeObservers()
        player = nil
        playerItem = nil
        currentAudioURL = nil
    }
}

extension AudioMessagePlayer {
    enum PlaybackState {
        case stopped, playing, paused
        
        var icon: String {
            return self == .playing ? "pause.fill" : "play.fill"
        }
    }
}
