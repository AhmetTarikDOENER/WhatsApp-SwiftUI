import SwiftUI

struct BubbleAudioView: View {
    
    let message: Message
    
    @State private var sliderValue = 0.0
    @State private var sliderRange: ClosedRange<Double> = 0...20
    
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
    }
    
    //  MARK: - Private
    private func playButton() -> some View {
        Button {
            
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
