import SwiftUI

struct TextInputAreaView: View {
    
    @Binding var textMessage: String
    let actionHandler: (_ action: UserAction) -> Void
    
    private var disableSendButton: Bool { textMessage.isEmptyOrWhitespace }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            imagePickerButton()
                .padding(3)
            audioRecorderButton()
            messageTextField()
            sendMessageButton()
                .disabled(disableSendButton)
                .grayscale(disableSendButton ? 0.8 : 0)
        }
        .padding(.bottom)
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .background(.whatsAppWhite)
    }
    
    //  MARK: - Private
    private func imagePickerButton() -> some View {
        Button {
            actionHandler(.presentPhotoPicker)
        } label: {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 20))
        }
    }
    
    private func audioRecorderButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "mic.fill")
                .fontWeight(.heavy)
                .imageScale(.small)
                .foregroundStyle(.white)
                .padding(6)
                .background(.blue)
                .clipShape(Circle())
                .padding(.horizontal, 3)
        }
    }
    
    private func messageTextField() -> some View {
        TextField("", text: $textMessage, axis: .vertical)
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.thinMaterial)
            )
            .overlay(textViewBorder())
    }
    
    private func textViewBorder() -> some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(Color(.systemGray5), lineWidth: 1)
    }
    
    private func sendMessageButton() -> some View {
        Button {
            actionHandler(.sendMessage)
        } label: {
            Image(systemName: "arrow.up")
                .font(.system(size: 20))
                .fontWeight(.heavy)
                .imageScale(.small)
                .foregroundStyle(.white)
                .padding(6)
                .background(.blue)
                .clipShape(Circle())
                .padding(.horizontal, 3)
        }
    }
}

//  MARK: - TextInputAreaView+UserAction
extension TextInputAreaView {
    enum UserAction {
        case presentPhotoPicker
        case sendMessage
    }
}

#Preview {
    TextInputAreaView(textMessage: .constant("")) { _ in
        
    }
}
