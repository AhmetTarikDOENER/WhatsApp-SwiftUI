import SwiftUI

struct MediaAttachmentsPreview: View {
    
    //  MARK: - Property
    let mediaAttachments: [MediaAttachments]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                audioAttachmentPreview()
                ForEach(mediaAttachments) { attachment in
                    thumbnailImageView(attachment)
                }
            }
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
                    cancelButton()
                }
                .overlay(alignment: .center) {
                    playButton("play.fill")
                }
        }
    }
    
    private func cancelButton() -> some View {
        Button {
            
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
    
    private func playButton(_ systemName: String) -> some View {
        Button {
            
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
    
    private func audioAttachmentPreview() -> some View {
        ZStack {
            LinearGradient(
                colors: [.green, .green.opacity(0.7), .teal],
                startPoint: .topLeading,
                endPoint: .bottom
            )
            playButton("mic.fill")
                .padding(.bottom, 12)
        }
        .frame(width: Constants.attachmentImageDimension * 1.75, height: Constants.attachmentImageDimension)
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        .clipped()
        .overlay(alignment: .topTrailing) {
            cancelButton()
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

//  MARK: - MediaAttachmentsPreview+Constants
extension MediaAttachmentsPreview {
    enum Constants {
        static let attachmentListHeight: CGFloat = 100
        static let attachmentImageDimension: CGFloat = 80
    }
}

#Preview {
    MediaAttachmentsPreview(mediaAttachments: [])
}
