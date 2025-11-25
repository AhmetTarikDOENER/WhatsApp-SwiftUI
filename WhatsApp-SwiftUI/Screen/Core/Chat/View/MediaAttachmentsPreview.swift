import SwiftUI

struct MediaAttachmentsPreview: View {
    
    //  MARK: - Property
    let mediaAttachments: [MediaAttachments]
    let actionHandler: (_ action: UserAction) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(mediaAttachments) { attachment in
                    thumbnailImageView(attachment)
                }
            }
            .padding(.horizontal)
        }
        .frame(height: Constants.attachmentListHeight)
        .frame(maxWidth: .infinity)
        .background(.whatsAppWhite)
    }
    
    //  MARK: - Private
    private func thumbnailImageView(_ attachment: MediaAttachments) -> some View {
        Button {
            
        } label: {
            Image(uiImage: attachment.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(
                    width: Constants.attachmentImageDimension,
                    height: Constants.attachmentImageDimension
                )
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .clipped()
                .overlay(alignment: .topTrailing) {
                    cancelButton(attachment)
                }
                .overlay(alignment: .center) {
                    playButton("play.fill", attachment: attachment)
                        .opacity(attachment.type == .video(UIImage(), .stubURL) ? 1 : 0)
                }
        }
    }
    
    private func cancelButton(_ attachment: MediaAttachments) -> some View {
        Button {
            actionHandler(.remove(attachment))
        } label: {
            Image(systemName: "xmark")
                .scaledToFit()
                .imageScale(.small)
                .padding(4)
                .foregroundStyle(.white)
                .background(.white.opacity(0.5))
                .clipShape(Circle())
                .shadow(radius: 4)
                .padding(2)
                .bold()
        }
    }
    
    private func playButton(_ systemName: String, attachment: MediaAttachments) -> some View {
        Button {
            actionHandler(.play(attachment))
        } label: {
            Image(systemName: systemName)
                .scaledToFit()
                .imageScale(.large)
                .padding(10)
                .foregroundStyle(.white)
                .background(.white.opacity(0.5))
                .clipShape(Circle())
                .shadow(radius: 4)
                .padding(2)
                .bold()
        }
    }
    
    private func audioAttachmentPreview(attachment: MediaAttachments) -> some View {
        ZStack {
            LinearGradient(
                colors: [.green, .green.opacity(0.7), .teal],
                startPoint: .topLeading,
                endPoint: .bottom
            )
            playButton("mic.fill", attachment: attachment)
                .padding(.bottom, 12)
        }
        .frame(width: Constants.attachmentImageDimension * 1.75, height: Constants.attachmentImageDimension)
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        .clipped()
        .overlay(alignment: .topTrailing) {
            cancelButton(attachment)
        }
        .overlay(alignment: .bottomLeading) {
            Text("test.mp3")
                .lineLimit(1)
                .font(.caption)
                .padding(2)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.white.opacity(0.5))
        }
    }
}

//  MARK: - MediaAttachmentsPreview+Constants+UserAction
extension MediaAttachmentsPreview {
    enum Constants {
        static let attachmentListHeight: CGFloat = 100
        static let attachmentImageDimension: CGFloat = 80
    }
    
    enum UserAction {
        case play(_ attachment: MediaAttachments)
        case remove(_ attachment: MediaAttachments)
    }
}

#Preview {
    MediaAttachmentsPreview(mediaAttachments: []) { action in
        
    }
}
