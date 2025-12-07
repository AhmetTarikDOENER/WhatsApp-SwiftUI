import SwiftUI
import AVFoundation

struct BubbleAudioView: View {
    
    //  MARK: - Properties
    @State private var sliderValue = 0.0
    @State private var sliderRange: ClosedRange<Double>
    @State private var playbackState: AudioMessagePlayer.PlaybackState = .stopped
    @State private var playbackTime = "00:00"
    @State private var isDraggingSlider = false
    @EnvironmentObject private var audioMessagePlayer: AudioMessagePlayer
    private let message: Message
    
    private var isCurrentAudioMessage: Bool {
        audioMessagePlayer.currentAudioURL?.absoluteString == message.audioURL
    }
    
    //  MARK: - Init
    init(message: Message) {
        self.message = message
        let audioDuration = message.audioDuration ?? 0
        self._sliderRange = .init(wrappedValue: 0...audioDuration)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            if message.showGroupChatPartnerProfileImage {
                CircularProfileImageView(message.sender?.profileImageURL, size: .mini)
                    .offset(y: 3)
            }
            
            if message.direction == .outgoing {
                timestampTextView()
            }
            
            HStack {
                playButton()
                
                Slider(value: $sliderValue, in: sliderRange) { isEditingChange in
                    isDraggingSlider = isEditingChange
                    if !isEditingChange && isCurrentAudioMessage {
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
            
            if message.direction == .received {
                timestampTextView()
            }
        }
        .shadow(
            color: Color(.systemGray3).opacity(0.1),
            radius: 5,
            x: 0,
            y: 20
        )
        .frame(maxWidth: .infinity, alignment: message.alignment)
        .padding(.leading, message.leadingPadding)
        .padding(.trailing, message.trailingPadding)
        .overlay(alignment: message.reactionAnchor) {
            MessageReactionView(message: message)
                .offset(x: message.showGroupChatPartnerProfileImage ? 44 : 0, y: 10)
        }
        .onReceive(audioMessagePlayer.$playbackState) { playbackState in
            observePlaybackState(playbackState)
        }
        .onReceive(audioMessagePlayer.$currentTime) { currentTime in
            guard audioMessagePlayer.currentAudioURL?.absoluteString == message.audioURL else { return }
            observeCurrentPlayerTime(currentTime)
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
            Text(message.timestamp.timeRepresentation)
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
        switch state {
        case .stopped:
            playbackState = .stopped
            sliderValue = 0
        case .playing, .paused:
            if isCurrentAudioMessage {
                playbackState = state
            }
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
    .environmentObject(AudioMessagePlayer())
}
