import SwiftUI
import AVFoundation

struct BubbleAudioView: View {
    
    //  MARK: - Properties
    @State private var sliderValue = 0.0
    @State private var sliderRange: ClosedRange<Double> = 0...20
    @State private var playbackState: AudioMessagePlayer.PlaybackState = .stopped
    @State private var playbackTime = "00:00"
    @State private var isDraggingSlider = false
    @EnvironmentObject private var audioMessagePlayer: AudioMessagePlayer
    let message: Message
    
    var body: some View {
        VStack(alignment: message.horizontalAlignment, spacing: 4) {
            HStack {
                playButton()
                
                Slider(value: $sliderValue, in: sliderRange) { isEditingChange in
                    isDraggingSlider = isEditingChange
                    if !isEditingChange {
                        audioMessagePlayer.seek(to: sliderValue)
                    }
                }
                .tint(.gray)
                
                if playbackState == .stopped {
                    Text(message.audioDurationString)
                        .foregroundStyle(.gray)
                } else {
                    Text(playbackTime)
                        .foregroundStyle(.gray)
                }
            }
            .padding(10)
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(5)
            .background(message.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .applyTail(message.direction)
            
            timestampTextView()
        }
        .shadow(
            color: Color(.systemGray3).opacity(0.1),
            radius: 5,
            x: 0,
            y: 20
        )
        .frame(maxWidth: .infinity, alignment: message.alignment)
        .padding(.leading, message.direction == .received ? 5 : 100)
        .padding(.trailing, message.direction == .received ? 100 : 5)
        .onReceive(audioMessagePlayer.$playbackState) { playbackState in
            observePlaybackState(playbackState)
        }
        .onReceive(audioMessagePlayer.$currentTime) { currentTime in
            guard audioMessagePlayer.currentAudioURL?.absoluteString == message.audioURL else { return }
            observeCurrentPlayerTime(currentTime)
        }
        .onReceive(audioMessagePlayer.$playerItem) { playerItem in
            guard audioMessagePlayer.currentAudioURL?.absoluteString == message.audioURL else { return }
            guard let audioDuration = message.audioDuration else { return }
            sliderRange = 0...audioDuration
        }
    }
    
    //  MARK: - Private
    private func playButton() -> some View {
        Button {
            handlePlayAudio()
        } label: {
            Image(systemName: playbackState.icon)
                .padding(10)
                .background(message.direction == .received ? .green : .white)
                .clipShape(Circle())
                .foregroundStyle(message.direction == .received ? .white : .black)
        }
    }
    
    private func timestampTextView() -> some View {
        HStack {
            Text("05:06 PM")
                .font(.system(size: 13))
                .foregroundStyle(.gray)
            
            if message.direction == .outgoing {
                Image(.seen)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color(.systemBlue))
            }
        }
    }
}

//  MARK: - BubbleAudioView
extension BubbleAudioView {
    private func handlePlayAudio() {
        if playbackState == .stopped || playbackState == .paused {
            guard let audioURLString = message.audioURL,
                  let audioURL = URL(string: audioURLString) else { return }
            audioMessagePlayer.playAudio(from: audioURL)
        } else {
            audioMessagePlayer.pauseAudio()
        }
    }
    
    private func observePlaybackState(_ state: AudioMessagePlayer.PlaybackState) {
        if state == .stopped {
            playbackState = .stopped
            sliderValue = 0
        } else {
            guard audioMessagePlayer.currentAudioURL?.absoluteString == message.audioURL else { return }
            playbackState = state
        }
    }
    
    private func observeCurrentPlayerTime(_ currentTime: CMTime) {
        guard !isDraggingSlider else { return }
        playbackTime = currentTime.seconds.formatElapsedTime
        sliderValue = currentTime.seconds
    }
}

#Preview {
    ScrollView {
        BubbleAudioView(message: .sentPlaceholder)
        BubbleAudioView(message: .receivedPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
    .background(.gray.opacity(0.2))
    .onAppear {
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
}
