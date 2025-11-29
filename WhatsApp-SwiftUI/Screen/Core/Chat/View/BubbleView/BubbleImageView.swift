import SwiftUI
import Kingfisher

struct BubbleImageView: View {
    
    let message: Message
    
    var body: some View {
        HStack {
            if message.direction == .outgoing { Spacer() }
            
            HStack {
                if message.direction == .outgoing { shareButton() }
                
                messageImageView()
                    .shadow(
                        color: Color(.systemGray3).opacity(0.1),
                        radius: 5,
                        x: 0,
                        y: 20
                    )
                    .overlay {
                        playButton()
                            .opacity(message.type == .video ? 1 : 0)
                    }
                
                if message.direction == .received { shareButton() }
            }
            
            if message.direction == .received { Spacer() }
        }
    }
    
    //  MARK: - Private
    private func shareButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "arrowshape.turn.up.right.fill")
                .padding(10)
                .foregroundStyle(.white)
                .background(.gray)
                .clipShape(Circle())
        }
    }
    
    private func messageImageView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            KFImage(URL(string: message.thumbnailURL ?? ""))
                .resizable()
                .placeholder { ProgressView() }
                .scaledToFill()
                .frame(width: message.imageSize.width, height: message.imageSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.systemGray5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color(.systemGray5))
                )
                .padding(5)
                .overlay(alignment: .bottomTrailing) {
                    timestampTextView()
                }
            
            Text(message.text)
                .padding([.horizontal, .bottom], 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(width: message.imageSize.width)
        }
        .background(message.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .applyTail(message.direction)
    }
    
    private func timestampTextView() -> some View {
        HStack {
            Text("12:34")
                .font(.system(size: 12))
            
            if message.direction == .outgoing {
                Image(.seen)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 15, height: 15)
            }
        }
        .padding(.vertical, 2.5)
        .padding(.horizontal, 8)
        .foregroundStyle(.white)
        .background(Color(.systemGray3))
        .clipShape(Capsule())
        .padding(10)
    }
    
    private func playButton() -> some View {
        Image(systemName: "play.fill")
            .padding()
            .imageScale(.large)
            .foregroundStyle(.gray)
            .background(.thinMaterial)
            .clipShape(Circle())
    }
}

#Preview {
    ScrollView {
        BubbleImageView(message: .receivedPlaceholder)
        BubbleImageView(message: .sentPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
    .background(.gray.opacity(0.5))
}
