import SwiftUI
import AVFoundation

struct BubbleAudioView: View {
    
    //  MARK: - Properties
    @State private var sliderValue = 0.0
    @State private var sliderRange: ClosedRange<Double> = 0...20
    @State private var playbackState: AudioMessagePlayer.PlaybackState = .stopped
    @State private var playbackTime = "00:00"
    @EnvironmentObject private var audioMessagePlayer: AudioMessagePlayer
    let message: Message
    
    var body: some View {
        VStack(alignment: message.horizontalAlignment, spacing: 4) {
            HStack {
                playButton()
                
                Slider(value: $sliderValue, in: sliderRange)
                    .tint(.gray)
                
                Text("02:23")
                    .foregroundStyle(.gray)
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
            observeCurrentPlayerTime(currentTime)
        }
        .onReceive(audioMessagePlayer.$playerItem) { playerItem in
            guard let audioDuration = message.audioDuration else { return }
            sliderRange = 0...audioDuration
        }
    }
    
    //  MARK: - Private
    private func playButton() -> some View {
        Button {
            handlePlayAudio()
        } label: {
            Image(systemName: "play.fill")
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
            playbackState = state
        }
    }
    
    private func observeCurrentPlayerTime(_ currentTime: CMTime) {
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
